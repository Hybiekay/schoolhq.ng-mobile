import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/exam/helpers/student_exam_helpers.dart';

class StudentExamInstructionsCard extends StatelessWidget {
  final String instructions;
  final String subtitle;

  const StudentExamInstructionsCard({
    super.key,
    required this.instructions,
    this.subtitle = 'Read the rules before starting the exam.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            'CBT Instructions',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(subtitle, style: AppTextStyles.small),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                examPlainText(instructions),
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
