import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class StudentExamQuestionStrip extends StatelessWidget {
  final int total;
  final int currentIndex;
  final Map<String, String> answers;
  final Set<String> flagged;
  final List<Map<String, dynamic>> questions;
  final ValueChanged<int> onSelected;

  const StudentExamQuestionStrip({
    super.key,
    required this.total,
    required this.currentIndex,
    required this.answers,
    required this.flagged,
    required this.questions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question navigator',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap any number to jump quickly between questions.',
            style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(total, (index) {
              final id = questions[index]['id']?.toString() ?? '';
              final answered = (answers[id] ?? '').trim().isNotEmpty;
              final isFlagged = flagged.contains(id);
              final isCurrent = index == currentIndex;

              return InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primaryDark
                        : answered
                        ? AppColors.accent.withOpacity(0.14)
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFlagged
                          ? AppColors.warning
                          : isCurrent
                          ? AppColors.primaryDark
                          : AppColors.grey.withOpacity(0.4),
                      width: isCurrent ? 1.4 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.small.copyWith(
                        color: isCurrent
                            ? Colors.white
                            : answered
                            ? AppColors.accent
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
