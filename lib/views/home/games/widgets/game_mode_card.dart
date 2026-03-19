import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class GameModeCard extends StatelessWidget {
  final Map<String, dynamic> mode;

  const GameModeCard({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final icon = mode['icon'] as IconData? ?? Icons.sports_esports_rounded;
    final gradient = mode['gradient'] as LinearGradient? ??
        AppColors.accentGradient;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const Spacer(),
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
                  (mode['badge'] ?? 'Mode').toString(),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            (mode['title'] ?? 'Game Mode').toString(),
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            (mode['subtitle'] ?? '').toString(),
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              'Open Challenge',
              style: AppTextStyles.button,
            ),
          ),
        ],
      ),
    );
  }
}
