import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/views/home/exams/helpers/exams_screen_helpers.dart';
import 'package:schoolhq_ng/views/home/exams/widgets/exam_list_card.dart';
import 'package:schoolhq_ng/views/home/exams/widgets/exams_empty_state.dart';
import 'package:schoolhq_ng/views/home/exams/widgets/exams_error_card.dart';
import 'package:schoolhq_ng/views/home/exams/widgets/exams_header_card.dart';
import 'package:schoolhq_ng/views/home/exams/widgets/exams_parent_child_selector.dart';
import 'package:schoolhq_ng/views/home/exams/widgets/exams_summary_strip.dart';
import 'package:schoolhq_ng/views/home/shared/widgets/mobile_top_action_bar.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  Future<void> _refreshExamData(WidgetRef ref, String role) async {
    if (role == 'parent') {
      ref.invalidate(parentChildrenProvider);
      await ref.read(parentChildrenProvider.future);
    }

    ref.invalidate(mobileExamsProvider);
    await ref.read(mobileExamsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final examsAsync = ref.watch(mobileExamsProvider);
    final childrenAsync = role == 'parent'
        ? ref.watch(parentChildrenProvider)
        : const AsyncValue<List<Map<String, dynamic>>>.data([]);
    final selectedChildId = ref.watch(parentSelectedChildIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshExamData(ref, role),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              MobileTopActionBar(
                title: role == 'parent' ? 'Children Exams' : 'My Exams',
                subtitle:
                    'Stay synced with the latest exam status and jump quickly between key screens.',
                gradient: AppColors.coolGradient,
                onRefresh: () => _refreshExamData(ref, role),
              ),
              const SizedBox(height: 16),
              ExamsHeaderCard(role: role),
              const SizedBox(height: 16),
              if (role == 'parent') ...[
                childrenAsync.when(
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (e, _) =>
                      ExamsErrorCard(message: 'Failed to load children: $e'),
                  data: (children) => ExamsParentChildSelector(
                    children: children,
                    selectedChildId: selectedChildId,
                    onSelected: (id) async {
                      ref.read(parentSelectedChildIdProvider.notifier).set(id);
                      await _refreshExamData(ref, role);
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              examsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => ExamsErrorCard(message: error.toString()),
                data: (data) {
                  final exams = examsExtractExams(data);
                  final child = examsAsMap(data['child']);
                  final inProgress = exams
                      .where(
                        (exam) =>
                            examsAsMap(exam['attempt'])['status']?.toString() ==
                            'in_progress',
                      )
                      .length;
                  final submitted = exams
                      .where(
                        (exam) =>
                            examsAsMap(exam['attempt'])['status']?.toString() ==
                            'submitted',
                      )
                      .length;
                  final pending = exams.length - submitted;
                  final heading = role == 'parent' && child.isNotEmpty
                      ? 'Showing exams for ${child['full_name'] ?? 'child'}'
                      : role == 'student'
                      ? 'Latest exam state synced from backend'
                      : 'Select a child to view exams';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(heading, style: AppTextStyles.subtitle),
                      const SizedBox(height: 12),
                      ExamsSummaryStrip(
                        total: exams.length,
                        inProgress: inProgress,
                        submitted: submitted,
                        pending: pending,
                      ),
                      const SizedBox(height: 16),
                      if (exams.isEmpty)
                        const ExamsEmptyState(
                          message: 'No exams available right now.',
                        )
                      else
                        ...exams.map(
                          (exam) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ExamListCard(
                              exam: exam,
                              role: role,
                              onOpen: role != 'student'
                                  ? null
                                  : () async {
                                      await context.push(
                                        RouteNames.examDetailPath(
                                          exam['id'].toString(),
                                        ),
                                      );
                                      await _refreshExamData(ref, role);
                                    },
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
