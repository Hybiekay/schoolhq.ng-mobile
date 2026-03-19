import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/results/helpers/results_helpers.dart';
import 'package:schoolhq_ng/views/home/results/widgets/session_subject_result_card.dart';

class ResultsSessionCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultsSessionCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final session = resultsAsMap(data['session']);
    final results = resultsAsList(data['results']);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Summary',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            (session['name'] ?? '-').toString(),
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 14),
          if (results.isEmpty)
            const Text(
              'No session summary available.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...results.map(
              (subjectRow) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SessionSubjectResultCard(row: subjectRow),
              ),
            ),
        ],
      ),
    );
  }
}
