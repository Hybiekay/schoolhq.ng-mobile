import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class GameModeCard extends StatelessWidget {
  final Map<String, dynamic> mode;
  final VoidCallback? onTap;
  final bool highlighted;

  const GameModeCard({
    super.key,
    required this.mode,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final icon = mode['icon'] as IconData? ?? Icons.sports_esports_rounded;
    final gradient =
        mode['gradient'] as LinearGradient? ?? AppColors.accentGradient;
    final badge = (mode['badge'] ?? 'Mode').toString();
    final title = (mode['title'] ?? 'Game Mode').toString();
    final subtitle = (mode['subtitle'] ?? '').toString();
    final actionLabel =
        (mode['action'] ?? (onTap != null ? 'Open challenge' : 'Coming soon'))
            .toString();
    final isPlayable = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: highlighted
                  ? const Color(0xFFCBD5E1)
                  : AppColors.surfaceMuted,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(highlighted ? 0.08 : 0.05),
                blurRadius: highlighted ? 28 : 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: compact ? -18 : -24,
                top: compact ? -18 : -24,
                child: Container(
                  width: compact ? 84 : 108,
                  height: compact ? 84 : 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: gradient,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(compact ? 16 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: compact ? 48 : 54,
                              height: compact ? 48 : 54,
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
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
                                color: isPlayable
                                    ? const Color(0xFFE0F2FE)
                                    : AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                badge,
                                style: AppTextStyles.small.copyWith(
                                  color: isPlayable
                                      ? const Color(0xFF0369A1)
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 12 : 16),
                        Text(
                          title,
                          style: AppTextStyles.headingMedium.copyWith(
                            fontSize: compact ? 18 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: compact ? 6 : 8),
                        Text(
                          subtitle,
                          style: AppTextStyles.small.copyWith(
                            fontSize: compact ? 11 : 12,
                            color: AppColors.textSecondary,
                            height: 1.55,
                          ),
                        ),
                        SizedBox(height: compact ? 12 : 16),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: compact ? 11 : 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: isPlayable ? gradient : null,
                            color: isPlayable ? null : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                actionLabel,
                                style: AppTextStyles.button.copyWith(
                                  fontSize: compact ? 14 : 16,
                                  color: isPlayable
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (isPlayable) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
