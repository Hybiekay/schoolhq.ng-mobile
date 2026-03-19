import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final examsAsync = ref.watch(mobileExamsProvider);
    final childrenAsync = role == 'parent'
        ? ref.watch(parentChildrenProvider)
        : const AsyncValue<List<Map<String, dynamic>>>.data([]);
    final selectedChildId = ref.watch(parentSelectedChildIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(role == 'parent' ? 'Children Exams' : 'My Exams'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(mobileExamsProvider);
              if (role == 'parent') ref.invalidate(parentChildrenProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(mobileExamsProvider);
          if (role == 'parent') ref.invalidate(parentChildrenProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            if (role == 'parent') ...[
              childrenAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (e, _) =>
                    _ErrorCard(message: 'Failed to load children: $e'),
                data: (children) => _ParentChildSelector(
                  children: children,
                  selectedChildId: selectedChildId,
                  onSelected: (id) {
                    ref.read(parentSelectedChildIdProvider.notifier).set(id);
                    ref.invalidate(mobileExamsProvider);
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],
            examsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => _ErrorCard(message: error.toString()),
              data: (data) {
                final exams = _extractExams(data);
                final child = _asMap(data['child']);
                final heading = role == 'parent' && child.isNotEmpty
                    ? 'Showing exams for ${child['full_name'] ?? 'child'}'
                    : role == 'student'
                    ? 'Available exams and attempt status'
                    : 'Select a child to view exams';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(heading, style: AppTextStyles.subtitle),
                    const SizedBox(height: 10),
                    if (exams.isEmpty)
                      const _EmptyCard(message: 'No exams available right now.')
                    else
                      ...exams.map(
                        (exam) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ExamCard(exam: exam, role: role),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentChildSelector extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final String? selectedChildId;
  final ValueChanged<String> onSelected;

  const _ParentChildSelector({
    required this.children,
    required this.selectedChildId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const _EmptyCard(
        message: 'No children linked to this parent account yet.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Child',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children.map((child) {
            final id = (child['id'] ?? '').toString();
            final selected =
                id == selectedChildId ||
                (selectedChildId == null && children.first == child);
            final label = (child['full_name'] ?? 'Student').toString();
            return ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => onSelected(id),
              selectedColor: AppColors.primary.withOpacity(0.15),
              labelStyle: AppTextStyles.small.copyWith(
                color: selected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: selected
                    ? AppColors.primary
                    : AppColors.grey.withOpacity(0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Map<String, dynamic> exam;
  final String role;

  const _ExamCard({required this.exam, required this.role});

  @override
  Widget build(BuildContext context) {
    final subject =
        _asMap(exam['subject'])['name']?.toString() ??
        (exam['subject']?.toString() ?? 'Subject');
    final className =
        _asMap(exam['class'])['name']?.toString() ??
        (exam['class']?.toString() ?? '');
    final attempt = _asMap(exam['attempt']);
    final status = (attempt['status'] ?? exam['status'] ?? 'available')
        .toString();
    final score = attempt['score'];
    final start = _formatIso(exam['start_date']);
    final end = _formatIso(exam['end_date']);

    return Container(
      padding: const EdgeInsets.all(16),
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (exam['title'] ?? 'Exam').toString(),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        subject,
                        className,
                      ].where((e) => e.isNotEmpty).join(' • '),
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                text:
                    'Type: ${(exam['exam_type'] ?? '-').toString().replaceAll('_', ' ')}',
              ),
              if (start != null) _Pill(text: 'Start: $start'),
              if (end != null) _Pill(text: 'End: $end'),
              if (role == 'student' && score != null)
                _Pill(text: 'Score: ${score.toString()}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'submitted' => const Color(0xFF16A34A),
      'in_progress' => const Color(0xFF2563EB),
      'draft' => const Color(0xFFF59E0B),
      _ => AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized.replaceAll('_', ' ').toUpperCase(),
        style: AppTextStyles.small.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: AppTextStyles.small),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Text(
        message,
        style: AppTextStyles.subtitle.copyWith(color: AppColors.error),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, style: AppTextStyles.subtitle),
    );
  }
}

List<Map<String, dynamic>> _extractExams(Map<String, dynamic> data) {
  final candidate = data['data'] ?? data['exams'];
  if (candidate is! List) return const [];
  return candidate
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
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
    final hh = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month ${dt.day}, $hh:$mm $ampm';
  } catch (_) {
    return null;
  }
}
