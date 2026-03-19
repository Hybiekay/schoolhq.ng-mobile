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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFlagged
              ? const Color(0xFFF59E0B)
              : AppColors.primary.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Question ${index + 1} of $total',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: onToggleFlag,
                icon: Icon(
                  isFlagged ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFlagged ? const Color(0xFFF59E0B) : AppColors.grey,
                ),
                tooltip: isFlagged ? 'Unflag question' : 'Flag question',
              ),
            ],
          ),
          if (isFlagged)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
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
            ),
          Text(
            examPlainText(question['question_text']?.toString() ?? 'Question'),
            style: AppTextStyles.body.copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StudentExamAnswerOption(
                label: examPlainText(option['option_text']?.toString() ?? ''),
                value: option['option_text']?.toString() ?? '',
                selected: answer == (option['option_text']?.toString() ?? ''),
                onTap: () =>
                    onAnswerChanged(option['option_text']?.toString() ?? ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
