import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/exam/helpers/student_exam_helpers.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_overview_pill.dart';

class StudentExamOverviewCard extends StatelessWidget {
  final Map<String, dynamic> exam;

  const StudentExamOverviewCard({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final subject = examAsMap(exam['subject'])['name']?.toString();
    final term = examAsMap(exam['term'])['name']?.toString();
    final className = examAsMap(exam['class'])['name']?.toString();
    final attempt = examAsMap(exam['attempt']);
    final status = (attempt['status'] ?? exam['status'] ?? 'available')
        .toString()
        .toLowerCase();
    final statusColor = switch (status) {
      'submitted' => AppColors.success,
      'in_progress' => AppColors.accent,
      _ => Colors.white,
    };

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -26,
            right: -12,
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
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
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.monitor_heart_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (exam['title'] ?? 'Exam').toString(),
                            style: AppTextStyles.headingMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            examIfEmpty(
                              [
                                if ((subject ?? '').isNotEmpty) subject!,
                                if ((term ?? '').isNotEmpty) term!,
                                if ((className ?? '').isNotEmpty) className!,
                              ].join(' | '),
                              'Computer-based test',
                            ),
                            style: AppTextStyles.subtitle.copyWith(
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'available'
                            ? Colors.white.withOpacity(0.14)
                            : statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status.replaceAll('_', ' ').toUpperCase(),
                        style: AppTextStyles.small.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StudentExamOverviewPill(
                      label: '${examIntValue(exam['question_count'])} items',
                    ),
                    StudentExamOverviewPill(
                      label: '${examIntValue(exam['duration_minutes'])} minutes',
                    ),
                    StudentExamOverviewPill(
                      label:
                          '${examIntValue(exam['passing_percentage'])}% pass mark',
                    ),
                    StudentExamOverviewPill(
                      label: (exam['exam_type'] ?? 'CBT').toString().replaceAll(
                        '_',
                        ' ',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live schedule',
                        style: AppTextStyles.small.copyWith(
                          color: Colors.white.withOpacity(0.82),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Starts: ${examFormatIso(exam['start_date']) ?? 'Not scheduled'}',
                        style: AppTextStyles.small.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ends: ${examFormatIso(exam['end_date']) ?? 'Not scheduled'}',
                        style: AppTextStyles.small.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
