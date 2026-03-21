import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/views/home/games/helpers/games_catalog.dart';
import 'package:schoolhq_ng/views/home/games/widgets/game_mission_tile.dart';
import 'package:schoolhq_ng/views/home/games/widgets/game_mode_card.dart';
import 'package:schoolhq_ng/views/home/games/widgets/games_hero_card.dart';
import 'package:schoolhq_ng/views/home/shared/widgets/mobile_top_action_bar.dart';

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          Positioned(
            top: -36,
            right: -32,
            child: _AmbientGlow(
              size: 140,
              colors: const [Color(0xFF818CF8), Color(0xFF22D3EE)],
            ),
          ),
          Positioned(
            left: -40,
            top: 220,
            child: _AmbientGlow(
              size: 124,
              colors: const [Color(0xFFEC4899), Color(0xFFF472B6)],
            ),
          ),
          SafeArea(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const MobileTopActionBar(
                  title: 'Games',
                  subtitle:
                      'Step into the learning arcade for challenge rounds and bright revision energy.',
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1D4ED8),
                      Color(0xFF06B6D4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                const SizedBox(height: 12),
                GamesHeroCard(
                  role: role,
                  onPlayMathSprint: () => context.push(RouteNames.mathSprint),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
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
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.calculate_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Math Sprint is live',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap the first featured mode to launch a fast arithmetic burst.',
                              style: AppTextStyles.small.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Daily Missions', style: AppTextStyles.headingMedium),
                const SizedBox(height: 6),
                Text(
                  'Small bursts that keep the learning rhythm alive throughout the day.',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 12),
                ...gamesDailyMissions.map(
                  (mission) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GameMissionTile(mission: mission),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Featured Modes', style: AppTextStyles.headingMedium),
                const SizedBox(height: 6),
                Text(
                  'Math Sprint is ready now. The rest of the arcade is being unlocked next.',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 12),
                ...gamesFeaturedModes.map((mode) {
                  final route = mode['route'] as String?;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GameModeCard(
                      mode: mode,
                      highlighted: route != null,
                      onTap: route == null ? null : () => context.push(route),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _AmbientGlow({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors.map((color) => color.withOpacity(0.20)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
