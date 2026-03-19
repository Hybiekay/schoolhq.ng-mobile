import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/dashboard/helpers/dashboard_helpers.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/child_tile.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/dashboard_hero_card.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/dashboard_stats_grid.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/empty_tile.dart';

class ParentDashboardBody extends StatelessWidget {
  final Map<String, dynamic> data;

  const ParentDashboardBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final parent = asDashboardMap(data['parent']);
    final counts = asDashboardMap(data['counts']);
    final children = asDashboardList(data['children']);
    final name = (parent['full_name'] ?? 'Parent').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardHeroCard(
          title: 'Hello, ${dashboardFirstWord(name)}',
          subtitle: 'Track your children, balances, and school updates from one place.',
          pills: [
            '${dashboardIntValue(counts['children'])} children',
            'Balance ${dashboardMoney(counts['total_fee_balance'])}',
          ],
          icon: Icons.family_restroom_rounded,
          gradient: AppColors.accentGradient,
        ),
        const SizedBox(height: 20),
        Text('Overview', style: AppTextStyles.headingMedium),
        const SizedBox(height: 10),
        DashboardStatsGrid(
          items: [
            DashboardStatItem(
              title: 'Children',
              value: '${dashboardIntValue(counts['children'])}',
              icon: Icons.family_restroom_outlined,
              accent: AppColors.primary,
            ),
            DashboardStatItem(
              title: 'Open Fee Items',
              value: '${dashboardIntValue(counts['outstanding_fee_items'])}',
              icon: Icons.receipt_long_outlined,
              accent: AppColors.secondary,
            ),
            DashboardStatItem(
              title: 'Fee Balance',
              value: dashboardMoney(counts['total_fee_balance']),
              icon: Icons.account_balance_wallet_outlined,
              accent: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Children', style: AppTextStyles.headingMedium),
        const SizedBox(height: 10),
        if (children.isEmpty)
          const EmptyTile(
            message: 'No children linked to this parent account yet.',
          )
        else
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ChildTile(child: child),
            ),
          ),
      ],
    );
  }
}
