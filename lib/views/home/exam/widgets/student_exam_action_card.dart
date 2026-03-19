import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_hint_pill.dart';

class StudentExamActionCard extends StatelessWidget {
  final Map<String, dynamic> attempt;
  final bool isBusy;
  final Future<void> Function() onStart;

  const StudentExamActionCard({
    super.key,
    required this.attempt,
    required this.isBusy,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final hasAttempt = attempt.isNotEmpty;
    final isInProgress = attempt['status']?.toString() == 'in_progress';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
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
                    gradient: AppColors.coolGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exam readiness',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isInProgress
                            ? 'Your attempt is live. Open it and continue from the latest backend state.'
                            : 'Review the rules below before you begin the CBT.',
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'The timer starts from the recorded attempt start time. Leaving the CBT screen, minimizing the app, or entering split screen will submit the paper automatically.',
                style: AppTextStyles.subtitle,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                StudentExamHintPill(text: 'No screenshots'),
                StudentExamHintPill(text: 'No split screen'),
                StudentExamHintPill(text: 'Auto-submit on minimize'),
                StudentExamHintPill(text: 'Pull down to sync'),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isBusy ? null : onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: Icon(
                  isInProgress ? Icons.play_arrow_rounded : Icons.rocket_launch,
                ),
                label: Text(
                  isBusy
                      ? 'Opening CBT...'
                      : hasAttempt && isInProgress
                      ? 'Continue CBT'
                      : 'Start CBT',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
