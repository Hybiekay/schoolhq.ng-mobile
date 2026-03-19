import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class DashboardStatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const DashboardStatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });
}

class DashboardStatsGrid extends StatelessWidget {
  final List<DashboardStatItem> items;

  const DashboardStatsGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: item.accent.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: item.accent.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, size: 18, color: item.accent),
                ),
                const Spacer(),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: item.accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
