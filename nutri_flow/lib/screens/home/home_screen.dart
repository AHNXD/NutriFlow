import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../drinks_bank/drinks_bank_screen.dart';
import '../food_lists/food_lists_screen.dart';
import '../plan_builder/plans_list_screen.dart';
import '../recipe_bank/recipe_bank_screen.dart';
import '../settings/settings_screen.dart';
import '../supplements_bank/supplements_bank_screen.dart';
import '../tips_bank/tips_bank_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.list(children: [
              Text('الخطط', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              _NavCard(
                icon: Icons.calendar_month,
                title: 'خطط المريضات',
                subtitle: 'إنشاء خطة جديدة أو متابعة خطة قائمة',
                gradient: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlansListScreen()),
                ),
              ),
              const SizedBox(height: 24),
              Text('البنوك', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  _NavCard(
                    icon: Icons.restaurant_menu,
                    title: 'بنك الأكلات',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RecipeBankScreen())),
                  ),
                  _NavCard(
                    icon: Icons.lightbulb_outline,
                    title: 'بنك النصائح',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TipsBankScreen())),
                  ),
                  _NavCard(
                    icon: Icons.local_drink_outlined,
                    title: 'المشروبات المساعدة',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const DrinksBankScreen())),
                  ),
                  _NavCard(
                    icon: Icons.medication_outlined,
                    title: 'المكملات الغذائية',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SupplementsBankScreen())),
                  ),
                  _NavCard(
                    icon: Icons.rule,
                    title: 'المسموح والممنوع',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const FoodListsScreen())),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      decoration: const BoxDecoration(gradient: AppColors.gradient),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 52,
              height: 52,
              color: Colors.white,
              padding: const EdgeInsets.all(4),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NutriFlow',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'بنوك الأكلات والخطط الغذائية — كل شيء بمكان واحد',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'الملف الشخصي',
            color: Colors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.gradient = false,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: gradient ? const BoxDecoration(gradient: AppColors.gradient) : null,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: gradient ? Colors.white : AppColors.emerald, size: 28),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: gradient ? Colors.white : null,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: gradient ? Colors.white.withValues(alpha: 0.9) : Colors.black54,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
