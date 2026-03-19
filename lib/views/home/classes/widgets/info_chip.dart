import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/classes/helpers/subject_palette.dart';

class InfoChip extends StatelessWidget {
  final String text;
  final bool selected;
  final SubjectPalette palette;

  const InfoChip({
    super.key,
    required this.text,
    required this.selected,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.small.copyWith(
          color: selected ? Colors.white : palette.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
