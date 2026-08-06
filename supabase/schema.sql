-- ============================================================================
-- NutriFlow — Supabase schema (v1)
-- ============================================================================
-- Run this once against a fresh Supabase project (SQL Editor, or
-- `supabase db push` if you set up the CLI). Safe to re-run: every statement
-- is guarded with IF NOT EXISTS / OR REPLACE where possible.
--
-- v1 has a single user (the dietitian) and no login flow (see spec §1, §8),
-- so RLS below is intentionally permissive: anyone holding the anon key can
-- read/write. That's an acceptable v1 trade-off ONLY because the anon key
-- is never shipped publicly (it lives in the compiled app / --dart-define).
-- The moment this app has more than one trusted holder of that key, add
-- Supabase Auth (email/password is enough) and tighten the policies marked
-- "TIGHTEN LATER" below to `using (auth.uid() is not null)`.
-- ============================================================================

create extension if not exists pgcrypto;

-- ========== helper: auto-update updated_at ==========
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ========== بنك الأكلات (Recipe bank) ==========
create table if not exists recipes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  meal_type text not null check (meal_type in ('breakfast','lunch','dinner','snack','salad','drink')),
  image_url text,
  ingredients jsonb not null default '[]',   -- [{ "item": "زبادي يوناني", "amount": "300", "unit": "غ" }]
  steps text[] not null default '{}',        -- كل عنصر = خطوة
  tip text,                                  -- نصيحة اختيارية خاصة بالوصفة
  tags text[] default '{}',                  -- مثل: عالي بروتين، صيام متقطع، نباتي
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create index if not exists idx_recipes_meal_type on recipes (meal_type);
create index if not exists idx_recipes_name on recipes using gin (to_tsvector('simple', name));
drop trigger if exists trg_recipes_updated_at on recipes;
create trigger trg_recipes_updated_at before update on recipes
  for each row execute function set_updated_at();

-- ========== بنك النصائح والرسائل التحفيزية ==========
create table if not exists tips (
  id uuid primary key default gen_random_uuid(),
  text text not null,
  category text default 'general',           -- general / hunger / hydration / motivation
  created_at timestamptz default now()
);

create table if not exists motivational_messages (
  id uuid primary key default gen_random_uuid(),
  text text not null,                        -- عنوان اليوم التحفيزي
  created_at timestamptz default now()
);

-- ========== بنك المشروبات المساعدة ==========
create table if not exists helper_drinks (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  ingredients jsonb not null default '[]',
  steps text[] not null default '{}',
  timing text,                                -- "مرة يوميًا بعد الغداء بساعة"
  created_at timestamptz default now()
);

-- ========== بنك المكملات الغذائية ==========
create table if not exists supplements (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  default_dose text,
  default_timing text,
  default_notes text,
  created_at timestamptz default now()
);

-- ========== بنك الأطعمة المسموحة / الممنوعة (Global) ==========
create table if not exists food_lists (
  id uuid primary key default gen_random_uuid(),
  list_type text not null check (list_type in ('allowed','forbidden')),
  category text not null,      -- بروتينات / دهون صحية / خضار / ألبان / سكريات
  item text not null,
  created_at timestamptz default now()
);
create index if not exists idx_food_lists_type on food_lists (list_type);

-- ========== الخطة الأسبوعية ==========
create table if not exists plans (
  id uuid primary key default gen_random_uuid(),
  patient_name text not null,
  dietitian_name text not null,
  duration_days int not null default 7,
  fasting_hours int,                          -- مثال: 16
  fasting_notes text,
  general_notes text,                         -- ملاحظات عامة (البروتين، الوزن، إلخ)
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
drop trigger if exists trg_plans_updated_at on plans;
create trigger trg_plans_updated_at before update on plans
  for each row execute function set_updated_at();

create table if not exists plan_days (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid references plans(id) on delete cascade,
  day_number int not null,                    -- 1..duration_days
  motivational_text text,                     -- عنوان اليوم التحفيزي المخصص
  unique (plan_id, day_number)
);
create index if not exists idx_plan_days_plan on plan_days (plan_id);

create table if not exists plan_meals (
  id uuid primary key default gen_random_uuid(),
  plan_day_id uuid references plan_days(id) on delete cascade,
  meal_type text not null check (meal_type in ('breakfast','lunch','dinner','salad','snack')),
  recipe_id uuid references recipes(id) on delete set null,  -- nullable لو أُدخلت يدويًا
  custom_name text,
  custom_ingredients jsonb,                   -- override للمقادير الأصلية إذا عدّلت الكمية
  custom_steps text[],
  sort_order int default 0
);
create index if not exists idx_plan_meals_day on plan_meals (plan_day_id);

create table if not exists plan_drinks (
  plan_id uuid references plans(id) on delete cascade,
  drink_id uuid references helper_drinks(id) on delete cascade,
  primary key (plan_id, drink_id)
);

create table if not exists plan_supplements (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid references plans(id) on delete cascade,
  supplement_id uuid references supplements(id) on delete set null,
  dose text,
  timing text,
  notes text
);
create index if not exists idx_plan_supplements_plan on plan_supplements (plan_id);

-- ============================================================================
-- Row Level Security — v1 permissive policies (see header note above)
-- ============================================================================
do $$
declare
  t text;
begin
  foreach t in array array[
    'recipes','tips','motivational_messages','helper_drinks','supplements',
    'food_lists','plans','plan_days','plan_meals','plan_drinks','plan_supplements'
  ]
  loop
    execute format('alter table %I enable row level security;', t);
    execute format('drop policy if exists "allow_all_v1" on %I;', t);
    -- TIGHTEN LATER: replace `true` with `auth.uid() is not null` once
    -- Supabase Auth is wired up in the Flutter app.
    execute format(
      'create policy "allow_all_v1" on %I for all using (true) with check (true);', t
    );
  end loop;
end $$;

-- ============================================================================
-- Storage — recipe images
-- ============================================================================
insert into storage.buckets (id, name, public)
values ('recipe-images', 'recipe-images', true)
on conflict (id) do nothing;

drop policy if exists "recipe_images_public_read" on storage.objects;
create policy "recipe_images_public_read" on storage.objects
  for select using (bucket_id = 'recipe-images');

drop policy if exists "recipe_images_write_v1" on storage.objects;
-- TIGHTEN LATER alongside the table policies above.
create policy "recipe_images_write_v1" on storage.objects
  for all using (bucket_id = 'recipe-images') with check (bucket_id = 'recipe-images');
