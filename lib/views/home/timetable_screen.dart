import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final timetable = ref.watch(mobileTimetableProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Timetable'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.refresh(mobileTimetableProvider.future),
          ),
        ],
      ),
      body: role != 'student'
          ? _StatusState(
              icon: Icons.lock_outline_rounded,
              title: 'Student timetable only',
              message:
                  'This screen is available for student accounts when the school has timetable records ready.',
            )
          : timetable.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _StatusState(
                icon: Icons.event_busy_outlined,
                title: 'Unable to load timetable',
                message: error.toString(),
                onRetry: () => ref.invalidate(mobileTimetableProvider),
              ),
              data: (data) => _TimetableBody(
                data: data,
                onRefresh: () => ref.refresh(mobileTimetableProvider.future),
              ),
            ),
    );
  }
}

class _TimetableBody extends StatelessWidget {
  final Map<String, dynamic> data;
  final Future<void> Function() onRefresh;

  const _TimetableBody({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final student = _asMap(data['student']);
    final session = _asMap(data['session']);
    final term = _asMap(data['term']);
    final today = data['today']?.toString();
    final todayLessons = _asList(data['today_timetable']);
    final weeklyLessons = _asList(data['weekly_timetable']);
    final examTimetable = _asList(data['exam_timetable']);
    final highlights = _asList(data['calendar_highlights']);
    final grouped = _groupWeeklyLessons(weeklyLessons);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _OverviewCard(
            studentName: (student['full_name'] ?? 'Student').toString(),
            sessionName: session['name']?.toString(),
            termName: term['name']?.toString(),
            today: today,
            lessonCount: todayLessons.length,
            weeklyCount: weeklyLessons.length,
            examCount: examTimetable.length,
          ),
          const SizedBox(height: 18),
          Text('Today', style: AppTextStyles.headingMedium),
          const SizedBox(height: 10),
          if (todayLessons.isEmpty)
            const _EmptyCard(message: 'No lessons are scheduled for today.')
          else
            ...todayLessons.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LessonTile(item: item),
              ),
            ),
          const SizedBox(height: 18),
          Text('Weekly Timetable', style: AppTextStyles.headingMedium),
          const SizedBox(height: 10),
          if (grouped.isEmpty)
            const _EmptyCard(
              message: 'No weekly timetable has been published yet.',
            )
          else
            ...grouped.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WeekdayGroup(day: entry.key, lessons: entry.value),
              ),
            ),
          const SizedBox(height: 18),
          Text('Exam Timetable', style: AppTextStyles.headingMedium),
          const SizedBox(height: 10),
          if (examTimetable.isEmpty)
            const _EmptyCard(
              message: 'No exam timetable entries are available right now.',
            )
          else
            ...examTimetable.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ExamTile(item: item),
              ),
            ),
          const SizedBox(height: 18),
          Text('Calendar Highlights', style: AppTextStyles.headingMedium),
          const SizedBox(height: 10),
          if (highlights.isEmpty)
            const _EmptyCard(
              message: 'No upcoming events or holidays have been added.',
            )
          else
            ...highlights.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HighlightTile(item: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String studentName;
  final String? sessionName;
  final String? termName;
  final String? today;
  final int lessonCount;
  final int weeklyCount;
  final int examCount;

  const _OverviewCard({
    required this.studentName,
    required this.sessionName,
    required this.termName,
    required this.today,
    required this.lessonCount,
    required this.weeklyCount,
    required this.examCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.coolGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            studentName,
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            [
              if ((sessionName ?? '').isNotEmpty) sessionName!,
              if ((termName ?? '').isNotEmpty) termName!,
            ].join(' | ').ifEmpty('School schedule'),
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.white.withOpacity(0.92),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderPill(
                label: _formatDateShort(today),
                icon: Icons.today_outlined,
              ),
              _HeaderPill(
                label: '$lessonCount lessons today',
                icon: Icons.schedule_outlined,
              ),
              _HeaderPill(
                label: '$weeklyCount weekly rows',
                icon: Icons.view_week_outlined,
              ),
              _HeaderPill(
                label: '$examCount exams ahead',
                icon: Icons.school_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HeaderPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayGroup extends StatelessWidget {
  final String day;
  final List<Map<String, dynamic>> lessons;

  const _WeekdayGroup({required this.day, required this.lessons});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  day,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${lessons.length} classes', style: AppTextStyles.small),
            ],
          ),
          const SizedBox(height: 12),
          ...lessons.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == lessons.length - 1 ? 0 : 10,
              ),
              child: _LessonTile(item: entry.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _LessonTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final subject = _asMap(item['subject'])['name']?.toString();
    final teacher = _asMap(item['teacher'])['name']?.toString();
    final className = _asMap(item['class'])['name']?.toString();
    final location = item['location']?.toString();
    final day = item['day_of_week']?.toString();
    final notes = item['description']?.toString();

    final meta = [
      if ((subject ?? '').isNotEmpty) subject!,
      if ((teacher ?? '').isNotEmpty) teacher!,
      if ((className ?? '').isNotEmpty) className!,
      if ((location ?? '').isNotEmpty) location!,
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.schedule_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['title'] ?? subject ?? 'Lesson').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if ((day ?? '').isNotEmpty) _titleCase(day!),
                    _formatTimeRange(item['starts_at'], item['ends_at']),
                  ].join(' | '),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(meta.join(' | '), style: AppTextStyles.subtitle),
                ],
                if ((notes ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(notes!, style: AppTextStyles.small),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ExamTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final subject = _asMap(item['subject'])['name']?.toString();
    final location = item['location']?.toString();
    final notes = item['description']?.toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF8B4C6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
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
                  (item['title'] ?? subject ?? 'Exam').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateRange(item['start_date'], item['end_date']),
                  style: AppTextStyles.small.copyWith(
                    color: const Color(0xFFE11D48),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    _formatTimeRange(item['starts_at'], item['ends_at']),
                    if ((subject ?? '').isNotEmpty) subject!,
                    if ((location ?? '').isNotEmpty) location!,
                  ].join(' | '),
                  style: AppTextStyles.subtitle,
                ),
                if ((notes ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(notes!, style: AppTextStyles.small),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _HighlightTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final type = (item['entry_type'] ?? 'event').toString();
    final isHoliday = type == 'holiday';
    final color = isHoliday ? const Color(0xFF0F766E) : AppColors.primary;
    final background = isHoliday
        ? const Color(0xFFF0FDFA)
        : AppColors.primary.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isHoliday
                  ? Icons.beach_access_outlined
                  : Icons.celebration_outlined,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['title'] ?? _titleCase(type)).toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateRange(item['start_date'], item['end_date']),
                  style: AppTextStyles.small.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((item['description'] ?? '')
                    .toString()
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item['description'].toString(),
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

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

class _StatusState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _StatusState({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message.replaceFirst('Exception: ', ''),
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
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

Map<String, List<Map<String, dynamic>>> _groupWeeklyLessons(
  List<Map<String, dynamic>> lessons,
) {
  final orderedDays = const [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  final grouped = <String, List<Map<String, dynamic>>>{};
  for (final day in orderedDays) {
    final items = lessons
        .where(
          (lesson) =>
              (lesson['day_of_week']?.toString().toLowerCase() ?? '') == day,
        )
        .toList();

    items.sort(
      (a, b) => (a['starts_at']?.toString() ?? '').compareTo(
        b['starts_at']?.toString() ?? '',
      ),
    );

    if (items.isNotEmpty) {
      grouped[_titleCase(day)] = items;
    }
  }

  for (final item in lessons) {
    final rawDay = item['day_of_week']?.toString().trim();
    if (rawDay == null || rawDay.isEmpty) {
      grouped.putIfAbsent('Other', () => <Map<String, dynamic>>[]).add(item);
    }
  }

  return grouped;
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

String _formatDateRange(dynamic start, dynamic end) {
  final startLabel = _formatDateLong(start);
  final endLabel = _formatDateLong(end);

  if (startLabel == '-' && endLabel == '-') {
    return 'Date not set';
  }

  if (startLabel != '-' && endLabel != '-' && startLabel != endLabel) {
    return '$startLabel - $endLabel';
  }

  return startLabel != '-' ? startLabel : endLabel;
}

String _formatDateShort(dynamic raw) {
  if (raw == null) return 'Today';
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
    return raw.toString();
  }
}

String _formatDateLong(dynamic raw) {
  if (raw == null) return '-';
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

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
