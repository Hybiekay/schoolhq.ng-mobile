import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/classes/helpers/student_classes_helpers.dart';
import 'package:schoolhq_ng/views/home/classes/widgets/glow_bubble.dart';
import 'package:schoolhq_ng/views/home/classes/widgets/summary_badge.dart';

class LearningHeroCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final Map<String, dynamic> session;
  final Map<String, dynamic> term;
  final Map<String, dynamic> summary;

  const LearningHeroCard({
    super.key,
    required this.student,
    required this.session,
    required this.term,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final className = asClassMap(student['class'])['name']?.toString() ?? 'Class';

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.coolGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -36,
            right: -8,
            child: GlowBubble(size: 116, opacity: 0.12),
          ),
          const Positioned(
            bottom: -50,
            left: -18,
            child: GlowBubble(size: 146, opacity: 0.08),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Hub',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$className | ${session['name'] ?? 'Session'} | ${term['name'] ?? 'Term'}',
                  style: AppTextStyles.subtitle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'All your subjects, weekly modules, and study resources are organized here for quick learning.',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SummaryBadge(
                      label: 'Subjects',
                      value: '${classIntValue(summary['subject_count'])}',
                    ),
                    SummaryBadge(
                      label: 'Modules',
                      value: '${classIntValue(summary['module_count'])}',
                    ),
                    SummaryBadge(
                      label: 'Resources',
                      value: '${classIntValue(summary['resource_count'])}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
