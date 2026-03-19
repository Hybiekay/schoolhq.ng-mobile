import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/exam/helpers/student_exam_helpers.dart';

class StudentExamAttemptHeader extends StatelessWidget {
  final Map<String, dynamic> attempt;
  final int currentIndex;
  final int totalQuestions;
  final int? remainingSeconds;
  final bool isWarning;

  const StudentExamAttemptHeader({
    super.key,
    required this.attempt,
    required this.currentIndex,
    required this.totalQuestions,
    required this.remainingSeconds,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    final exam = examAsMap(attempt['exam']);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (exam['title'] ?? 'CBT').toString(),
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            [
              examAsMap(exam['subject'])['name']?.toString(),
              examAsMap(exam['term'])['name']?.toString(),
            ].whereType<String>().where((item) => item.isNotEmpty).join(' | '),
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.white.withOpacity(0.92),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPill('Question ${currentIndex + 1}/$totalQuestions'),
              _buildPill(
                '${examIntValue(exam['duration_minutes'])} min duration',
              ),
              if (remainingSeconds != null)
                _buildPill(
                  'Time left ${examFormatTime(remainingSeconds!)}',
                  isWarning: isWarning,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String label, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFF7F1D1D).withOpacity(0.55)
            : Colors.white.withOpacity(0.16),
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
