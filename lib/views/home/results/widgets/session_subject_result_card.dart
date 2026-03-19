import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/results/helpers/results_helpers.dart';

class SessionSubjectResultCard extends StatelessWidget {
  final Map<String, dynamic> row;

  const SessionSubjectResultCard({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    final terms = resultsAsMap(row['terms']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (row['subject_name'] ?? 'Subject').toString(),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...terms.entries.map((entry) {
            final score = resultsAsMap(entry.value);
            final unpublished = entry.value == null || score.isEmpty;
            final total = unpublished
                ? '-'
                : resultsNum(score['total']).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key, style: AppTextStyles.small)),
                  Text(
                    unpublished ? 'Not published' : 'Total $total',
                    style: AppTextStyles.small.copyWith(
                      color: unpublished
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
