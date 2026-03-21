import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class MathSprintSummaryCard extends StatelessWidget {
  final int score;
  final int correct;
  final int attempted;
  final int accuracy;
  final int bestStreak;
  final VoidCallback onRestart;
  final VoidCallback onBackToGames;

  const MathSprintSummaryCard({
    super.key,
    required this.score,
    required this.correct,
    required this.attempted,
    required this.accuracy,
    required this.bestStreak,
    required this.onRestart,
    required this.onBackToGames,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1E3A8A), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Sprint complete',
                    style: AppTextStyles.small.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 10 : 14),
                Text(
                  'Great pace. Keep the streak going.',
                  style: AppTextStyles.headingLarge.copyWith(
                    fontSize: compact ? 22 : 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: compact ? 6 : 8),
                Text(
                  'Your last run is locked in below. Restart to chase a higher score or smoother accuracy.',
                  style: AppTextStyles.body.copyWith(
                    fontSize: compact ? 13 : 16,
                    color: Colors.white.withOpacity(0.82),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: compact ? 14 : 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SummaryChip(label: 'Score', value: '$score'),
                    _SummaryChip(label: 'Correct', value: '$correct'),
                    _SummaryChip(label: 'Attempts', value: '$attempted'),
                    _SummaryChip(label: 'Accuracy', value: '$accuracy%'),
                    _SummaryChip(label: 'Best streak', value: '$bestStreak'),
                  ],
                ),
                SizedBox(height: compact ? 14 : 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onRestart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: compact ? 12 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          'Play again',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: compact ? 10 : 12),
                    Expanded(
                      child: TextButton(
                        onPressed: onBackToGames,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: compact ? 12 : 14,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                        ),
                        child: Text(
                          'Back to games',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontSize: 11,
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
