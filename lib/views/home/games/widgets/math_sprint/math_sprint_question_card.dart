import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/models/math_sprint_question_model.dart';

class MathSprintQuestionCard extends StatelessWidget {
  final MathSprintQuestionModel question;
  final bool isPlaying;
  final String? feedbackMessage;
  final Color? feedbackColor;

  const MathSprintQuestionCard({
    super.key,
    required this.question,
    required this.isPlaying,
    required this.feedbackMessage,
    required this.feedbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final borderColor =
        feedbackColor?.withOpacity(0.2) ?? AppColors.surfaceMuted;

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Round ${question.round}',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isPlaying
                      ? const Color(0xFFE0F2FE)
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isPlaying ? 'Race mode' : 'Ready',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 11,
                    color: isPlaying
                        ? const Color(0xFF0369A1)
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 18),
          Text(
            question.prompt,
            style: AppTextStyles.headingLarge.copyWith(
              fontSize: compact ? 22 : 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            'The answer lanes below reshuffle every round.',
            style: AppTextStyles.subtitle.copyWith(fontSize: compact ? 12 : 14),
          ),
          if (feedbackMessage != null) ...[
            SizedBox(height: compact ? 12 : 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(compact ? 12 : 14),
              decoration: BoxDecoration(
                color: (feedbackColor ?? AppColors.primary).withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                feedbackMessage!,
                style: AppTextStyles.body.copyWith(
                  fontSize: compact ? 14 : 16,
                  color: feedbackColor ?? AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
