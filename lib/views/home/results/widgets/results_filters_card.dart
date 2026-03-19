import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/results/helpers/results_helpers.dart';

class ResultsFiltersCard extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final String? selectedSessionId;
  final String? selectedTermId;
  final ValueChanged<String?> onSessionChanged;
  final ValueChanged<String?> onTermChanged;

  const ResultsFiltersCard({
    super.key,
    required this.sessions,
    required this.selectedSessionId,
    required this.selectedTermId,
    required this.onSessionChanged,
    required this.onTermChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentSession = sessions.firstWhere(
      (s) => s['id']?.toString() == selectedSessionId,
      orElse: () => sessions.isNotEmpty ? sessions.first : <String, dynamic>{},
    );
    final terms = resultsTermsForSession(currentSession);
    final termValue = terms.any((t) => t['id']?.toString() == selectedTermId)
        ? selectedTermId
        : (terms.isNotEmpty ? terms.first['id']?.toString() : null);

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
            'Academic Filters',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose the session and term you want to review.',
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: sessions.any((s) => s['id']?.toString() == selectedSessionId)
                ? selectedSessionId
                : (sessions.isNotEmpty
                      ? sessions.first['id']?.toString()
                      : null),
            items: sessions
                .map(
                  (session) => DropdownMenuItem<String>(
                    value: session['id']?.toString(),
                    child: Text((session['name'] ?? 'Session').toString()),
                  ),
                )
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Session',
              border: OutlineInputBorder(),
            ),
            onChanged: sessions.isEmpty ? null : onSessionChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: termValue,
            items: terms
                .map(
                  (term) => DropdownMenuItem<String>(
                    value: term['id']?.toString(),
                    child: Text((term['name'] ?? 'Term').toString()),
                  ),
                )
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Term',
              border: OutlineInputBorder(),
            ),
            onChanged: terms.isEmpty ? null : onTermChanged,
          ),
        ],
      ),
    );
  }
}
