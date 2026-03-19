import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/results/helpers/results_helpers.dart';

class ResultScoreRow extends StatelessWidget {
  final Map<String, dynamic> score;

  const ResultScoreRow({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final total = resultsNum(score['total']);
    final ca = resultsNum(score['welcome']) + resultsNum(score['mid']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (score['subject'] ?? 'Subject').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CA ${ca.toStringAsFixed(1)} | Exam ${resultsNum(score['exam']).toStringAsFixed(1)}',
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              total.toStringAsFixed(1),
              style: AppTextStyles.body.copyWith(
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
