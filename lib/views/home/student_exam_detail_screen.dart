import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';

class StudentExamDetailScreen extends ConsumerStatefulWidget {
  final String examId;

  const StudentExamDetailScreen({super.key, required this.examId});

  @override
  ConsumerState<StudentExamDetailScreen> createState() =>
      _StudentExamDetailScreenState();
}

class _StudentExamDetailScreenState
    extends ConsumerState<StudentExamDetailScreen> {
  bool _starting = false;

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserRoleProvider);
    final detail = widget.examId.isEmpty
        ? const AsyncValue<Map<String, dynamic>>.error(
            'Exam ID is missing.',
            StackTrace.empty,
          )
        : ref.watch(mobileExamDetailProvider(widget.examId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exam Details'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: widget.examId.isEmpty
                ? null
                : () => ref.invalidate(mobileExamDetailProvider(widget.examId)),
          ),
        ],
      ),
      body: role != 'student'
          ? const _StatusState(
              icon: Icons.lock_outline_rounded,
              title: 'Student only',
              message: 'Only students can open and attempt CBT exams here.',
            )
          : detail.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _StatusState(
                icon: Icons.error_outline_rounded,
                title: 'Unable to load exam',
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(mobileExamDetailProvider(widget.examId)),
              ),
              data: (payload) {
                final exam = _asMap(payload['exam']);
                final attempt = _asMap(exam['attempt']);
                final isSubmitted =
                    attempt['status']?.toString() == 'submitted' &&
                    (attempt['submitted_at']?.toString().isNotEmpty ?? false);

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(
                    mobileExamDetailProvider(widget.examId).future,
                  ),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      _OverviewCard(exam: exam),
                      const SizedBox(height: 16),
                      _InstructionsCard(
                        instructions:
                            exam['instructions']?.toString() ??
                            'Read each question carefully before answering.',
                      ),
                      const SizedBox(height: 16),
                      if (isSubmitted)
                        _SubmittedCard(exam: exam, attempt: attempt)
                      else
                        _ActionCard(
                          exam: exam,
                          attempt: attempt,
                          isBusy: _starting,
                          onStart: () => _startOrResumeExam(exam, attempt),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _startOrResumeExam(
    Map<String, dynamic> exam,
    Map<String, dynamic> attempt,
  ) async {
    final attemptId = attempt['id']?.toString();
    final status = attempt['status']?.toString();

    if (_starting) return;

    setState(() => _starting = true);
    try {
      String targetAttemptId = '';

      if (attemptId != null &&
          attemptId.isNotEmpty &&
          status == 'in_progress') {
        targetAttemptId = attemptId;
      } else {
        final response = await ref
            .read(mobileRepositoryProvider)
            .startStudentExam(exam['id'].toString());
        final startedAttempt = _asMap(response['attempt']);
        final startedStatus = startedAttempt['status']?.toString();

        if (startedStatus == 'submitted') {
          ref.invalidate(mobileExamDetailProvider(widget.examId));
          ref.invalidate(mobileExamsProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This CBT has already been submitted.'),
              ),
            );
          }
          return;
        }

        targetAttemptId = startedAttempt['id']?.toString() ?? '';
      }

      if (!mounted || targetAttemptId.isEmpty) return;

      final result = await context.push<bool>(
        RouteNames.examAttemptPath(targetAttemptId),
      );

      ref.invalidate(mobileExamDetailProvider(widget.examId));
      ref.invalidate(mobileExamsProvider);

      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CBT submitted successfully.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _starting = false);
      }
    }
  }
}

class _OverviewCard extends StatelessWidget {
  final Map<String, dynamic> exam;

  const _OverviewCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final subject = _asMap(exam['subject'])['name']?.toString();
    final term = _asMap(exam['term'])['name']?.toString();
    final className = _asMap(exam['class'])['name']?.toString();

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
            [
              if ((subject ?? '').isNotEmpty) subject!,
              if ((term ?? '').isNotEmpty) term!,
              if ((className ?? '').isNotEmpty) className!,
            ].join(' | ').ifEmpty('Computer-based test'),
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.white.withOpacity(0.92),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OverviewPill(
                label: '${_intValue(exam['question_count'])} items',
              ),
              _OverviewPill(
                label:
                    '${_intValue(exam['duration_minutes'])} minutes',
              ),
              _OverviewPill(
                label:
                    '${_intValue(exam['passing_percentage'])}% pass mark',
              ),
              _OverviewPill(
                label:
                    (exam['exam_type'] ?? 'CBT')
                        .toString()
                        .replaceAll('_', ' '),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Starts: ${_formatIso(exam['start_date']) ?? 'Not scheduled'}',
            style: AppTextStyles.small.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Ends: ${_formatIso(exam['end_date']) ?? 'Not scheduled'}',
            style: AppTextStyles.small.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _OverviewPill extends StatelessWidget {
  final String label;

  const _OverviewPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  final String instructions;

  const _InstructionsCard({required this.instructions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            'CBT Instructions',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            'Read the rules before starting the exam.',
            style: AppTextStyles.small,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _plainText(instructions),
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Map<String, dynamic> exam;
  final Map<String, dynamic> attempt;
  final bool isBusy;
  final Future<void> Function() onStart;

  const _ActionCard({
    required this.exam,
    required this.attempt,
    required this.isBusy,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final hasAttempt = attempt.isNotEmpty;
    final isInProgress = attempt['status']?.toString() == 'in_progress';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exam readiness',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'The timer starts from the recorded attempt start time. Leaving the CBT screen, minimizing the app, or entering split screen will submit the paper automatically.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _HintPill(text: 'No screenshots'),
              _HintPill(text: 'No split screen'),
              _HintPill(text: 'Auto-submit on minimize'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isBusy ? null : onStart,
              icon: Icon(
                isInProgress ? Icons.play_arrow_rounded : Icons.rocket_launch,
              ),
              label: Text(
                isBusy
                    ? 'Opening CBT...'
                    : hasAttempt && isInProgress
                    ? 'Continue CBT'
                    : 'Start CBT',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  final String text;

  const _HintPill({required this.text});

  @override
  Widget build(BuildContext context) {
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

class _SubmittedCard extends StatelessWidget {
  final Map<String, dynamic> exam;
  final Map<String, dynamic> attempt;

  const _SubmittedCard({required this.exam, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final score = _doubleValue(attempt['score']);
    final passing = _intValue(exam['passing_percentage']);
    final totalPoints = _intValue(exam['total_points']);
    final percentage = totalPoints > 0 ? (score / totalPoints) * 100 : null;
    final passed = percentage != null && percentage >= passing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attempt submitted',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'This CBT has already been submitted from this account.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HintPill(text: 'Score: ${score.toStringAsFixed(0)} / $totalPoints'),
              if (percentage != null)
                _HintPill(text: 'Percentage: ${percentage.toStringAsFixed(0)}%'),
              _HintPill(text: passed ? 'Status: Passed' : 'Status: Failed'),
            ],
          ),
          if ((attempt['submitted_at'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Submitted: ${_formatIso(attempt['submitted_at']) ?? '-'}',
              style: AppTextStyles.small,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _StatusState({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message.replaceFirst('Exception: ', ''),
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
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
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _doubleValue(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _plainText(String value) {
  return value
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String? _formatIso(dynamic raw) {
  if (raw == null) return null;
  try {
    final dt = DateTime.parse(raw.toString()).toLocal();
    final month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][dt.month - 1];
    final hh = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month ${dt.day}, ${dt.year} $hh:$mm $ampm';
  } catch (_) {
    return null;
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
