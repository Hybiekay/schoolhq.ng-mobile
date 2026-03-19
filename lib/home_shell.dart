import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/hive/hive_key.dart';
import 'package:schoolhq_ng/core/school/current_school.dart';
import 'package:schoolhq_ng/enum/user_role.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/widget/school_logo.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final role = _currentRole();
    final school = currentSchool();
    final items = _navItemsForRole(role);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final currentIndex = _getIndex(context, items);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            Container(
              width: 280,
              color: AppColors.white,
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          SchoolLogo(logo: school.logo, size: 36, radius: 10),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              school.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.headingMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: NavigationRail(
                        selectedIndex: currentIndex,
                        labelType: NavigationRailLabelType.all,
                        extended: true,
                        backgroundColor: Colors.transparent,
                        onDestinationSelected: _onTap(context, items),
                        destinations: items
                            .map(
                              (item) => NavigationRailDestination(
                                icon: Icon(item.icon),
                                selectedIcon: Icon(item.selectedIcon),
                                label: Text(item.label),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: currentIndex,
            onDestinationSelected: _onTap(context, items),
            indicatorColor: AppColors.primary.withOpacity(0.14),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: items
                .map(
                  (item) => NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  UserRole _currentRole() {
    final rawRole = Hive.box(
      HiveKey.boxApp,
    ).get(HiveKey.userRole, defaultValue: 'student');
    if (rawRole is String) {
      return UserRole.values.firstWhere(
        (r) => r.name == rawRole.toLowerCase(),
        orElse: () => UserRole.student,
      );
    }
    return UserRole.student;
  }

  List<_NavItem> _navItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return const [
          _NavItem(
            label: 'Dashboard',
            route: RouteNames.home,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
          ),
          _NavItem(
            label: 'Courses',
            route: RouteNames.courses,
            icon: Icons.menu_book_outlined,
            selectedIcon: Icons.menu_book_rounded,
          ),
          _NavItem(
            label: 'Tests',
            route: RouteNames.tests,
            icon: Icons.quiz_outlined,
            selectedIcon: Icons.quiz_rounded,
          ),
          _NavItem(
            label: 'Teacher',
            route: RouteNames.teacherDashboard,
            icon: Icons.campaign_outlined,
            selectedIcon: Icons.campaign_rounded,
          ),
          _NavItem(
            label: 'Profile',
            route: RouteNames.profile,
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
          ),
        ];
      case UserRole.parent:
        return const [
          _NavItem(
            label: 'Dashboard',
            route: RouteNames.home,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
          ),
          _NavItem(
            label: 'Results',
            route: RouteNames.courses,
            icon: Icons.assessment_outlined,
            selectedIcon: Icons.assessment_rounded,
          ),
          _NavItem(
            label: 'Exams',
            route: RouteNames.exams,
            icon: Icons.school_outlined,
            selectedIcon: Icons.school_rounded,
          ),
          _NavItem(
            label: 'Fees',
            route: RouteNames.tests,
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet_rounded,
          ),
          _NavItem(
            label: 'Profile',
            route: RouteNames.profile,
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
          ),
        ];
      case UserRole.staff:
        return const [
          _NavItem(
            label: 'Dashboard',
            route: RouteNames.home,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
          ),
          _NavItem(
            label: 'Teacher',
            route: RouteNames.teacherDashboard,
            icon: Icons.campaign_outlined,
            selectedIcon: Icons.campaign_rounded,
          ),
          _NavItem(
            label: 'Attendance',
            route: RouteNames.attendance,
            icon: Icons.fact_check_outlined,
            selectedIcon: Icons.fact_check_rounded,
          ),
          _NavItem(
            label: 'Exams',
            route: RouteNames.exams,
            icon: Icons.school_outlined,
            selectedIcon: Icons.school_rounded,
          ),
          _NavItem(
            label: 'Profile',
            route: RouteNames.profile,
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
          ),
        ];
      case UserRole.student:
        return const [
          _NavItem(
            label: 'Dashboard',
            route: RouteNames.home,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
          ),
          _NavItem(
            label: 'Results',
            route: RouteNames.courses,
            icon: Icons.assessment_outlined,
            selectedIcon: Icons.assessment_rounded,
          ),
          _NavItem(
            label: 'Exams',
            route: RouteNames.exams,
            icon: Icons.school_outlined,
            selectedIcon: Icons.school_rounded,
          ),
          _NavItem(
            label: 'Fees',
            route: RouteNames.tests,
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet_rounded,
          ),
          _NavItem(
            label: 'Profile',
            route: RouteNames.profile,
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
          ),
        ];
    }
  }

  void Function(int) _onTap(BuildContext context, List<_NavItem> items) =>
      (index) {
        if (index < 0 || index >= items.length) return;
        context.go(items[index].route);
      };

  int _getIndex(BuildContext context, List<_NavItem> items) {
    final location = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].route)) return i;
    }
    return 0;
  }
}

class _NavItem {
  final String label;
  final String route;
  final IconData icon;
  final IconData selectedIcon;

  const _NavItem({
    required this.label,
    required this.route,
    required this.icon,
    required this.selectedIcon,
  });
}
