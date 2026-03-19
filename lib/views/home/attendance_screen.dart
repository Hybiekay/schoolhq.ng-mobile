import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final attendance = ref.watch(mobileAttendanceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(role == 'parent' ? 'Child Attendance' : 'Attendance'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(mobileAttendanceProvider),
          ),
        ],
      ),
      body: attendance.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load attendance\n$error',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
          ),
        ),
        data: (data) {
          final summary = _asMap(data['summary']);
          final records = _asList(data['records']);
          final subjectEntity = role == 'parent'
              ? _asMap(data['child'])
              : _asMap(data['student']);
          final title = (subjectEntity['full_name'] ?? 'Attendance').toString();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(mobileAttendanceProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _SummaryCard(
                  title: title,
                  present: _intValue(summary['present']),
                  absent: _intValue(summary['absent']),
                  late: _intValue(summary['late']),
                  total: _intValue(summary['total']),
                ),
                const SizedBox(height: 14),
                Text('Recent Records', style: AppTextStyles.headingMedium),
                const SizedBox(height: 10),
                if (records.isEmpty)
                  const _EmptyCard(message: 'No attendance records found.')
                else
                  ...records.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AttendanceTile(record: record),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int present;
  final int absent;
  final int late;
  final int total;

  const _SummaryCard({
    required this.title,
    required this.present,
    required this.absent,
    required this.late,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text('Attendance summary', style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniStat(
                label: 'Present',
                value: '$present',
                color: const Color(0xFF16A34A),
              ),
              _MiniStat(
                label: 'Absent',
                value: '$absent',
                color: const Color(0xFFDC2626),
              ),
              _MiniStat(
                label: 'Late',
                value: '$late',
                color: const Color(0xFFD97706),
              ),
              _MiniStat(
                label: 'Total',
                value: '$total',
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: AppTextStyles.small.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final Map<String, dynamic> record;

  const _AttendanceTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final status = (record['status'] ?? 'unknown').toString().toLowerCase();
    final color = switch (status) {
      'present' => const Color(0xFF16A34A),
      'late' => const Color(0xFFD97706),
      'absent' => const Color(0xFFDC2626),
      _ => AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _formatDate(record['date']),
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            status.toUpperCase(),
            style: AppTextStyles.small.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
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

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> _asList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? 0}') ?? 0;
}

String _formatDate(dynamic raw) {
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
