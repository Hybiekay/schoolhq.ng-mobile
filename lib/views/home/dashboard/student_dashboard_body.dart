import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/views/home/dashboard/helpers/dashboard_helpers.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/class_hub_card.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/dashboard_hero_card.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/dashboard_stats_grid.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/empty_tile.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/exam_schedule_tile.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/exam_tile.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/inline_status_card.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/planner_shortcut.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/timetable_tile.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/today_focus_card.dart';

class StudentDashboardBody extends StatelessWidget {
  final Map<String, dynamic> data;
  final AsyncValue<Map<String, dynamic>> timetableAsync;
  final AsyncValue<Map<String, dynamic>> classesAsync;

  const StudentDashboardBody({
    super.key,
    required this.data,
    required this.timetableAsync,
    required this.classesAsync,
  });

  @override
  Widget build(BuildContext context) {
    final student = asDashboardMap(data['student']);
    final counts = asDashboardMap(data['counts']);
    final session = asDashboardMap(data['current_session']);
    final upcomingExams = asDashboardList(data['upcoming_exams']);
    final attendanceToday = asDashboardMap(data['attendance_today']);
    final name = (student['full_name'] ?? 'Student').toString();
    final lessonsTodayLabel = timetableAsync.maybeWhen(
      data: (payload) => '${asDashboardList(payload['today_timetable']).length}',
      orElse: () => '--',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardHeroCard(
          title: 'Welcome back, ${dashboardFirstWord(name)}',
          subtitle: session.isEmpty
              ? 'Your classroom, exams, and daily plan are ready.'
              : 'Current session: ${session['name']}. Start with what matters most today.',
          pills: [
            '${asDashboardMap(student['class'])['name'] ?? 'Your Class'}',
            '${dashboardIntValue(counts['pending_exams'])} pending exams',
          ],
          icon: Icons.dashboard_customize_rounded,
          gradient: AppColors.brandGradient,
        ),
        const SizedBox(height: 18),
        Text('Important First', style: AppTextStyles.headingMedium),
        const SizedBox(height: 10),
        classesAsync.when(
          loading: () => const InlineStatusCard(
            message: 'Preparing your subjects and modules...',
            icon: Icons.auto_stories_outlined,
          ),
          error: (error, _) => const InlineStatusCard(
            message: 'We could not load your classes right now.',
            icon: Icons.menu_book_outlined,
            isError: true,
          ),
          data: (payload) => ClassHubCard(
            payload: payload,
            onTap: () => context.push(RouteNames.classes),
          ),
        ),
        const SizedBox(height: 14),
        TodayFocusCard(
          attendanceLabel: attendanceToday.isEmpty
              ? 'N/A'
              : (attendanceToday['status'] ?? 'N/A').toString().toUpperCase(),
          lessonsLabel: lessonsTodayLabel,
          pendingExamsLabel: '${dashboardIntValue(counts['pending_exams'])}',
          feesLabel: '${dashboardIntValue(counts['fees_open'])}',
          onOpenClass: () => context.push(RouteNames.classes),
          onOpenExams: () => context.push(RouteNames.exams),
        ),
        const SizedBox(height: 20),
        Text('Academic', style: AppTextStyles.headingMedium),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: PlannerShortcut(
                title: 'Results',
                subtitle: 'Check term and session scores',
                icon: Icons.assessment_outlined,
                accent: AppColors.primary,
                onTap: () => context.push(RouteNames.courses),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PlannerShortcut(
                title: 'Fees',
                subtitle: 'Review balances and payments',
                icon: Icons.account_balance_wallet_outlined,
                accent: AppColors.warning,
                onTap: () => context.push(RouteNames.tests),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PlannerShortcut(
                title: 'Messages',
                subtitle: 'Chat with classmates and teachers',
                icon: Icons.forum_outlined,
                accent: AppColors.secondary,
                onTap: () => context.push(RouteNames.messages),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PlannerShortcut(
                title: 'Games',
                subtitle: 'Open the learning arcade',
                icon: Icons.sports_esports_outlined,
                accent: AppColors.accent,
                onTap: () => context.push(RouteNames.games),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Upcoming Exams', style: AppTextStyles.headingMedium),
        const SizedBox(height: 10),
        if (upcomingExams.isEmpty)
          const EmptyTile(message: 'No upcoming exams right now.')
        else
          ...upcomingExams
              .take(4)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ExamTile(item: item),
                ),
              ),
        const SizedBox(height: 20),
        Text('Today\'s Timetable', style: AppTextStyles.headingMedium),
        const SizedBox(height: 10),
        timetableAsync.when(
          loading: () => const InlineStatusCard(
            message: 'Loading timetable...',
            icon: Icons.schedule_outlined,
          ),
          error: (error, _) => InlineStatusCard(
            message: error.toString(),
            icon: Icons.lock_outline_rounded,
            isError: true,
          ),
          data: (payload) {
            final todayLessons = asDashboardList(payload['today_timetable']);
            final examTimetable = asDashboardList(payload['exam_timetable']);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todayLessons.isEmpty)
                  const EmptyTile(message: 'No timetable rows for today.')
                else
                  ...todayLessons.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TimetableTile(item: item),
                    ),
                  ),
                const SizedBox(height: 18),
                Text('Exam Timetable', style: AppTextStyles.headingMedium),
                const SizedBox(height: 10),
                if (examTimetable.isEmpty)
                  const EmptyTile(
                    message: 'No upcoming exam timetable entries right now.',
                  )
                else
                  ...examTimetable.take(4).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ExamScheduleTile(item: item),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text('Planner', style: AppTextStyles.headingMedium),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: PlannerShortcut(
                title: 'Weekly Timetable',
                subtitle: 'Open the full student schedule',
                icon: Icons.view_week_outlined,
                accent: AppColors.accent,
                onTap: () => context.push(RouteNames.timetable),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PlannerShortcut(
                title: 'Calendar',
                subtitle: 'Events and holidays',
                icon: Icons.event_available_outlined,
                accent: AppColors.secondary,
                onTap: () => context.push(RouteNames.calendar),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Quick Stats', style: AppTextStyles.headingMedium),
        const SizedBox(height: 10),
        DashboardStatsGrid(
          items: [
            DashboardStatItem(
              title: 'Attendance Today',
              value: attendanceToday.isEmpty
                  ? 'N/A'
                  : (attendanceToday['status'] ?? 'N/A')
                      .toString()
                      .toUpperCase(),
              icon: Icons.fact_check_outlined,
              accent: AppColors.success,
            ),
            DashboardStatItem(
              title: 'Upcoming Exams',
              value: '${dashboardIntValue(counts['upcoming_exams'])}',
              icon: Icons.school_outlined,
              accent: AppColors.secondary,
            ),
            DashboardStatItem(
              title: 'Lessons Today',
              value: lessonsTodayLabel,
              icon: Icons.schedule_outlined,
              accent: AppColors.accent,
            ),
            DashboardStatItem(
              title: 'Open Fees',
              value: '${dashboardIntValue(counts['fees_open'])}',
              icon: Icons.payments_outlined,
              accent: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }
}
