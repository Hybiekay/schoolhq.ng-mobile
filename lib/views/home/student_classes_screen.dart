import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/views/home/classes/helpers/student_classes_helpers.dart';
import 'package:schoolhq_ng/views/home/classes/helpers/subject_palette.dart';
import 'package:schoolhq_ng/views/home/classes/widgets/classes_error_state.dart';
import 'package:schoolhq_ng/views/home/classes/widgets/empty_classes_card.dart';
import 'package:schoolhq_ng/views/home/classes/widgets/learning_hero_card.dart';
import 'package:schoolhq_ng/views/home/classes/widgets/module_card.dart';
import 'package:schoolhq_ng/views/home/classes/widgets/subject_card.dart';

class StudentClassesScreen extends ConsumerStatefulWidget {
  const StudentClassesScreen({super.key});

  @override
  ConsumerState<StudentClassesScreen> createState() =>
      _StudentClassesScreenState();
}

class _StudentClassesScreenState extends ConsumerState<StudentClassesScreen> {
  String? _selectedSubjectId;
  final Set<String> _expandedModules = <String>{};

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(mobileClassesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Classes'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(mobileClassesProvider),
          ),
        ],
      ),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ClassesErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(mobileClassesProvider),
        ),
        data: (payload) {
          final subjects = asClassList(payload['subjects']);
          final summary = asClassMap(payload['summary']);
          final student = asClassMap(payload['student']);
          final session = asClassMap(payload['session']);
          final term = asClassMap(payload['term']);
          final selectedSubject = _selected(subjects);
          final selectedIndex = selectedSubject.isEmpty
              ? 0
              : subjects.indexWhere(
                  (item) => item['id']?.toString() == selectedSubject['id'],
                );
          final palette = paletteForIndex(
            selectedSubject['accent_index'] ?? selectedIndex,
          );
          final modules = asClassList(selectedSubject['modules']);

          return RefreshIndicator(
            onRefresh: () => ref.refresh(mobileClassesProvider.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                LearningHeroCard(
                  student: student,
                  session: session,
                  term: term,
                  summary: summary,
                ),
                const SizedBox(height: 20),
                Text('Subjects', style: AppTextStyles.headingMedium),
                const SizedBox(height: 6),
                Text(
                  'Choose a subject to explore its weekly modules and learning resources.',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 14),
                if (subjects.isEmpty)
                  const EmptyClassesCard(
                    title: 'No classes yet',
                    message:
                        'Your subjects and modules will appear here once your school publishes them.',
                  )
                else
                  SizedBox(
                    height: 164,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: subjects.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        final subject = subjects[index];
                        return SubjectCard(
                          subject: subject,
                          palette: paletteForIndex(
                            subject['accent_index'] ?? index,
                          ),
                          selected:
                              subject['id']?.toString() == selectedSubject['id'],
                          onTap: () {
                            setState(() {
                              _selectedSubjectId = subject['id']?.toString();
                            });
                          },
                        );
                      },
                    ),
                  ),
                if (subjects.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (selectedSubject['name'] ?? 'Modules').toString(),
                              style: AppTextStyles.headingMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              modules.isEmpty
                                  ? 'No module has been published for this subject yet.'
                                  : '${modules.length} learning module${modules.length == 1 ? '' : 's'} ready for you.',
                              style: AppTextStyles.subtitle,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: palette.soft,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${classIntValue(selectedSubject['resource_count'])} resources',
                          style: AppTextStyles.small.copyWith(
                            color: palette.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    child: modules.isEmpty
                        ? const EmptyClassesCard(
                            key: ValueKey('empty-modules'),
                            title: 'Nothing published yet',
                            message:
                                'Check back soon. Once your teacher opens a module, you will see it here.',
                          )
                        : Column(
                            key: ValueKey(selectedSubject['id'] ?? 'modules'),
                            children: modules
                                .map(
                                  (module) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: ModuleCard(
                                      module: module,
                                      palette: palette,
                                      expanded: _expandedModules.contains(
                                        module['id']?.toString(),
                                      ),
                                      onToggle: () {
                                        final id = module['id']?.toString();
                                        if (id == null || id.isEmpty) return;
                                        setState(() {
                                          if (_expandedModules.contains(id)) {
                                            _expandedModules.remove(id);
                                          } else {
                                            _expandedModules.add(id);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _selected(List<Map<String, dynamic>> subjects) {
    if (subjects.isEmpty) return const <String, dynamic>{};
    if (_selectedSubjectId != null) {
      for (final subject in subjects) {
        if (subject['id']?.toString() == _selectedSubjectId) return subject;
      }
    }
    return subjects.first;
  }
}
