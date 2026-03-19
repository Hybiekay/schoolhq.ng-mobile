import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class ExamsSummaryStrip extends StatelessWidget {
  final int total;
  final int inProgress;
  final int submitted;
  final int pending;

  const ExamsSummaryStrip({
    super.key,
    required this.total,
    required this.inProgress,
    required this.submitted,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _tile('Total', '$total', AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: _tile('Live', '$inProgress', AppColors.accent)),
        const SizedBox(width: 10),
        Expanded(child: _tile('Done', '$submitted', AppColors.success)),
        const SizedBox(width: 10),
        Expanded(child: _tile('Pending', '$pending', AppColors.secondary)),
      ],
    );
  }

  Widget _tile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
