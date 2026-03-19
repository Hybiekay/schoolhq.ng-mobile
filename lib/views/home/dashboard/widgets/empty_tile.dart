import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class EmptyTile extends StatelessWidget {
  final String message;

  const EmptyTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Text(message, style: AppTextStyles.subtitle),
    );
  }
}
