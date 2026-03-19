import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class StudentExamHintPill extends StatelessWidget {
  final String text;

  const StudentExamHintPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: AppTextStyles.small),
    );
  }
}
