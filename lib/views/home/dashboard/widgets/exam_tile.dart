import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/dashboard/helpers/dashboard_helpers.dart';

class ExamTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const ExamTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final subject = asDashboardMap(item['subject'])['name']?.toString() ?? 'Subject';
    final title = (item['title'] ?? 'Exam').toString();
    final status =
        asDashboardMap(item['attempt'])['status']?.toString() ?? 'not_started';
    final startDate = dashboardFormatIso(item['start_date']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.school_outlined, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subject, style: AppTextStyles.small),
                const SizedBox(height: 4),
                Text(
                  startDate == null
                      ? status.replaceAll('_', ' ')
                      : 'Starts $startDate',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
