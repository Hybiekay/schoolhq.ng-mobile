import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/views/home/results/helpers/results_helpers.dart';
import 'package:schoolhq_ng/views/home/results/widgets/results_error_card.dart';
import 'package:schoolhq_ng/views/home/results/widgets/results_filters_card.dart';
import 'package:schoolhq_ng/views/home/results/widgets/results_header_card.dart';
import 'package:schoolhq_ng/views/home/results/widgets/results_loading_card.dart';
import 'package:schoolhq_ng/views/home/results/widgets/results_parent_child_selector.dart';
import 'package:schoolhq_ng/views/home/results/widgets/results_session_card.dart';
import 'package:schoolhq_ng/views/home/results/widgets/results_term_card.dart';
import 'package:schoolhq_ng/views/home/shared/widgets/mobile_top_action_bar.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  Future<void> _refreshResultsData(WidgetRef ref, String role) async {
    if (role == 'parent') {
      ref.invalidate(parentChildrenProvider);
      await ref.read(parentChildrenProvider.future);
    }

    ref.invalidate(mobileSessionsMetaProvider);
    await ref.read(mobileSessionsMetaProvider.future);

    ref.invalidate(mobileTermResultsProvider);
    ref.invalidate(mobileSessionResultsProvider);

    await Future.wait<dynamic>([
      ref.read(mobileTermResultsProvider.future),
      ref.read(mobileSessionResultsProvider.future),
    ]);
  }

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
    final selectedChildName = childrenAsync.maybeWhen(
      data: (children) {
        if (children.isEmpty) return null;
        final selected = children.firstWhere(
          (child) => child['id']?.toString() == selectedChildId,
          orElse: () => children.first,
        );
        return selected['full_name']?.toString();
      },
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshResultsData(ref, role),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              MobileTopActionBar(
                title: 'Results',
                subtitle:
                    'Review published term and session performance with quick tools at hand.',
                gradient: AppColors.accentGradient,
                onRefresh: () => _refreshResultsData(ref, role),
              ),
              const SizedBox(height: 16),
              ResultsHeaderCard(
                role: role,
                selectedChildName: selectedChildName,
              ),
              const SizedBox(height: 16),
              if (role == 'parent') ...[
                childrenAsync.when(
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (e, _) =>
                      ResultsErrorCard(message: 'Failed to load children: $e'),
                  data: (children) => ResultsParentChildSelector(
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
                const SizedBox(height: 14),
              ],
              metaAsync.when(
                loading: () =>
                    const ResultsLoadingCard(label: 'Loading session filters...'),
                error: (e, _) =>
                    ResultsErrorCard(message: 'Failed to load sessions: $e'),
                data: (sessions) => ResultsFiltersCard(
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
                    final terms = resultsTermsForSession(selectedSession);
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
              const SizedBox(height: 18),
              termAsync.when(
                loading: () =>
                    const ResultsLoadingCard(label: 'Loading term result...'),
                error: (e, _) => ResultsErrorCard(message: e.toString()),
                data: (data) => ResultsTermCard(data: data),
              ),
              const SizedBox(height: 18),
              sessionAsync.when(
                loading: () => const ResultsLoadingCard(
                  label: 'Loading session summary...',
                ),
                error: (e, _) => ResultsErrorCard(message: e.toString()),
                data: (data) => ResultsSessionCard(data: data),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
