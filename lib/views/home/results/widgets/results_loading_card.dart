import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class ResultsLoadingCard extends StatelessWidget {
  final String label;

  const ResultsLoadingCard({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}
