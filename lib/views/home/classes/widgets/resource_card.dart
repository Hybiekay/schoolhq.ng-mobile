import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/classes/helpers/student_classes_helpers.dart';
import 'package:schoolhq_ng/views/home/classes/helpers/subject_palette.dart';

class ResourceCard extends StatelessWidget {
  final Map<String, dynamic> resource;
  final SubjectPalette palette;

  const ResourceCard({
    super.key,
    required this.resource,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final title = (resource['title'] ?? 'Resource').toString();
    final type = (resource['type'] ?? 'text').toString().toLowerCase();
    final description = classStringOrNull(resource['description_preview']);
    final content = classStringOrNull(resource['content_preview']);
    final url = classStringOrNull(resource['url']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.soft.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(classResourceIcon(type), color: palette.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        classResourceLabel(type),
                        style: AppTextStyles.small.copyWith(
                          color: palette.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTextStyles.subtitle.copyWith(height: 1.45),
                  ),
                ],
                if (content != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
                if (url != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          size: 16,
                          color: palette.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.small.copyWith(
                              color: palette.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
