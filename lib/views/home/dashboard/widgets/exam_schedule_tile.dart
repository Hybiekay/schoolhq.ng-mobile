import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/dashboard/helpers/dashboard_helpers.dart';

class ExamScheduleTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const ExamScheduleTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final subject = asDashboardMap(item['subject'])['name']?.toString();
    final location = item['location']?.toString();
    final date = dashboardFormatIsoDate(item['start_date']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE11D48).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_note_outlined,
              color: Color(0xFFE11D48),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['title'] ?? 'Exam').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (date != null) date,
                    dashboardFormatTimeRange(item['starts_at'], item['ends_at']),
                  ].join(' | '),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((subject ?? '').isNotEmpty || (location ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      [
                        if ((subject ?? '').isNotEmpty) subject!,
                        if ((location ?? '').isNotEmpty) location!,
                      ].join(' | '),
                      style: AppTextStyles.small,
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
