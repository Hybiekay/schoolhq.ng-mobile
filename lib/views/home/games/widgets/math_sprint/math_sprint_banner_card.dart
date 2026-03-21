import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class MathSprintBannerCard extends StatelessWidget {
  final String role;
  final bool isPlaying;
  final bool isFinished;
  final int round;
  final int timeLeft;
  final VoidCallback onStart;
  final VoidCallback onRestart;

  const MathSprintBannerCard({
    super.key,
    required this.role,
    required this.isPlaying,
    required this.isFinished,
    required this.round,
    required this.timeLeft,
    required this.onStart,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final copy = role == 'teacher'
        ? 'Use this as a quick warm-up before class or a fast revision burst between lessons.'
        : 'Beat the clock, stack streaks, and keep your accuracy sharp for each round.';

    final actionLabel = isPlaying
        ? 'Restart sprint'
        : isFinished
        ? 'Play again'
        : 'Start sprint';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF4F46E5), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -26,
            right: -26,
            child: _GlowDot(size: 120, opacity: 0.12),
          ),
          Positioned(
            left: -18,
            bottom: -18,
            child: _GlowDot(size: 88, opacity: 0.08),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 16 : 20),
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
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isFinished
                            ? 'Sprint complete'
                            : isPlaying
                            ? 'Sprint active'
                            : 'Ready to launch',
                        style: AppTextStyles.small.copyWith(
                          color: Colors.white,
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
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${timeLeft}s left',
                        style: AppTextStyles.small.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 10 : 14),
                Text(
                  'Math Sprint',
                  style: AppTextStyles.headingLarge.copyWith(
                    fontSize: compact ? 22 : 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: compact ? 6 : 8),
                Text(
                  copy,
                  style: AppTextStyles.body.copyWith(
                    fontSize: compact ? 13 : 16,
                    color: Colors.white.withOpacity(0.84),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: compact ? 12 : 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _HeroChip(
                      icon: Icons.timer_rounded,
                      label: '60 second bursts',
                    ),
                    _HeroChip(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Streak rewards',
                    ),
                    _HeroChip(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Fast scoring',
                    ),
                  ],
                ),
                SizedBox(height: compact ? 14 : 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isPlaying ? onRestart : onStart,
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
                        icon: Icon(
                          isPlaying
                              ? Icons.refresh_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          actionLabel,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (isPlaying) ...[
                      SizedBox(width: compact ? 10 : 12),
                      TextButton(
                        onPressed: onRestart,
                        child: Text(
                          'Reset',
                          style: AppTextStyles.body.copyWith(
                            fontSize: compact ? 14 : 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isPlaying) ...[
                  SizedBox(height: compact ? 8 : 10),
                  Text(
                    'Round $round is underway. Keep the rhythm and answer fast.',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.75),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowDot extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlowDot({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
