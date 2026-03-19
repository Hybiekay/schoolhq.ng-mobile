import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/dashboard/helpers/dashboard_helpers.dart';

class ChildTile extends StatelessWidget {
  final Map<String, dynamic> child;

  const ChildTile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final classMap = asDashboardMap(child['class']);
    final deptMap = asDashboardMap(child['department']);
    final status = (child['attendance_today'] ?? 'unknown').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            foregroundColor: AppColors.primary,
            child: Text(
              dashboardInitials((child['full_name'] ?? '').toString()),
              style: AppTextStyles.small.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (child['full_name'] ?? 'Student').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    classMap['name']?.toString(),
                    deptMap['name']?.toString(),
                  ].where((e) => e != null && e.isNotEmpty).join(' | '),
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status.toUpperCase(),
              style: AppTextStyles.small.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
