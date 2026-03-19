import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/classes/helpers/student_classes_helpers.dart';
import 'package:schoolhq_ng/views/home/dashboard/widgets/hero_pill.dart';

class ClassHubCard extends StatelessWidget {
  final Map<String, dynamic> payload;
  final VoidCallback? onTap;

  const ClassHubCard({super.key, required this.payload, this.onTap});

  @override
  Widget build(BuildContext context) {
    final summary = asClassMap(payload['summary']);
    final session = asClassMap(payload['session']);
    final term = asClassMap(payload['term']);
    final subjects = asClassList(payload['subjects']);
    final topSubjects = subjects.take(3).toList();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -28,
              right: -18,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -36,
              left: -12,
              child: Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Go to Class',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${session['name'] ?? 'Current Session'} | ${term['name'] ?? 'Current Term'}',
                              style: AppTextStyles.small.copyWith(
                                color: Colors.white.withOpacity(0.84),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subjects.isEmpty
                        ? 'Your class space will appear here once modules are published.'
                        : 'Open subjects, follow weekly modules, and read resources from one colorful learning hub.',
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      HeroPill(
                        label: '${classIntValue(summary['subject_count'])} subjects',
                      ),
                      HeroPill(
                        label: '${classIntValue(summary['module_count'])} modules',
                      ),
                      HeroPill(
                        label:
                            '${classIntValue(summary['resource_count'])} resources',
                      ),
                    ],
                  ),
                  if (topSubjects.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: topSubjects
                          .map(
                            (item) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                (item['name'] ?? 'Subject').toString(),
                                style: AppTextStyles.small.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
