import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/results/helpers/results_helpers.dart';
import 'package:schoolhq_ng/views/home/results/widgets/result_score_row.dart';
import 'package:schoolhq_ng/views/home/results/widgets/results_status_badge.dart';

class ResultsTermCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultsTermCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final student = resultsAsMap(data['student']);
    final session = resultsAsMap(data['session']);
    final term = resultsAsMap(data['term']);
    final published = data['published'] == true;
    final results = resultsAsList(data['results']);
    final scoreRows = <Map<String, dynamic>>[];
    for (final result in results) {
      scoreRows.addAll(resultsAsList(result['scores']));
    }
    final average = resultsAverageTotal(scoreRows);

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (student['full_name'] ?? 'Student').toString(),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session['name'] ?? '-'} | ${term['name'] ?? '-'}',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
              ResultsStatusBadge(
                text: published ? 'PUBLISHED' : 'NOT PUBLISHED',
                color: published
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFD97706),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('Subjects ${scoreRows.length}'),
              _pill(
                published && scoreRows.isNotEmpty
                    ? 'Average ${average.toStringAsFixed(1)}'
                    : 'Awaiting publication',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (scoreRows.isEmpty)
            const Text(
              'No scores found for this term.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...scoreRows.map((score) => ResultScoreRow(score: score)),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: AppTextStyles.small),
    );
  }
}
