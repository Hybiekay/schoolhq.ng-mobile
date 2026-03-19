import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const MobileTopActionBar(
              title: 'Games',
              subtitle:
                  'Step into the learning arcade for challenge rounds and bright revision energy.',
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            const SizedBox(height: 16),
            GamesHeroCard(role: role),
            const SizedBox(height: 20),
            Text('Daily Missions', style: AppTextStyles.headingMedium),
            const SizedBox(height: 10),
            ...gamesDailyMissions.map(
              (mission) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GameMissionTile(mission: mission),
              ),
            ),
            const SizedBox(height: 12),
            Text('Featured Modes', style: AppTextStyles.headingMedium),
            const SizedBox(height: 10),
            ...gamesFeaturedModes.map(
              (mode) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GameModeCard(mode: mode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
