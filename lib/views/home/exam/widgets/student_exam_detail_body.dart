import 'package:flutter/material.dart';
import 'package:schoolhq_ng/views/home/exam/helpers/student_exam_helpers.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_action_card.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_instructions_card.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_overview_card.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_submitted_card.dart';

class StudentExamDetailBody extends StatelessWidget {
  final Map<String, dynamic> payload;
  final bool starting;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Map<String, dynamic>, Map<String, dynamic>)
  onStart;

  const StudentExamDetailBody({
    super.key,
    required this.payload,
    required this.starting,
    required this.onRefresh,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final exam = examAsMap(payload['exam']);
    final attempt = examAsMap(exam['attempt']);
    final isSubmitted =
        attempt['status']?.toString() == 'submitted' &&
        (attempt['submitted_at']?.toString().isNotEmpty ?? false);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          StudentExamOverviewCard(exam: exam),
          const SizedBox(height: 16),
          StudentExamInstructionsCard(
            instructions:
                exam['instructions']?.toString() ??
                'Read each question carefully before answering.',
          ),
          const SizedBox(height: 16),
          if (isSubmitted)
            StudentExamSubmittedCard(exam: exam, attempt: attempt)
          else
            StudentExamActionCard(
              attempt: attempt,
              isBusy: starting,
              onStart: () => onStart(exam, attempt),
            ),
        ],
      ),
    );
  }
}
