import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class MathSprintScoreboard extends StatelessWidget {
  final int score;
  final int streak;
  final int bestStreak;
  final int timeLeft;

  const MathSprintScoreboard({
    super.key,
    required this.score,
    required this.streak,
    required this.bestStreak,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceMuted),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: compact ? 10 : 12,
        crossAxisSpacing: compact ? 10 : 12,
        childAspectRatio: compact ? 1.85 : 1.7,
        children: [
          _StatTile(
            icon: Icons.emoji_events_rounded,
            label: 'Score',
            value: '$score',
            accent: const Color(0xFF4F46E5),
          ),
          _StatTile(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '$streak',
            accent: const Color(0xFFEC4899),
          ),
          _StatTile(
            icon: Icons.trending_up_rounded,
            label: 'Best streak',
            value: '$bestStreak',
            accent: const Color(0xFF0EA5E9),
          ),
          _StatTile(
            icon: Icons.timer_rounded,
            label: 'Time left',
            value: '$timeLeft s',
            accent: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 38 : 42,
            height: compact ? 38 : 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTextStyles.small.copyWith(
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
