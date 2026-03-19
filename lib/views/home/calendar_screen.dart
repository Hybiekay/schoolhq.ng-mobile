import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final calendar = ref.watch(mobileCalendarProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('School Calendar'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(mobileCalendarProvider),
          ),
        ],
      ),
      body: role != 'student'
          ? _StatusState(
              icon: Icons.lock_outline_rounded,
              title: 'Student calendar only',
              message:
                  'This screen is reserved for student accounts because the current mobile calendar feed is student-based.',
            )
          : calendar.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _StatusState(
                icon: Icons.event_busy_outlined,
                title: 'Unable to load calendar',
                message: error.toString(),
                onRetry: () => ref.invalidate(mobileCalendarProvider),
              ),
              data: (data) => _CalendarBody(
                data: data,
                onRefresh: () => ref.refresh(mobileCalendarProvider.future),
              ),
            ),
    );
  }
}

class _CalendarBody extends StatelessWidget {
  final Map<String, dynamic> data;
  final Future<void> Function() onRefresh;

  const _CalendarBody({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final student = _asMap(data['student']);
    final session = _asMap(data['session']);
    final term = _asMap(data['term']);
    final upcoming = _asList(data['upcoming']);
    final events = _asList(data['events']);
    final holidays = _asList(data['holidays']);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _SummaryCard(
            studentName: (student['full_name'] ?? 'Student').toString(),
            sessionName: session['name']?.toString(),
            termName: term['name']?.toString(),
            upcomingCount: upcoming.length,
            eventCount: events.length,
            holidayCount: holidays.length,
            onOpenTimetable: () => context.push(RouteNames.timetable),
          ),
          const SizedBox(height: 18),
          Text('Upcoming', style: AppTextStyles.headingMedium),
          const SizedBox(height: 10),
          if (upcoming.isEmpty)
            const _EmptyCard(
              message: 'No upcoming events or holidays have been scheduled.',
            )
          else
            ...upcoming.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CalendarTile(item: item),
              ),
            ),
          const SizedBox(height: 18),
          Text('Events', style: AppTextStyles.headingMedium),
          const SizedBox(height: 10),
          if (events.isEmpty)
            const _EmptyCard(message: 'No event items are available yet.')
          else
            ...events.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CalendarTile(item: item),
              ),
            ),
          const SizedBox(height: 18),
          Text('Holidays', style: AppTextStyles.headingMedium),
          const SizedBox(height: 10),
          if (holidays.isEmpty)
            const _EmptyCard(message: 'No holiday periods are available yet.')
          else
            ...holidays.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CalendarTile(item: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String studentName;
  final String? sessionName;
  final String? termName;
  final int upcomingCount;
  final int eventCount;
  final int holidayCount;
  final VoidCallback onOpenTimetable;

  const _SummaryCard({
    required this.studentName,
    required this.sessionName,
    required this.termName,
    required this.upcomingCount,
    required this.eventCount,
    required this.holidayCount,
    required this.onOpenTimetable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendar for $studentName',
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            [
              if ((sessionName ?? '').isNotEmpty) sessionName!,
              if ((termName ?? '').isNotEmpty) termName!,
            ].join(' | ').ifEmpty('School events and holidays'),
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.white.withOpacity(0.92),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CountPill(
                label: '$upcomingCount upcoming',
                color: Colors.white.withOpacity(0.16),
              ),
              _CountPill(
                label: '$eventCount events',
                color: Colors.white.withOpacity(0.16),
              ),
              _CountPill(
                label: '$holidayCount holidays',
                color: Colors.white.withOpacity(0.16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onOpenTimetable,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B5E20),
            ),
            icon: const Icon(Icons.view_week_outlined),
            label: const Text('Open Timetable'),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final String label;
  final Color color;

  const _CountPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CalendarTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _CalendarTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final type = (item['entry_type'] ?? 'event').toString().toLowerCase();
    final isHoliday = type == 'holiday';
    final title = (item['title'] ?? _titleCase(type)).toString();
    final description = item['description']?.toString();
    final location = item['location']?.toString();
    final color = isHoliday ? const Color(0xFF0F766E) : AppColors.primary;
    final background = isHoliday
        ? const Color(0xFFF0FDFA)
        : AppColors.primary.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isHoliday ? Icons.beach_access_outlined : Icons.event_outlined,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _titleCase(type),
                        style: AppTextStyles.small.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDateRange(item['start_date'], item['end_date']),
                  style: AppTextStyles.small.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((location ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    location!,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
                if ((description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(description!, style: AppTextStyles.subtitle),
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
