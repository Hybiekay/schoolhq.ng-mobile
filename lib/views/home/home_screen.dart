import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/school/current_school.dart';
import 'package:schoolhq_ng/providers/auth_provider.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/widget/school_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final dashboard = ref.watch(mobileDashboardProvider);
    final timetable = role == 'student'
        ? ref.watch(mobileTimetableProvider)
        : const AsyncValue<Map<String, dynamic>>.data(<String, dynamic>{});

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          role == 'parent' ? 'Parent Dashboard' : 'Student Dashboard',
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(mobileDashboardProvider);
              if (role == 'student') {
                ref.invalidate(mobileTimetableProvider);
                ref.invalidate(mobileCalendarProvider);
              }
            },
          ),
        ],
      ),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(mobileDashboardProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(mobileDashboardProvider);
            if (role == 'student') {
              ref.invalidate(mobileTimetableProvider);
              ref.invalidate(mobileCalendarProvider);
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              _SchoolDirectoryCard(
                onSwitchSchool: () => _switchSchool(context, ref),
              ),
              const SizedBox(height: 16),
              ...(role == 'parent'
                  ? _buildParentDashboard(data)
                  : _buildStudentDashboard(context, data, timetable)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _switchSchool(BuildContext context, WidgetRef ref) async {
    final shouldSwitch = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Switch school?'),
        content: const Text(
          'We will sign you out first so the next school uses the correct account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );

    if (shouldSwitch != true || !context.mounted) {
      return;
    }

    await ref.read(authProvider.notifier).logout(clearSchool: true);

    if (context.mounted) {
      context.go(RouteNames.selectSchool);
    }
  }

  List<Widget> _buildStudentDashboard(
    BuildContext context,
    Map<String, dynamic> data,
    AsyncValue<Map<String, dynamic>> timetableAsync,
  ) {
    final student = _asMap(data['student']);
    final counts = _asMap(data['counts']);
    final session = _asMap(data['current_session']);
    final upcomingExams = _asList(data['upcoming_exams']);
    final attendanceToday = _asMap(data['attendance_today']);
    final name = (student['full_name'] ?? 'Student').toString();

    return [
      _HeroCard(
        title: 'Welcome back, ${_firstWord(name)}',
        subtitle: session.isEmpty
            ? 'Your mobile dashboard is ready.'
            : 'Current session: ${session['name']}',
        pills: [
          '${_intValue(counts['upcoming_exams'])} upcoming exams',
          '${_intValue(counts['pending_exams'])} pending',
        ],
      ),
      const SizedBox(height: 16),
      Text('Quick Stats', style: AppTextStyles.headingMedium),
      const SizedBox(height: 10),
      _StatsGrid(
        items: [
          _StatItem(
            title: 'Attendance Today',
            value: attendanceToday.isEmpty
                ? 'N/A'
                : (attendanceToday['status'] ?? 'N/A').toString().toUpperCase(),
            icon: Icons.fact_check_outlined,
          ),
          _StatItem(
            title: 'Upcoming Exams',
            value: '${_intValue(counts['upcoming_exams'])}',
            icon: Icons.school_outlined,
          ),
          _StatItem(
            title: 'Pending Exams',
            value: '${_intValue(counts['pending_exams'])}',
            icon: Icons.pending_actions_outlined,
          ),
          _StatItem(
            title: 'Open Fees',
            value: '${_intValue(counts['fees_open'])}',
            icon: Icons.payments_outlined,
          ),
          _StatItem(
            title: 'Lessons Today',
            value: timetableAsync.maybeWhen(
              data: (payload) =>
                  '${_asList(payload['today_timetable']).length}',
              orElse: () => '--',
            ),
            icon: Icons.schedule_outlined,
          ),
        ],
      ),
      const SizedBox(height: 18),
      Text('Planner', style: AppTextStyles.headingMedium),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _PlannerShortcut(
              title: 'Weekly Timetable',
              subtitle: 'Open the full student schedule',
              icon: Icons.view_week_outlined,
              onTap: () => context.push(RouteNames.timetable),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PlannerShortcut(
              title: 'Calendar',
              subtitle: 'Events and holidays',
              icon: Icons.event_available_outlined,
              onTap: () => context.push(RouteNames.calendar),
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Text('Upcoming Exams', style: AppTextStyles.headingMedium),
      const SizedBox(height: 10),
      if (upcomingExams.isEmpty)
        const _EmptyTile(message: 'No upcoming exams right now.')
      else
        ...upcomingExams
            .take(5)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ExamTile(item: item),
              ),
            ),
      const SizedBox(height: 18),
      Text('Today\'s Timetable', style: AppTextStyles.headingMedium),
      const SizedBox(height: 10),
      timetableAsync.when(
        loading: () => const _InlineStatusCard(
          message: 'Loading timetable...',
          icon: Icons.schedule_outlined,
        ),
        error: (error, _) => _InlineStatusCard(
          message: error.toString(),
          icon: Icons.lock_outline_rounded,
          isError: true,
        ),
        data: (payload) {
          final todayLessons = _asList(payload['today_timetable']);
          final examTimetable = _asList(payload['exam_timetable']);

          return Column(
            children: [
              if (todayLessons.isEmpty)
                const _EmptyTile(message: 'No timetable rows for today.')
              else
                ...todayLessons.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TimetableTile(item: item),
                  ),
                ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Exam Timetable',
                  style: AppTextStyles.headingMedium,
                ),
              ),
              const SizedBox(height: 10),
              if (examTimetable.isEmpty)
                const _EmptyTile(
                  message: 'No upcoming exam timetable entries right now.',
                )
              else
                ...examTimetable
                    .take(4)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ExamScheduleTile(item: item),
                      ),
                    ),
            ],
          );
        },
      ),
    ];
  }

  List<Widget> _buildParentDashboard(Map<String, dynamic> data) {
    final parent = _asMap(data['parent']);
    final counts = _asMap(data['counts']);
    final children = _asList(data['children']);
    final name = (parent['full_name'] ?? 'Parent').toString();

    return [
      _HeroCard(
        title: 'Hello, ${_firstWord(name)}',
        subtitle: 'Track your children from one place.',
        pills: [
          '${_intValue(counts['children'])} children',
          'Fee balance ${_money(counts['total_fee_balance'])}',
        ],
      ),
      const SizedBox(height: 16),
      Text('Overview', style: AppTextStyles.headingMedium),
      const SizedBox(height: 10),
      _StatsGrid(
        items: [
          _StatItem(
            title: 'Children',
            value: '${_intValue(counts['children'])}',
            icon: Icons.family_restroom_outlined,
          ),
          _StatItem(
            title: 'Open Fee Items',
            value: '${_intValue(counts['outstanding_fee_items'])}',
            icon: Icons.receipt_long_outlined,
          ),
          _StatItem(
            title: 'Fee Balance',
            value: _money(counts['total_fee_balance']),
            icon: Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
      const SizedBox(height: 18),
      Text('Children', style: AppTextStyles.headingMedium),
      const SizedBox(height: 10),
      if (children.isEmpty)
        const _EmptyTile(
          message: 'No children linked to this parent account yet.',
        )
      else
        ...children.map(
          (child) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChildTile(child: child),
          ),
        ),
    ];
  }
}

class _SchoolDirectoryCard extends StatelessWidget {
  final VoidCallback onSwitchSchool;

  const _SchoolDirectoryCard({required this.onSwitchSchool});

  @override
  Widget build(BuildContext context) {
    final school = currentSchool();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          SchoolLogo(logo: school.logo, size: 48, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current School', style: AppTextStyles.small),
                const SizedBox(height: 4),
                Text(
                  school.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          if (!kIsWeb)
            TextButton(onPressed: onSwitchSchool, child: const Text('Switch')),
        ],
      ),
    );
  }
}

class _PlannerShortcut extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PlannerShortcut({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.small),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> pills;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.pills,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF265BE3), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pills
                .where((e) => e.trim().isNotEmpty)
                .map(
                  (label) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      label,
                      style: AppTextStyles.small.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<_StatItem> items;

  const _StatsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (_, index) => _StatCard(item: items[index]),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 0.3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 18, color: AppColors.primary),
            ),
            const Spacer(),
            Text(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.title,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ExamTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final subject = _asMap(item['subject'])['name']?.toString() ?? 'Subject';
    final title = (item['title'] ?? 'Exam').toString();
    final status =
        _asMap(item['attempt'])['status']?.toString() ?? 'not_started';
    final startDate = _formatIso(item['start_date']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subject, style: AppTextStyles.small),
                const SizedBox(height: 2),
                Text(
                  startDate == null
                      ? status.replaceAll('_', ' ')
                      : 'Starts $startDate',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimetableTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _TimetableTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final subject = _asMap(item['subject'])['name']?.toString();
    final teacher = _asMap(item['teacher'])['name']?.toString();
    final location = item['location']?.toString();
    final className = _asMap(item['class'])['name']?.toString();
    final lines = [
      if (subject != null && subject.isNotEmpty) subject,
      if (teacher != null && teacher.isNotEmpty) teacher,
      if (className != null && className.isNotEmpty) className,
      if (location != null && location.isNotEmpty) location,
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.schedule, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['title'] ?? 'Lesson').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeRange(item['starts_at'], item['ends_at']),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (lines.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(lines.join(' | '), style: AppTextStyles.small),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamScheduleTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ExamScheduleTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final subject = _asMap(item['subject'])['name']?.toString();
    final location = item['location']?.toString();
    final date = _formatIsoDate(item['start_date']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_note_outlined,
              color: Color(0xFFE11D48),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['title'] ?? 'Exam').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (date != null) date,
                    _formatTimeRange(item['starts_at'], item['ends_at']),
                  ].join(' | '),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((subject ?? '').isNotEmpty || (location ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      [
                        if ((subject ?? '').isNotEmpty) subject!,
                        if ((location ?? '').isNotEmpty) location!,
                      ].join(' | '),
                      style: AppTextStyles.small,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  final Map<String, dynamic> child;

  const _ChildTile({required this.child});

  @override
  Widget build(BuildContext context) {
    final classMap = _asMap(child['class']);
    final deptMap = _asMap(child['department']);
    final status = (child['attendance_today'] ?? 'unknown').toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.12),
            foregroundColor: AppColors.primary,
            child: Text(
              _initials((child['full_name'] ?? '').toString()),
              style: AppTextStyles.small.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (child['full_name'] ?? 'Student').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    classMap['name']?.toString(),
                    deptMap['name']?.toString(),
                  ].where((e) => e != null && e.isNotEmpty).join(' • '),
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status.toUpperCase(),
              style: AppTextStyles.small.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  final String message;

  const _EmptyTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, style: AppTextStyles.subtitle),
    );
  }
}

class _InlineStatusCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isError;

  const _InlineStatusCard({
    required this.message,
    required this.icon,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.replaceFirst('Exception: ', ''),
              style: AppTextStyles.subtitle.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: AppColors.grey,
            ),
            const SizedBox(height: 10),
            Text(
              'Failed to load dashboard',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.small,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> _asList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _money(dynamic value) {
  final amount = (value is num)
      ? value.toDouble()
      : double.tryParse('${value ?? 0}') ?? 0;
  return '\$${amount.toStringAsFixed(amount >= 1000 ? 0 : 2)}';
}

String _firstWord(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  return parts.isEmpty ? value : parts.first;
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

String? _formatIso(dynamic raw) {
  if (raw == null) return null;
  try {
    final dt = DateTime.parse(raw.toString()).toLocal();
    final month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][dt.month - 1];
    return '$month ${dt.day}';
  } catch (_) {
    return null;
  }
}

String? _formatIsoDate(dynamic raw) {
  if (raw == null) return null;
  try {
    final dt = DateTime.parse(raw.toString()).toLocal();
    final month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][dt.month - 1];
    return '$month ${dt.day}, ${dt.year}';
  } catch (_) {
    return raw.toString();
  }
}

String _formatTimeRange(dynamic start, dynamic end) {
  final startLabel = (start ?? '').toString();
  final endLabel = (end ?? '').toString();

  if (startLabel.isEmpty && endLabel.isEmpty) {
    return 'Time not set';
  }

  if (startLabel.isNotEmpty && endLabel.isNotEmpty) {
    return '$startLabel - $endLabel';
  }

  return startLabel.isNotEmpty ? startLabel : endLabel;
}
