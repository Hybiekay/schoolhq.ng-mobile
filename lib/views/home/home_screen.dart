import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/views/home/dashboard/parent_dashboard_body.dart';
import 'package:schoolhq_ng/views/home/dashboard/student_dashboard_body.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/dashboard_error_state.dart';
import 'package:schoolhq_ng/views/home/shared/widgets/mobile_top_action_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final dashboard = ref.watch(mobileDashboardProvider);
    final timetable = role == 'student'
        ? ref.watch(mobileTimetableProvider)
        : const AsyncValue<Map<String, dynamic>>.data(<String, dynamic>{});
    final classes = role == 'student'
        ? ref.watch(mobileClassesProvider)
        : const AsyncValue<Map<String, dynamic>>.data(<String, dynamic>{});

    Future<void> refreshDashboard() async {
      ref.invalidate(mobileDashboardProvider);
      final futures = <Future<dynamic>>[
        ref.read(mobileDashboardProvider.future),
      ];
      if (role == 'student') {
        ref.invalidate(mobileClassesProvider);
        ref.invalidate(mobileTimetableProvider);
        ref.invalidate(mobileCalendarProvider);
        futures.addAll([
          ref.read(mobileClassesProvider.future),
          ref.read(mobileTimetableProvider.future),
          ref.read(mobileCalendarProvider.future),
        ]);
      }
      await Future.wait<dynamic>(futures);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: dashboard.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => DashboardErrorState(
            message: error.toString(),
            onRetry: () {
              refreshDashboard();
            },
          ),
          data: (data) => RefreshIndicator(
            onRefresh: refreshDashboard,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                MobileTopActionBar(
                  title: role == 'parent'
                      ? 'Family Dashboard'
                      : 'Student Dashboard',
                  subtitle: '',
                  gradient: role == 'parent'
                      ? AppColors.accentGradient
                      : AppColors.brandGradient,
                  onRefresh: refreshDashboard,
                ),
                const SizedBox(height: 16),
                if (role == 'parent')
                  ParentDashboardBody(data: data)
                else
                  StudentDashboardBody(
                    data: data,
                    timetableAsync: timetable,
                    classesAsync: classes,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
