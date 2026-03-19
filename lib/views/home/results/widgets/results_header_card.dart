import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class ResultsHeaderCard extends StatelessWidget {
  final String role;
  final String? selectedChildName;

  const ResultsHeaderCard({
    super.key,
    required this.role,
    this.selectedChildName,
  });

  @override
  Widget build(BuildContext context) {
    final isParent = role == 'parent';

    return Container(
      decoration: BoxDecoration(
        gradient: isParent ? AppColors.accentGradient : AppColors.brandGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: (isParent ? AppColors.secondary : AppColors.primary)
                .withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -12,
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.assessment_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isParent ? 'Results Overview' : 'Academic Results',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isParent
                      ? selectedChildName == null || selectedChildName!.isEmpty
                            ? 'Select a child to review term scores and session performance.'
                            : 'Viewing result performance for $selectedChildName.'
                      : 'Track your published term scores and full session summary in one place.',
                  style: AppTextStyles.subtitle.copyWith(
                    color: Colors.white.withOpacity(0.92),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
