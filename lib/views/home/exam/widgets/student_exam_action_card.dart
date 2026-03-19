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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exam readiness',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'The timer starts from the recorded attempt start time. Leaving the CBT screen, minimizing the app, or entering split screen will submit the paper automatically.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              StudentExamHintPill(text: 'No screenshots'),
              StudentExamHintPill(text: 'No split screen'),
              StudentExamHintPill(text: 'Auto-submit on minimize'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isBusy ? null : onStart,
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
    );
  }
}
