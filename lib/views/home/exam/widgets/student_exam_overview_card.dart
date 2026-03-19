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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C81), Color(0xFF265BE3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (exam['title'] ?? 'Exam').toString(),
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
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
                label: '${examIntValue(exam['passing_percentage'])}% pass mark',
              ),
              StudentExamOverviewPill(
                label: (exam['exam_type'] ?? 'CBT').toString().replaceAll(
                  '_',
                  ' ',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Starts: ${examFormatIso(exam['start_date']) ?? 'Not scheduled'}',
            style: AppTextStyles.small.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Ends: ${examFormatIso(exam['end_date']) ?? 'Not scheduled'}',
            style: AppTextStyles.small.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
