import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/exams/helpers/exams_screen_helpers.dart';

class ExamListCard extends StatelessWidget {
  final Map<String, dynamic> exam;
  final String role;
  final Future<void> Function()? onOpen;

  const ExamListCard({
    super.key,
    required this.exam,
    required this.role,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final subject =
        examsAsMap(exam['subject'])['name']?.toString() ??
        (exam['subject']?.toString() ?? 'Subject');
    final className =
        examsAsMap(exam['class'])['name']?.toString() ??
        (exam['class']?.toString() ?? '');
    final attempt = examsAsMap(exam['attempt']);
    final status = (attempt['status'] ?? exam['status'] ?? 'available')
        .toString();
    final score = attempt['score'];
    final start = examsFormatIso(exam['start_date']);
    final end = examsFormatIso(exam['end_date']);
    final statusColor = examsStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusColor.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withOpacity(0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white),
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
                    const SizedBox(height: 4),
                    Text(
                      [
                        subject,
                        className,
                      ].where((e) => e.isNotEmpty).join(' | '),
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  examsStatusLabel(status),
                  style: AppTextStyles.small.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(
                'Type ${(exam['exam_type'] ?? '-').toString().replaceAll('_', ' ')}',
              ),
              if (start != null) _pill('Start $start'),
              if (end != null) _pill('End $end'),
              if (role == 'student' && score != null)
                _pill('Score ${score.toString()}'),
            ],
          ),
          if (role == 'student' && onOpen != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpen,
                style: FilledButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(
                  status == 'in_progress'
                      ? Icons.play_arrow_rounded
                      : status == 'submitted'
                      ? Icons.visibility_rounded
                      : Icons.rocket_launch_rounded,
                ),
                label: Text(
                  status == 'in_progress'
                      ? 'Continue CBT'
                      : status == 'submitted'
                      ? 'View CBT'
                      : 'Open CBT',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(String text) {
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
