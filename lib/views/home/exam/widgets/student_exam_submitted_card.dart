import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/exam/helpers/student_exam_helpers.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_hint_pill.dart';

class StudentExamSubmittedCard extends StatelessWidget {
  final Map<String, dynamic> exam;
  final Map<String, dynamic> attempt;

  const StudentExamSubmittedCard({
    super.key,
    required this.exam,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    final score = examDoubleValue(attempt['score']);
    final passing = examIntValue(exam['passing_percentage']);
    final totalPoints = examIntValue(exam['total_points']);
    final percentage = totalPoints > 0 ? (score / totalPoints) * 100 : null;
    final passed = percentage != null && percentage >= passing;
    final accent = passed ? AppColors.success : AppColors.secondary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    passed ? Icons.verified_rounded : Icons.assignment_turned_in,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attempt submitted',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This CBT has already been submitted from this account.',
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StudentExamHintPill(
                  text: 'Score: ${score.toStringAsFixed(0)} / $totalPoints',
                ),
                if (percentage != null)
                  StudentExamHintPill(
                    text: 'Percentage: ${percentage.toStringAsFixed(0)}%',
                  ),
                StudentExamHintPill(
                  text: passed ? 'Status: Passed' : 'Status: Failed',
                ),
              ],
            ),
            if ((attempt['submitted_at'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Submitted: ${examFormatIso(attempt['submitted_at']) ?? '-'}',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
