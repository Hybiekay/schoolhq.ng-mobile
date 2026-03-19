import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/dashboard/helpers/dashboard_helpers.dart';

class TimetableTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const TimetableTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final subject = asDashboardMap(item['subject'])['name']?.toString();
    final teacher = asDashboardMap(item['teacher'])['name']?.toString();
    final location = item['location']?.toString();
    final className = asDashboardMap(item['class'])['name']?.toString();
    final lines = [
      if (subject != null && subject.isNotEmpty) subject,
      if (teacher != null && teacher.isNotEmpty) teacher,
      if (className != null && className.isNotEmpty) className,
      if (location != null && location.isNotEmpty) location,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.schedule, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['title'] ?? 'Lesson').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dashboardFormatTimeRange(item['starts_at'], item['ends_at']),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (lines.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(lines.join(' | '), style: AppTextStyles.small),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
