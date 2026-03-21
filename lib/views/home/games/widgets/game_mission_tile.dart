import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class GameMissionTile extends StatelessWidget {
  final Map<String, dynamic> mission;

  const GameMissionTile({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final icon = mission['icon'] as IconData? ?? Icons.star_rounded;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceMuted),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 38 : 42,
            height: compact ? 38 : 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (mission['title'] ?? 'Mission').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (mission['value'] ?? '').toString(),
                  style: AppTextStyles.small.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
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
