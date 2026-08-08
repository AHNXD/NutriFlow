import 'package:flutter/material.dart';

import '../screens/drinks_bank/drinks_bank_screen.dart';
import '../screens/food_lists/food_lists_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/plan_builder/plans_list_screen.dart';
import '../screens/recipe_bank/recipe_bank_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/supplements_bank/supplements_bank_screen.dart';
import '../screens/tips_bank/tips_bank_screen.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';

/// One place in the app you can navigate to. Shared by the phone home
/// screen (which renders them as cards) and the desktop rail (which
/// renders them as destinations), so the two can never drift apart.
class AppDestination {
  const AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.accent,
    required this.builder,
    this.subtitle,
    this.primary = false,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final IconData selectedIcon;

  /// Where this section sits on the brand ramp. Gives each bank its own
  /// identity without introducing colours from outside the logo.
  final Color accent;
  final WidgetBuilder builder;

  /// The one destination that gets the full-width gradient treatment on
  /// the home screen — building plans is what the app is for.
  final bool primary;
}

const appDestinations = <AppDestination>[
  AppDestination(
    label: 'الخطط الغذائية',
    subtitle: 'إنشاء خطة جديدة أو متابعة خطة قائمة',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    accent: AppColors.blue,
    primary: true,
    builder: _plans,
  ),
  AppDestination(
    label: 'بنك الأكلات',
    subtitle: 'الوصفات والمكوّنات',
    icon: Icons.restaurant_menu_outlined,
    selectedIcon: Icons.restaurant_menu,
    accent: AppColors.aqua,
    builder: _recipes,
  ),
  AppDestination(
    label: 'بنك النصائح',
    subtitle: 'رسائل تحفيزية وإرشادات',
    icon: Icons.lightbulb_outline,
    selectedIcon: Icons.lightbulb,
    accent: AppColors.violet,
    builder: _tips,
  ),
  AppDestination(
    label: 'المشروبات المساعدة',
    subtitle: 'مشروبات الخطة وتوقيتها',
    icon: Icons.local_drink_outlined,
    selectedIcon: Icons.local_drink,
    accent: AppColors.sky,
    builder: _drinks,
  ),
  AppDestination(
    label: 'المكملات الغذائية',
    subtitle: 'الجرعات والتوقيت',
    icon: Icons.medication_outlined,
    selectedIcon: Icons.medication,
    accent: AppColors.indigo,
    builder: _supplements,
  ),
  AppDestination(
    label: 'المسموح والممنوع',
    subtitle: 'قوائم الأصناف',
    icon: Icons.rule_outlined,
    selectedIcon: Icons.rule,
    accent: AppColors.navy,
    builder: _foodLists,
  ),
];

// Top-level builders, so the destination list can stay `const`.
Widget _plans(BuildContext _) => const PlansListScreen();
Widget _recipes(BuildContext _) => const RecipeBankScreen();
Widget _tips(BuildContext _) => const TipsBankScreen();
Widget _drinks(BuildContext _) => const DrinksBankScreen();
Widget _supplements(BuildContext _) => const SupplementsBankScreen();
Widget _foodLists(BuildContext _) => const FoodListsScreen();

/// Root of the app.
///
/// On a phone it is the home hub, and sections open by pushing a route. On
/// a laptop that would waste most of the window, so the same sections
/// become a persistent rail with the section rendered beside it — no
/// push, no back button, the way a desktop app behaves.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Which destination is showing, or null when Settings is — Settings sits
  /// outside the rail's destination list (it is the trailing button), so it
  /// deliberately is *not* an index. Modelling it as `destinations.length`
  /// is what NavigationRail asserts against, and it crashed the pane.
  int? _index = 0;

  bool get _settingsOpen => _index == null;

  @override
  Widget build(BuildContext context) {
    if (!context.isExpanded) return const HomeScreen();

    return Scaffold(
      body: Row(
        children: [
          _Rail(index: _index, onSelected: (i) => setState(() => _index = i)),
          const VerticalDivider(width: 1),
          Expanded(
            child: _settingsOpen
                ? const SettingsScreen()
                : appDestinations[_index!].builder(context),
          ),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.index, required this.onSelected});

  /// null selects nothing in the rail — Settings is open.
  final int? index;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Extended labels need room; below this the rail stays icons-only so
    // it never eats the content pane.
    final extended = width >= 1280;

    return SingleChildScrollView(
      child: IntrinsicHeight(
        child: NavigationRail(
          extended: extended,
          minExtendedWidth: 232,
          selectedIndex: index,
          onDestinationSelected: onSelected,
          labelType: extended
              ? NavigationRailLabelType.none
              : NavigationRailLabelType.all,
          leading: Padding(
            padding: EdgeInsets.fromLTRB(
              extended ? 16 : 0,
              20,
              extended ? 16 : 0,
              12,
            ),
            child: _RailBrand(extended: extended),
          ),
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IconButton(
                  tooltip: 'الإعدادات',
                  isSelected: index == null,
                  onPressed: () => onSelected(null),
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(
                    Icons.settings,
                    color: AppColors.blue,
                  ),
                ),
              ),
            ),
          ),
          destinations: [
            for (final d in appDestinations)
              NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: Text(d.label),
              ),
          ],
        ),
      ),
    );
  }
}

class _RailBrand extends StatelessWidget {
  const _RailBrand({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Text(
        'NF',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
    );

    if (!extended) return mark;

    return Row(
      children: [
        mark,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NutriFlow', style: Theme.of(context).textTheme.titleMedium),
              Text(
                'كل شيء بمكان واحد',
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
