import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class GamesHeroCard extends StatelessWidget {
  final String role;

  const GamesHeroCard({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final copy = role == 'teacher'
        ? 'A playful learning hub for warm-ups, revision rounds, and class energy.'
        : 'A colorful learning arcade for quick challenges, revision streaks, and fun practice.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Learning Arcade',
              style: AppTextStyles.small.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Play. Practice. Progress.',
            style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            copy,
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withOpacity(0.82),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
