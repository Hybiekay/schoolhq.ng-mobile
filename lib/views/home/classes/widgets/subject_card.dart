import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/classes/helpers/student_classes_helpers.dart';
import 'package:schoolhq_ng/views/home/classes/helpers/subject_palette.dart';
import 'package:schoolhq_ng/views/home/classes/widgets/info_chip.dart';

class SubjectCard extends StatelessWidget {
  final Map<String, dynamic> subject;
  final SubjectPalette palette;
  final bool selected;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = (subject['name'] ?? 'Subject').toString();
    final modules = classIntValue(subject['module_count']);
    final resources = classIntValue(subject['resource_count']);

    return AnimatedScale(
      scale: selected ? 1 : 0.97,
      duration: const Duration(milliseconds: 240),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: 214,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: selected
                ? palette.gradient
                : LinearGradient(
                    colors: [Colors.white, palette.soft.withOpacity(0.72)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: selected
                  ? Colors.white.withOpacity(0.18)
                  : palette.primary.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? palette.primary.withOpacity(0.18)
                    : Colors.black.withOpacity(0.05),
                blurRadius: selected ? 24 : 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.14)
                      : palette.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: selected ? Colors.white : palette.primary,
                ),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(
                    text: '$modules modules',
                    selected: selected,
                    palette: palette,
                  ),
                  InfoChip(
                    text: '$resources resources',
                    selected: selected,
                    palette: palette,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
