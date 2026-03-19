import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/classes/helpers/student_classes_helpers.dart';
import 'package:schoolhq_ng/views/home/classes/helpers/subject_palette.dart';
import 'package:schoolhq_ng/views/home/classes/widgets/empty_classes_card.dart';
import 'package:schoolhq_ng/views/home/classes/widgets/module_meta_pill.dart';
import 'package:schoolhq_ng/views/home/classes/widgets/resource_card.dart';

class ModuleCard extends StatelessWidget {
  final Map<String, dynamic> module;
  final SubjectPalette palette;
  final bool expanded;
  final VoidCallback onToggle;

  const ModuleCard({
    super.key,
    required this.module,
    required this.palette,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final title = (module['title'] ?? 'Learning Module').toString();
    final weekNumber = classIntValue(module['week_number']);
    final objective = classStringOrNull(module['objective_preview']);
    final instruction = classStringOrNull(module['instruction_preview']);
    final reference = classStringOrNull(module['reference']);
    final resources = asClassList(module['resources']);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: expanded
              ? palette.primary.withOpacity(0.28)
              : AppColors.grey.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: expanded
                ? palette.primary.withOpacity(0.12)
                : Colors.black.withOpacity(0.04),
            blurRadius: expanded ? 26 : 12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: palette.gradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'WEEK',
                          style: AppTextStyles.small.copyWith(
                            color: Colors.white.withOpacity(0.82),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$weekNumber',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (objective != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            objective,
                            style: AppTextStyles.subtitle.copyWith(
                              height: 1.45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 240),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: palette.primary,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ModuleMetaPill(
                    icon: Icons.folder_open_rounded,
                    label: '${resources.length} resources',
                    palette: palette,
                  ),
                  if (reference != null)
                    ModuleMetaPill(
                      icon: Icons.bookmark_outline_rounded,
                      label: 'Reference ready',
                      palette: palette,
                    ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                child: expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (instruction != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: palette.soft,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  instruction,
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: AppColors.textPrimary,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            if (instruction != null) const SizedBox(height: 14),
                            Text(
                              'Resources',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (resources.isEmpty)
                              const EmptyClassesCard(
                                title: 'No resources yet',
                                message:
                                    'This module is visible, but the teacher has not added resources yet.',
                                compact: true,
                              )
                            else
                              Column(
                                children: resources
                                    .map(
                                      (resource) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: ResourceCard(
                                          resource: resource,
                                          palette: palette,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
