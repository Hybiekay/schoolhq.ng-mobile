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
            'Attempt submitted',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'This CBT has already been submitted from this account.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 14),
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
            const SizedBox(height: 12),
            Text(
              'Submitted: ${examFormatIso(attempt['submitted_at']) ?? '-'}',
              style: AppTextStyles.small,
            ),
          ],
        ],
      ),
    );
  }
}
