import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class GamesHeroCard extends StatelessWidget {
  final String role;
  final VoidCallback onPlayMathSprint;
  final VoidCallback? onPlayWordBuilder;

  const GamesHeroCard({
    super.key,
    required this.role,
    required this.onPlayMathSprint,
    this.onPlayWordBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final copy = role == 'teacher'
        ? 'Launch quick arithmetic bursts and word-building runs before class, revision breaks, or team challenges.'
        : 'Jump into fast number games and vocabulary runs, then keep your streak sharp.';

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF4F46E5), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Container(
              width: compact ? 92 : 116,
              height: compact ? 92 : 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: -14,
            bottom: -18,
            child: Container(
              width: compact ? 76 : 92,
              height: compact ? 76 : 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
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
                children: const [
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
                    label: 'Badge boosts',
                  ),
                ],
              ),
              SizedBox(height: compact ? 14 : 18),
              if (onPlayWordBuilder == null)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPlayMathSprint,
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
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          'Play Math Sprint',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else if (compact)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onPlayMathSprint,
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
                        icon: const Icon(Icons.calculate_rounded),
                        label: Text(
                          'Play Math Sprint',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: onPlayWordBuilder,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.12),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: compact ? 12 : 14,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.spellcheck_rounded),
                        label: Text(
                          'Play Word Builder',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPlayMathSprint,
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
                        icon: const Icon(Icons.calculate_rounded),
                        label: Text(
                          'Play Math Sprint',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onPlayWordBuilder,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.12),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: compact ? 12 : 14,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.spellcheck_rounded),
                        label: Text(
                          'Play Word Builder',
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
