# توصيف تقني كامل — تطبيق مساعد أخصائية التغذية (NutriFlow)

> هذا الملف مرجع تقني كامل للمشروع، مُعد ليُستخدم كنقطة انطلاق مع Claude Code لبناء التطبيق فعليًا.

---

## 1. نظرة عامة على المشروع

**اسم المشروع:** NutriFlow

**المشكلة:** أخصائية التغذية تبني خططًا غذائية أسبوعية (7 أيام) لكل مريض يدويًا باستخدام Gamma، وتُعيد كتابة نفس الوصفات، النصائح، الجداول والتنسيق من الصفر كل مرة — عملية بطيئة ومكررة.

**الحل:** تطبيق Flutter (موبايل + ديسكتوب) يسمح لها بـ:
1. بناء **بنك أكلات** دائم (اسم، صورة، مكونات، طريقة تحضير) تستخدمه لمرة واحدة وتُعيد استعماله لا نهائيًا.
2. بناء **بنك نصائح ورسائل تحفيزية** يومية.
3. بناء **بنك مشروبات مساعدة ومكملات غذائية**.
4. **تركيب خطة أسبوعية** لكل مريض عبر السحب من البنوك أعلاه أو الكتابة اليدوية، مع تعديل الكميات لكل حالة.
5. تصدير الخطة **بضغطة زر** إلى ملف PDF منسّق احترافيًا (صفحة/أيام)، جاهز للإرسال المباشر للمريض.

**المستخدم الوحيد حاليًا:** الأخصائية (لا حاجة لتسجيل دخول معقد أو أدوار متعددة في النسخة الأولى — يمكن إضافة ذلك لاحقًا).

**قيد أساسي:** الكلفة = صفر. لا خوادم مدفوعة، لا بطاقات ائتمان، بدون تعقيد تقني يصل للمستخدمة النهائية.

---

## 2. البنية التقنية (Architecture)

```
┌─────────────────────────┐
│   Flutter App            │  ← موبايل + ديسكتوب (نفس الكود)
│   (recipe bank, plan     │
│    builder, PDF trigger) │
└───────────┬──────────────┘
            │ supabase_flutter SDK
            ▼
┌─────────────────────────┐
│   Supabase (مجاني)       │
│   - Postgres DB           │
│   - Storage (صور الأكلات) │
└───────────┬──────────────┘
            │ REST call عند طلب PDF
            ▼
┌─────────────────────────┐
│   FastAPI على Render      │
│   (مجاني)                 │
│   - Jinja2 templates      │
│   - WeasyPrint → PDF      │
└───────────┬──────────────┘
            │
            ▼
      ملف PDF جاهز
      (تحميل / مشاركة مباشرة)

┌─────────────────────────┐
│   n8n (موجود أصلًا)       │
│   - ping دوري لـ Supabase │
│     و Render لإبقائهم     │
│     نشطين (كل 24-48 ساعة) │
└─────────────────────────┘
```

### مكونات المشروع (Repo Structure المقترح)

```
nutrition-planner/
├── mobile_app/              # Flutter project
│   ├── lib/
│   │   ├── models/
│   │   ├── services/        # supabase_service.dart, pdf_service.dart
│   │   ├── screens/
│   │   │   ├── recipe_bank/
│   │   │   ├── tips_bank/
│   │   │   ├── plan_builder/
│   │   │   └── plan_preview/
│   │   ├── widgets/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── pdf_service/              # FastAPI project
│   ├── app/
│   │   ├── main.py
│   │   ├── routers/
│   │   │   └── plan_pdf.py
│   │   ├── templates/        # Jinja2 HTML templates (RTL)
│   │   │   ├── base.html
│   │   │   ├── cover_page.html
│   │   │   ├── day_page.html
│   │   │   ├── notes_page.html
│   │   │   └── styles.css
│   │   └── schemas.py
│   ├── requirements.txt
│   └── Dockerfile (اختياري لـ Render)
│
└── docs/
    └── nutrition-planner-spec.md   # هذا الملف
```

---

## 3. الحزمة التقنية (Tech Stack)

| الطبقة | الأداة | السبب |
|---|---|---|
| Frontend | **Flutter** (Dart) | كود واحد لموبايل + ديسكتوب |
| Backend/DB | **Supabase** (Postgres + Storage) | مجاني بدون بطاقة، علاقات قوية، مساحة صور |
| توليد PDF | **FastAPI + Jinja2 + WeasyPrint** على **Render** | تحكم كامل بتصميم RTL عربي |
| أتمتة/keep-alive | **n8n** (موجود أصلًا في المشروع التجاري الآخر) | ping دوري مجاني |
| الخطوط | Cairo أو Tajawal (Google Fonts, مجاني) | يدعم العربي بشكل احترافي |

---

## 4. مخطط قاعدة البيانات (Supabase / Postgres Schema)

```sql
-- ========== بنك الأكلات ==========
create table recipes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  meal_type text not null check (meal_type in ('breakfast','lunch','dinner','snack','salad','drink')),
  image_url text,
  ingredients jsonb not null default '[]',   -- [{ "item": "زبادي يوناني", "amount": "300", "unit": "غ" }]
  steps text[] not null default '{}',        -- كل عنصر = خطوة
  tip text,                                  -- نصيحة اختيارية خاصة بالوصفة (مثل نصيحة الشوفان المنقوع)
  tags text[] default '{}',                  -- مثل: عالي بروتين، صيام متقطع، نباتي
  created_at timestamptz default now()
);

-- ========== بنك النصائح والرسائل التحفيزية ==========
create table tips (
  id uuid primary key default gen_random_uuid(),
  text text not null,
  category text default 'general'            -- general / hunger / hydration / motivation
);

create table motivational_messages (
  id uuid primary key default gen_random_uuid(),
  text text not null                          -- عنوان اليوم التحفيزي مثل "بداية جديدة = فرصة جديدة"
);

-- ========== بنك المشروبات المساعدة ==========
create table helper_drinks (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  ingredients jsonb not null default '[]',
  steps text[] not null default '{}',
  timing text                                 -- "مرة يوميًا بعد الغداء بساعة"
);

-- ========== بنك المكملات الغذائية ==========
create table supplements (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  default_dose text,
  default_timing text,
  default_notes text
);

-- ========== بنك الأطعمة المسموحة / الممنوعة (Global) ==========
create table food_lists (
  id uuid primary key default gen_random_uuid(),
  list_type text not null check (list_type in ('allowed','forbidden')),
  category text not null,      -- بروتينات / دهون صحية / خضار / ألبان / سكريات
  item text not null
);

-- ========== الخطة الأسبوعية ==========
create table plans (
  id uuid primary key default gen_random_uuid(),
  patient_name text not null,
  dietitian_name text not null,
  duration_days int not null default 7,
  fasting_hours int,                          -- مثال: 16
  fasting_notes text,
  general_notes text,                         -- ملاحظات عامة (البروتين، الوزن، إلخ)
  created_at timestamptz default now()
);

create table plan_days (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid references plans(id) on delete cascade,
  day_number int not null,                    -- 1..7
  motivational_text text                      -- عنوان اليوم التحفيزي المخصص
);

create table plan_meals (
  id uuid primary key default gen_random_uuid(),
  plan_day_id uuid references plan_days(id) on delete cascade,
  meal_type text not null check (meal_type in ('breakfast','lunch','dinner','salad','snack')),
  recipe_id uuid references recipes(id),      -- nullable لو أُدخلت يدويًا
  custom_name text,
  custom_ingredients jsonb,                   -- override للمقادير الأصلية إذا عدّلت الكمية
  custom_steps text[],
  sort_order int default 0
);

create table plan_drinks (
  plan_id uuid references plans(id) on delete cascade,
  drink_id uuid references helper_drinks(id),
  primary key (plan_id, drink_id)
);

create table plan_supplements (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid references plans(id) on delete cascade,
  supplement_id uuid references supplements(id),
  dose text,
  timing text,
  notes text
);
```

> **ملاحظة تصميم:** `custom_ingredients` و`custom_steps` بجدول `plan_meals` تسمح للأخصائية إنها تسحب وصفة جاهزة من البنك وتعدّل عليها (مثلًا تغيّر الكمية لمريض معيّن) بدون ما تُغيّر الوصفة الأصلية بالبنك.

### تخزين الصور (Supabase Storage)
- Bucket باسم `recipe-images`، مسار `recipe-images/{recipe_id}.jpg`
- ضغط الصورة على جهاز الأخصائية قبل الرفع (استخدام `flutter_image_compress`) للحفاظ على مساحة الـ 1GB المجانية.

---

## 5. شاشات التطبيق (Flutter Screens)

| الشاشة | الوظيفة |
|---|---|
| **بنك الأكلات** | عرض/بحث/فلترة (فطور، غداء...) + زر إضافة أكلة جديدة (اسم، صورة، مكونات ديناميكية، خطوات، نصيحة) |
| **بنك النصائح** | إضافة/تعديل/حذف نصائح ورسائل تحفيزية |
| **بنك المشروبات والمكملات** | نفس فكرة بنك الأكلات |
| **إنشاء خطة جديدة** | إدخال اسم المريض، عدد الأيام، ساعات الصيام، الملاحظات العامة |
| **باني اليوم (Day Builder)** | لكل يوم: اختيار رسالة تحفيزية + سحب وصفة لكل وجبة (فطور/غداء/عشاء/سلطة) من البنك أو كتابة يدوية + تعديل الكميات |
| **معاينة الخطة** | عرض شكل الخطة قبل التصدير |
| **تصدير PDF** | زر واحد → استدعاء FastAPI → استلام رابط/ملف PDF → مشاركة مباشرة (WhatsApp/Email) عبر `share_plus` |

---

## 6. خدمة توليد PDF (FastAPI)

### Endpoint

```
POST /generate-plan-pdf
Body: { "plan_id": "uuid" }
Response: application/pdf (binary) أو رابط تحميل مؤقت
```

### تدفق العملية
1. الـ Flutter app يبعت `plan_id` فقط.
2. FastAPI يجيب كل بيانات الخطة من Supabase (باستخدام `supabase-py` أو REST مباشر) — الأيام، الوجبات، الوصفات المرتبطة، المشروبات، المكملات، الملاحظات.
3. يعبّي قالب Jinja2 (`day_page.html`) لكل يوم — صفحة مستقلة، بالضبط متل تصميم Gamma (فطور/غداء/عشاء/سلطة + صور + نصيحة اليوم).
4. يضيف صفحة غلاف (اسم المريض + الأخصائية + شعار)، صفحة تعليمات النظام، صفحة الممنوعات/المسموحات، صفحة المكملات، صفحة المشروبات المساعدة، وصفحة ختامية تحفيزية.
5. WeasyPrint يحوّل الـ HTML المجمّع لملف PDF واحد (RTL، خط Cairo/Tajawal).
6. يرجّع الملف مباشرة كـ response أو يرفعه لـ Supabase Storage ويرجّع رابط.

### قالب التصميم (يُبنى ليطابق نمط الملف المرجعي المرفق سابقًا)
- الألوان: تدرّج أخضر زمردي/تركوازي فاتح (متوافق مع هوية Tabiby البصرية إذا رغبت بالتناسق).
- كل يوم = صفحة مستقلة، تقسيم فطور/غداء/عشاء/سلطة بأعمدة، صور الأطباق أسفل الصفحة.
- خط عربي واضح يدعم RTL بالكامل (Cairo أو Tajawal من Google Fonts، مضمّن محليًا كملفات `.ttf` بمجلد fonts حتى ما يحتاج اتصال إنترنت وقت التوليد).

---

## 7. النشر (Deployment) — خطوة بخطوة لاحقًا

| الخدمة | ماذا تستضيف | الخطة |
|---|---|---|
| Supabase | قاعدة البيانات + الصور | Free tier (بدون بطاقة) |
| Render | FastAPI (pdf_service) | Free Web Service (بدون بطاقة) |
| n8n | Workflow لـ ping دوري كل 24-48 ساعة لـ Supabase و Render | مستضاف أصلًا عند Ali |
| الأخصائية | تطبيق Flutter مثبّت مباشرة (APK للأندرويد / حزمة exe أو dmg للديسكتوب) | لا تحتاج أي حساب أو دفع |

---

## 8. نطاق النسخة الأولى (MVP Scope)

**داخل النطاق (v1):**
- بنك الأكلات (CRUD كامل + صور)
- بنك النصائح/الرسائل التحفيزية/المشروبات/المكملات
- بناء خطة 7 أيام بالسحب من البنك أو يدويًا
- تصدير PDF بتصميم ثابت واحد يطابق نمط Gamma الحالي
- تخزين سحابي متزامن بين الموبايل والديسكتوب

**خارج النطاق حاليًا (يُضاف لاحقًا إذا احتجنا):**
- حسابات مرضى/دخول منفصل لهم
- أكثر من مستخدم/أخصائية واحدة (multi-tenant)
- تعديل قوالب PDF من داخل التطبيق (تصميم متعدد الأنماط)
- تتبع تقدم المريض أو متابعة يومية

---

## 9. متغيرات البيئة المطلوبة (لاحقًا عند البناء)

**Flutter (.env / --dart-define):**
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
PDF_SERVICE_URL=   # رابط خدمة Render
```

**FastAPI (.env على Render):**
```
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
```

---

## 10. خطوات البناء المقترحة (Roadmap للتنفيذ)

1. إنشاء مشروع Supabase + تطبيق الجداول أعلاه.
2. إنشاء Flutter project أساسي + ربطه بـ Supabase + شاشة بنك الأكلات (CRUD) كأول قطعة عاملة.
3. إضافة باقي البنوك (نصائح، مشروبات، مكملات).
4. بناء شاشة "إنشاء خطة" + "باني اليوم".
5. بناء خدمة FastAPI + أول قالب Jinja2 ليوم واحد فقط، واختبار WeasyPrint محليًا.
6. توسيع القالب ليغطي كل الصفحات (غلاف، تعليمات، ممنوعات، مكملات، مشروبات، ختام).
7. ربط زر "تصدير PDF" داخل Flutter بخدمة FastAPI.
8. نشر FastAPI على Render + إعداد n8n keep-alive.
9. اختبار شامل مع الأخصائية الفعلية على بيانات حقيقية.

---

*نهاية التوصيف.*
