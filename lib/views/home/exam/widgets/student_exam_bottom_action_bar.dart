import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class StudentExamBottomActionBar extends StatelessWidget {
  final bool canGoBack;
  final bool isSaving;
  final bool isSubmitting;
  final bool isLastQuestion;
  final bool hasSelection;
  final VoidCallback onPrevious;
  final Future<void> Function() onNext;
  final Future<void> Function() onFinish;

  const StudentExamBottomActionBar({
    super.key,
    required this.canGoBack,
    required this.isSaving,
    required this.isSubmitting,
    required this.isLastQuestion,
    required this.hasSelection,
    required this.onPrevious,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final canContinue = hasSelection && !isSaving && !isSubmitting;
    final primaryLabel = isSubmitting
        ? 'Submitting...'
        : isSaving
        ? 'Saving...'
        : isLastQuestion
        ? 'Submit CBT'
        : 'Next Question';
    final statusColor = isSubmitting
        ? AppColors.primaryDark
        : isSaving
        ? AppColors.accent
        : hasSelection
        ? AppColors.success
        : AppColors.warning;
    final statusLabel = isSubmitting
        ? 'Sending answers to the server'
        : isSaving
        ? 'Saving your answer'
        : hasSelection
        ? 'Answer selected and ready'
        : 'Select an answer to continue';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.primary.withOpacity(0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, size: 18, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusLabel,
                    style: AppTextStyles.small.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  onPressed: canGoBack && !isSubmitting ? onPrevious : null,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    foregroundColor: AppColors.primaryDark,
                    side: BorderSide(
                      color: canGoBack
                          ? AppColors.primary.withOpacity(0.22)
                          : AppColors.grey.withOpacity(0.6),
                    ),
                    backgroundColor: canGoBack
                        ? AppColors.primary.withOpacity(0.04)
                        : AppColors.surfaceMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 7,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    gradient: canContinue
                        ? AppColors.accentGradient
                        : const LinearGradient(
                            colors: [Color(0xFFD1D5DB), Color(0xFF9CA3AF)],
                          ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: canContinue
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.18),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: !canContinue
                        ? null
                        : () => isLastQuestion ? onFinish() : onNext(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: Icon(
                      isLastQuestion
                          ? Icons.task_alt_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        primaryLabel,
                        key: ValueKey(primaryLabel),
                        style: AppTextStyles.button.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
