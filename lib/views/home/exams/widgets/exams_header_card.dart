import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class ExamsHeaderCard extends StatelessWidget {
  final String role;

  const ExamsHeaderCard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isParent = role == 'parent';

    return Container(
      decoration: BoxDecoration(
        gradient: isParent ? AppColors.accentGradient : AppColors.coolGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: (isParent ? AppColors.secondary : AppColors.accent)
                .withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -16,
            child: Container(
              width: 110,
              height: 110,
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
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  isParent ? 'Exam Center' : 'My Exam Hub',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isParent
                      ? 'Check each child, refresh from backend, and follow live exam status.'
                      : 'Pull down anytime to sync your latest exam status directly from backend.',
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
