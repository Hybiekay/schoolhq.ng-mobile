import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final metaAsync = ref.watch(mobileSessionsMetaProvider);
    final termAsync = ref.watch(mobileTermResultsProvider);
    final sessionAsync = ref.watch(mobileSessionResultsProvider);
    final childrenAsync = role == 'parent'
        ? ref.watch(parentChildrenProvider)
        : const AsyncValue<List<Map<String, dynamic>>>.data([]);
    final selectedChildId = ref.watch(parentSelectedChildIdProvider);
    final selectedSessionId = ref.watch(resultsSelectedSessionIdProvider);
    final selectedTermId = ref.watch(resultsSelectedTermIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(mobileSessionsMetaProvider);
              ref.invalidate(mobileTermResultsProvider);
              ref.invalidate(mobileSessionResultsProvider);
              ref.invalidate(parentChildrenProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(mobileSessionsMetaProvider);
          ref.invalidate(mobileTermResultsProvider);
          ref.invalidate(mobileSessionResultsProvider);
          if (role == 'parent') ref.invalidate(parentChildrenProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            if (role == 'parent') ...[
              childrenAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (e, _) =>
                    _ErrorCard(message: 'Failed to load children: $e'),
                data: (children) => _ParentChildSelector(
                  children: children,
                  selectedChildId: selectedChildId,
                  onSelected: (id) {
                    ref.read(parentSelectedChildIdProvider.notifier).set(id);
                    ref.invalidate(mobileTermResultsProvider);
                    ref.invalidate(mobileSessionResultsProvider);
                    ref.invalidate(mobileFeesProvider);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            metaAsync.when(
              loading: () =>
                  const _LoadingCard(label: 'Loading session filters...'),
              error: (e, _) =>
                  _ErrorCard(message: 'Failed to load sessions: $e'),
              data: (sessions) => _ResultsFilters(
                sessions: sessions,
                selectedSessionId: selectedSessionId,
                selectedTermId: selectedTermId,
                onSessionChanged: (sessionId) {
                  ref.read(resultsSelectedSessionIdProvider.notifier).state =
                      sessionId;
                  final selectedSession = sessions
                      .cast<Map<String, dynamic>?>()
                      .firstWhere(
                        (s) => s?['id']?.toString() == sessionId,
                        orElse: () =>
                            sessions.isNotEmpty ? sessions.first : null,
                      );
                  final terms = _termsForSession(selectedSession);
                  final currentTerm = terms.firstWhere(
                    (t) => t['is_current'] == true,
                    orElse: () =>
                        terms.isNotEmpty ? terms.first : <String, dynamic>{},
                  );
                  ref.read(resultsSelectedTermIdProvider.notifier).state =
                      currentTerm['id']?.toString();
                  ref.invalidate(mobileTermResultsProvider);
                  ref.invalidate(mobileSessionResultsProvider);
                  ref.invalidate(mobileFeesProvider);
                },
                onTermChanged: (termId) {
                  ref.read(resultsSelectedTermIdProvider.notifier).state =
                      termId;
                  ref.invalidate(mobileTermResultsProvider);
                  ref.invalidate(mobileFeesProvider);
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Term Result', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            termAsync.when(
              loading: () =>
                  const _LoadingCard(label: 'Loading term result...'),
              error: (e, _) => _ErrorCard(message: e.toString()),
              data: (data) => _TermResultsCard(data: data),
            ),
            const SizedBox(height: 16),
            Text('Session Summary', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            sessionAsync.when(
              loading: () =>
                  const _LoadingCard(label: 'Loading session summary...'),
              error: (e, _) => _ErrorCard(message: e.toString()),
              data: (data) => _SessionResultsCard(data: data),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsFilters extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final String? selectedSessionId;
  final String? selectedTermId;
  final ValueChanged<String?> onSessionChanged;
  final ValueChanged<String?> onTermChanged;

  const _ResultsFilters({
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
    final terms = _termsForSession(currentSession);
    final termValue = terms.any((t) => t['id']?.toString() == selectedTermId)
        ? selectedTermId
        : (terms.isNotEmpty ? terms.first['id']?.toString() : null);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
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

class _TermResultsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TermResultsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final student = _asMap(data['student']);
    final session = _asMap(data['session']);
    final term = _asMap(data['term']);
    final published = data['published'] == true;
    final results = _asList(data['results']);
    final scoreRows = <Map<String, dynamic>>[];
    for (final result in results) {
      final scores = _asList(result['scores']);
      scoreRows.addAll(scores);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (student['full_name'] ?? 'Student').toString(),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${session['name'] ?? '-'} • ${term['name'] ?? '-'}',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 8),
          _Badge(
            text: published ? 'PUBLISHED' : 'NOT PUBLISHED',
            color: published
                ? const Color(0xFF16A34A)
                : const Color(0xFFD97706),
          ),
          const SizedBox(height: 12),
          if (scoreRows.isEmpty)
            const Text(
              'No scores found for this term.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...scoreRows.map((score) => _ScoreRow(score: score)),
        ],
      ),
    );
  }
}

class _SessionResultsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _SessionResultsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final session = _asMap(data['session']);
    final results = _asList(data['results']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session: ${session['name'] ?? '-'}',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (results.isEmpty)
            const Text(
              'No session summary available.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...results.map(
              (subjectRow) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SubjectSessionCard(row: subjectRow),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubjectSessionCard extends StatelessWidget {
  final Map<String, dynamic> row;

  const _SubjectSessionCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final terms = _asMap(row['terms']);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (row['subject_name'] ?? 'Subject').toString(),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...terms.entries.map((entry) {
            final score = _asMap(entry.value);
            final unpublished = entry.value == null || score.isEmpty;
            final total = unpublished
                ? '-'
                : _num(score['total']).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key, style: AppTextStyles.small)),
                  Text(
                    unpublished ? 'Not published' : 'Total: $total',
                    style: AppTextStyles.small.copyWith(
                      color: unpublished
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final Map<String, dynamic> score;

  const _ScoreRow({required this.score});

  @override
  Widget build(BuildContext context) {
    final total = _num(score['total']);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (score['subject'] ?? 'Subject').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CA: ${_num(score['welcome']) + _num(score['mid'])} • Exam: ${_num(score['exam'])}',
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
          Text(
            total.toStringAsFixed(1),
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentChildSelector extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final String? selectedChildId;
  final ValueChanged<String> onSelected;

  const _ParentChildSelector({
    required this.children,
    required this.selectedChildId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const _ErrorCard(
        message: 'No children linked to this parent account.',
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: children.map((child) {
        final id = (child['id'] ?? '').toString();
        final selected =
            id == selectedChildId ||
            (selectedChildId == null && children.first == child);
        return ChoiceChip(
          label: Text((child['full_name'] ?? 'Student').toString()),
          selected: selected,
          onSelected: (_) => onSelected(id),
          selectedColor: AppColors.primary.withOpacity(0.15),
          labelStyle: AppTextStyles.small.copyWith(
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        );
      }).toList(),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.small.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String label;

  const _LoadingCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Text(
        message,
        style: AppTextStyles.subtitle.copyWith(color: AppColors.error),
      ),
    );
  }
}

List<Map<String, dynamic>> _termsForSession(Map<String, dynamic>? session) {
  if (session == null) return const [];
  final terms = (session['terms'] as List?) ?? const [];
  return terms
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> _asList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

double _num(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? 0}') ?? 0;
}
