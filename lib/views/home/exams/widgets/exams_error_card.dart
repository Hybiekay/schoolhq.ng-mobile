import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class ExamsErrorCard extends StatelessWidget {
  final String message;

  const ExamsErrorCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Text(
        message.replaceFirst('Exception: ', ''),
        style: AppTextStyles.subtitle.copyWith(color: AppColors.error),
      ),
    );
  }
}
