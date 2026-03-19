import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/feedback/app_snackbar.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/views/home/exam/helpers/student_exam_helpers.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_detail_body.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_status_state.dart';

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

  Future<void> _refreshDetail() async {
    if (widget.examId.isEmpty) {
      return;
    }

    ref.invalidate(mobileExamDetailProvider(widget.examId));
    ref.invalidate(mobileExamsProvider);

    await Future.wait<dynamic>([
      ref.read(mobileExamDetailProvider(widget.examId).future),
      ref.read(mobileExamsProvider.future),
    ]);
  }

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
            onPressed: widget.examId.isEmpty ? null : _refreshDetail,
          ),
        ],
      ),
      body: role != 'student'
          ? const StudentExamStatusState(
              icon: Icons.lock_outline_rounded,
              title: 'Student only',
              message: 'Only students can open and attempt CBT exams here.',
            )
          : detail.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => StudentExamStatusState(
                icon: Icons.error_outline_rounded,
                title: 'Unable to load exam',
                message: error.toString(),
                onRetry: _refreshDetail,
              ),
              data: (payload) => StudentExamDetailBody(
                payload: payload,
                starting: _starting,
                onRefresh: _refreshDetail,
                onStart: _startOrResumeExam,
              ),
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
        final startedAttempt = examAsMap(response['attempt']);
        final startedStatus = startedAttempt['status']?.toString();

        if (startedStatus == 'submitted') {
          await _refreshDetail();
          if (mounted) {
            AppSnackBar.info(context, 'This CBT has already been submitted.');
          }
          return;
        }

        targetAttemptId = startedAttempt['id']?.toString() ?? '';
      }

      if (!mounted || targetAttemptId.isEmpty) return;

      final result = await context.push<bool>(
        RouteNames.examAttemptPath(targetAttemptId),
      );

      await _refreshDetail();

      if (result == true && mounted) {
        AppSnackBar.success(context, 'CBT submitted successfully.');
      }
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _starting = false);
      }
    }
  }
}
