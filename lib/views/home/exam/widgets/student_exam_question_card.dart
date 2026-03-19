import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/exam/helpers/student_exam_helpers.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_answer_option.dart';

class StudentExamQuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;
  final String answer;
  final bool isFlagged;
  final int index;
  final int total;
  final ValueChanged<String> onAnswerChanged;
  final VoidCallback onToggleFlag;

  const StudentExamQuestionCard({
    super.key,
    required this.question,
    required this.answer,
    required this.isFlagged,
    required this.index,
    required this.total,
    required this.onAnswerChanged,
    required this.onToggleFlag,
  });

  @override
  Widget build(BuildContext context) {
    final options = examAsList(question['options']);
    final progress = total <= 0 ? 0.0 : (index + 1) / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFlagged
              ? AppColors.warning
              : AppColors.primary.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${index + 1} of $total',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceMuted,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onToggleFlag,
                icon: Icon(
                  isFlagged ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFlagged
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
                tooltip: isFlagged ? 'Unflag question' : 'Flag question',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Read carefully and choose one answer.',
              style: AppTextStyles.small.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (isFlagged) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Flagged for review',
                style: AppTextStyles.small.copyWith(
                  color: const Color(0xFFB45309),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            examPlainText(question['question_text']?.toString() ?? 'Question'),
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...options.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StudentExamAnswerOption(
                indexLabel: String.fromCharCode(65 + entry.key),
                label: examPlainText(
                  entry.value['option_text']?.toString() ?? '',
                ),
                value: entry.value['option_text']?.toString() ?? '',
                selected:
                    answer == (entry.value['option_text']?.toString() ?? ''),
                onTap: () => onAnswerChanged(
                  entry.value['option_text']?.toString() ?? '',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
