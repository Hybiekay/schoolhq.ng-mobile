import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/models/math_sprint_question_model.dart';

class MathSprintChoiceGrid extends StatelessWidget {
  final MathSprintQuestionModel question;
  final bool isPlaying;
  final int? selectedChoice;
  final ValueChanged<int> onChoiceSelected;

  const MathSprintChoiceGrid({
    super.key,
    required this.question,
    required this.isPlaying,
    required this.selectedChoice,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: compact ? 10 : 12,
      crossAxisSpacing: compact ? 10 : 12,
      childAspectRatio: compact ? 1.85 : 1.55,
      children: question.choices.map((choice) {
        final isCorrectChoice = choice == question.answer;
        final isSelected = choice == selectedChoice;
        final isAnswered = selectedChoice != null;

        Color borderColor = AppColors.surfaceMuted;
        Color backgroundColor = AppColors.white;
        Color textColor = AppColors.textPrimary;
        List<BoxShadow> shadows = [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ];

        if (!isPlaying) {
          backgroundColor = const Color(0xFFF8FAFC);
          textColor = AppColors.grey;
        } else if (isAnswered && isCorrectChoice) {
          borderColor = const Color(0xFF86EFAC);
          backgroundColor = const Color(0xFFF0FDF4);
          textColor = const Color(0xFF15803D);
          shadows = [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ];
        } else if (isAnswered && isSelected) {
          borderColor = const Color(0xFFFCA5A5);
          backgroundColor = const Color(0xFFFFF1F2);
          textColor = const Color(0xFFB91C1C);
          shadows = [
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ];
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: isPlaying && !isAnswered
                ? () => onChoiceSelected(choice)
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
                boxShadow: shadows,
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$choice',
                    style: AppTextStyles.headingLarge.copyWith(
                      fontSize: compact ? 22 : 24,
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: compact ? 2 : 4),
                  Text(
                    isPlaying ? 'Tap to answer' : 'Ready to start',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 11,
                      color: textColor.withOpacity(0.72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
