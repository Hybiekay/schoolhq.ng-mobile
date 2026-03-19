import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:schoolhq_ng/core/feedback/app_snackbar.dart';
import 'package:schoolhq_ng/core/hive/hive_key.dart';
import 'package:schoolhq_ng/routes/route_names.dart';

Future<void> openMobileQuickSearch(BuildContext context) async {
  await showSearch<void>(
    context: context,
    delegate: _MobileQuickSearchDelegate(),
  );
}

void showMobileNotificationsPreview(BuildContext context) {
  AppSnackBar.info(
    context,
    'Notifications will show here when school alerts are connected.',
  );
}

void showMobileChatPreview(BuildContext context) {
  if (!mobileMessagingEnabled()) {
    AppSnackBar.info(
      context,
      'Messaging is available for student and teacher accounts.',
    );
    return;
  }

  GoRouter.of(context).go(RouteNames.messages);
}

class _MobileQuickSearchDelegate extends SearchDelegate<void> {
  @override
  String get searchFieldLabel => 'Search screens';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.close_rounded),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultsList(
      results: _filteredResults(),
      onSelected: (destination) => _openDestination(context, destination),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResultsList(
      results: _filteredResults(),
      onSelected: (destination) => _openDestination(context, destination),
    );
  }

  List<_QuickAccessDestination> _filteredResults() {
    final destinations = _destinationsForRole(currentMobileRole());
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return destinations;
    }

    return destinations.where((destination) {
      return destination.title.toLowerCase().contains(normalized) ||
          destination.subtitle.toLowerCase().contains(normalized);
    }).toList();
  }

  void _openDestination(
    BuildContext context,
    _QuickAccessDestination destination,
  ) {
    final router = GoRouter.of(context);
    close(context, null);
    router.go(destination.route);
  }
}

bool mobileMessagingEnabled() {
  final role = currentMobileRole();
  return role == 'student' || role == 'teacher';
}

bool mobileGamesEnabled() {
  final role = currentMobileRole();
  return role == 'student' || role == 'teacher';
}

String currentMobileRole() {
  final raw = Hive.box(HiveKey.boxApp).get(HiveKey.userRole);
  return raw is String && raw.isNotEmpty ? raw.toLowerCase() : 'student';
}

List<_QuickAccessDestination> _destinationsForRole(String role) {
  final destinations = <_QuickAccessDestination>[
    const _QuickAccessDestination(
      title: 'Dashboard',
      subtitle: 'Go back to your home overview',
      route: RouteNames.home,
      icon: Icons.dashboard_rounded,
    ),
    const _QuickAccessDestination(
      title: 'Classes',
      subtitle: 'Open subjects, modules, and resources',
      route: RouteNames.classes,
      icon: Icons.menu_book_rounded,
    ),
    const _QuickAccessDestination(
      title: 'Results',
      subtitle: 'Review term and session performance',
      route: RouteNames.courses,
      icon: Icons.assessment_rounded,
    ),
    const _QuickAccessDestination(
      title: 'Fees',
      subtitle: 'Check balances and fee items',
      route: RouteNames.tests,
      icon: Icons.account_balance_wallet_rounded,
    ),
    const _QuickAccessDestination(
      title: 'Exams',
      subtitle: 'See current and upcoming exams',
      route: RouteNames.exams,
      icon: Icons.fact_check_rounded,
    ),
    const _QuickAccessDestination(
      title: 'Timetable',
      subtitle: 'View class and exam schedule',
      route: RouteNames.timetable,
      icon: Icons.schedule_rounded,
    ),
    const _QuickAccessDestination(
      title: 'Calendar',
      subtitle: 'School events and holiday dates',
      route: RouteNames.calendar,
      icon: Icons.event_note_rounded,
    ),
    const _QuickAccessDestination(
      title: 'Attendance',
      subtitle: 'Track attendance records',
      route: RouteNames.attendance,
      icon: Icons.how_to_reg_rounded,
    ),
    const _QuickAccessDestination(
      title: 'Profile',
      subtitle: 'Open account and school access details',
      route: RouteNames.profile,
      icon: Icons.person_rounded,
    ),
  ];

  if (role == 'student' || role == 'teacher') {
    destinations.add(
      const _QuickAccessDestination(
        title: 'Messages',
        subtitle: 'Chat with your class network',
        route: RouteNames.messages,
        icon: Icons.forum_rounded,
      ),
    );
    destinations.add(
      const _QuickAccessDestination(
        title: 'Games',
        subtitle: 'Open the learning arcade',
        route: RouteNames.games,
        icon: Icons.sports_esports_rounded,
      ),
    );
  }

  return destinations;
}

Widget _buildResultsList({
  required List<_QuickAccessDestination> results,
  required ValueChanged<_QuickAccessDestination> onSelected,
}) {
  if (results.isEmpty) {
    return const Center(child: Text('No matching screens found.'));
  }

  return ListView.separated(
    padding: const EdgeInsets.all(20),
    itemCount: results.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final destination = results[index];
      return ListTile(
        onTap: () => onSelected(destination),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(destination.icon, color: const Color(0xFF4F46E5)),
        ),
        title: Text(destination.title),
        subtitle: Text(destination.subtitle),
        trailing: const Icon(Icons.arrow_outward_rounded),
      );
    },
  );
}

class _QuickAccessDestination {
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;

  const _QuickAccessDestination({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
  });
}
