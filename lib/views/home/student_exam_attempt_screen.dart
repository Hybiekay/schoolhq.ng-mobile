import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/exam/exam_security_service.dart';
import 'package:schoolhq_ng/core/feedback/app_snackbar.dart';
import 'package:schoolhq_ng/core/hive/hive_key.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/views/home/exam/helpers/student_exam_helpers.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_attempt_header.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_bottom_action_bar.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_completed_state.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_instructions_card.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_question_card.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_question_strip.dart';
import 'package:schoolhq_ng/views/home/exam/widgets/student_exam_status_state.dart';

class StudentExamAttemptScreen extends ConsumerStatefulWidget {
  final String attemptId;

  const StudentExamAttemptScreen({super.key, required this.attemptId});

  @override
  ConsumerState<StudentExamAttemptScreen> createState() =>
      _StudentExamAttemptScreenState();
}

class _StudentExamAttemptScreenState
    extends ConsumerState<StudentExamAttemptScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  StreamSubscription<ExamSecurityEvent>? _securitySubscription;

  Map<String, dynamic> _attempt = const {};
  List<Map<String, dynamic>> _questions = const [];
  Map<String, String> _answers = const {};
  Set<String> _flagged = <String>{};

  int _currentIndex = 0;
  int? _remainingSeconds;
  bool _loading = true;
  bool _submitting = false;
  bool _savingAnswer = false;
  bool _completed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadAttempt());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _securitySubscription?.cancel();
    unawaited(ExamSecurityService.setSecureScreen(false));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_completed || _submitting || _attempt.isEmpty) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(
        _submitAttempt(
          reason: 'CBT submitted because the app left the exam screen.',
          autoTriggered: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserRoleProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('CBT Attempt'),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0.5,
          actions: [
            if (_remainingSeconds != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    examFormatTime(_remainingSeconds!),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _isInWarningWindow
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: role != 'student'
            ? const StudentExamStatusState(
                icon: Icons.lock_outline_rounded,
                title: 'Student only',
                message: 'Only students can take CBT exams from this screen.',
              )
            : _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? StudentExamStatusState(
                icon: Icons.error_outline_rounded,
                title: 'Unable to load CBT',
                message: _errorMessage!,
                onRetry: _loadAttempt,
              )
            : _completed
            ? StudentExamCompletedState(
                title: 'CBT submitted',
                message:
                    'Your answers have been submitted. You can return to the exam list now.',
                onClose: () => context.pop(true),
              )
            : SelectionContainer.disabled(
                child: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadAttempt,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          children: [
                            StudentExamAttemptHeader(
                              attempt: _attempt,
                              currentIndex: _currentIndex,
                              totalQuestions: _questions.length,
                              remainingSeconds: _remainingSeconds,
                              isWarning: _isInWarningWindow,
                            ),
                            const SizedBox(height: 14),
                            StudentExamInstructionsCard(
                              instructions:
                                  _exam['instructions']?.toString() ??
                                  'Read each question carefully before answering.',
                              subtitle:
                                  'Copying, screenshots, minimizing, and split screen are blocked.',
                            ),
                            const SizedBox(height: 14),
                            if (_question != null)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  final slide = Tween<Offset>(
                                    begin: const Offset(0.06, 0),
                                    end: Offset.zero,
                                  ).animate(animation);

                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: slide,
                                      child: child,
                                    ),
                                  );
                                },
                                child: StudentExamQuestionCard(
                                  key: ValueKey(
                                    '${_questionId}_$_currentIndex',
                                  ),
                                  question: _question!,
                                  answer: _answers[_questionId] ?? '',
                                  isFlagged: _flagged.contains(_questionId),
                                  index: _currentIndex,
                                  total: _questions.length,
                                  onAnswerChanged: _updateAnswer,
                                  onToggleFlag: _toggleFlag,
                                ),
                              ),
                            const SizedBox(height: 14),
                            StudentExamQuestionStrip(
                              total: _questions.length,
                              currentIndex: _currentIndex,
                              answers: _answers,
                              flagged: _flagged,
                              questions: _questions,
                              onSelected: (index) {
                                setState(() => _currentIndex = index);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    StudentExamBottomActionBar(
                      canGoBack: _currentIndex > 0,
                      isSaving: _savingAnswer,
                      isSubmitting: _submitting,
                      isLastQuestion: _currentIndex == _questions.length - 1,
                      hasSelection: (_answers[_questionId] ?? '').isNotEmpty,
                      onPrevious: () {
                        if (_currentIndex == 0) return;
                        setState(() => _currentIndex -= 1);
                      },
                      onNext: _goToNextQuestion,
                      onFinish: _confirmFinish,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Map<String, dynamic> get _exam => examAsMap(_attempt['exam']);

  Map<String, dynamic>? get _question =>
      _questions.isEmpty ? null : _questions[_currentIndex];

  String get _questionId => _question?['id']?.toString() ?? '';

  bool get _isInWarningWindow {
    final remaining = _remainingSeconds;
    if (remaining == null) return false;
    return remaining <=
        examWarningThresholdSeconds(examIntValue(_exam['duration_minutes']));
  }

  Future<void> _loadAttempt() async {
    if (widget.attemptId.isEmpty) {
      setState(() {
        _loading = false;
        _errorMessage = 'Attempt ID is missing.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final payload = await ref
          .read(mobileRepositoryProvider)
          .fetchStudentExamAttempt(widget.attemptId);
      final attempt = examAsMap(payload['attempt']);
      final orderedQuestions = _resolveQuestionOrder(
        examAsList(examAsMap(attempt['exam'])['questions']),
      );
      final answers = _mergeAnswers(examAsList(attempt['answers']));
      final flagged = _readStringSet(_flaggedStorageKey);

      _timer?.cancel();
      _securitySubscription?.cancel();

      setState(() {
        _attempt = attempt;
        _questions = orderedQuestions;
        _answers = answers;
        _flagged = flagged;
        _currentIndex = _initialQuestionIndex(orderedQuestions, answers);
        _remainingSeconds = _computeRemainingSeconds(attempt);
        _completed = attempt['status']?.toString() == 'submitted';
      });

      if (_completed) {
        _clearAttemptCache();
        return;
      }

      await ExamSecurityService.setSecureScreen(true);
      _startTimer();
      _securitySubscription = ExamSecurityService.events.listen((event) {
        if (event.type == 'multi_window' && event.active) {
          unawaited(
            _submitAttempt(
              reason:
                  'CBT submitted because split screen is not allowed during an exam.',
              autoTriggered: true,
            ),
          );
        }
      });

      final inMultiWindow = await ExamSecurityService.isInMultiWindow();
      if (inMultiWindow) {
        await _submitAttempt(
          reason:
              'CBT submitted because split screen is not allowed during an exam.',
          autoTriggered: true,
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = _computeRemainingSeconds(_attempt);
      if (!mounted) return;

      setState(() => _remainingSeconds = remaining);

      if (remaining <= 0) {
        _timer?.cancel();
        unawaited(
          _submitAttempt(
            reason: 'Time is up. Your CBT has been submitted automatically.',
            autoTriggered: true,
          ),
        );
      }
    });
  }

  void _updateAnswer(String value) {
    if (_questionId.isEmpty) return;

    setState(() {
      _answers = {..._answers, _questionId: value};
    });
    _persistAnswers();
  }

  void _toggleFlag() {
    if (_questionId.isEmpty) return;

    setState(() {
      if (_flagged.contains(_questionId)) {
        _flagged.remove(_questionId);
      } else {
        _flagged.add(_questionId);
      }
    });
    _persistFlagged();
  }

  Future<void> _goToNextQuestion() async {
    if (_question == null || _submitting) return;

    final answer = (_answers[_questionId] ?? '').trim();
    if (answer.isEmpty) return;

    setState(() => _savingAnswer = true);
    try {
      await ref
          .read(mobileRepositoryProvider)
          .saveStudentExamAnswer(
            attemptId: widget.attemptId,
            questionId: _questionId,
            answer: answer,
          );
    } catch (_) {
      if (mounted) {
        AppSnackBar.warning(
          context,
          'Answer saved locally. Final submission will still include it.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _savingAnswer = false);
      }
    }

    if (!mounted) return;

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex += 1);
      return;
    }

    await _confirmFinish();
  }

  Future<void> _confirmFinish() async {
    if (_submitting) return;

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Submit CBT?'),
        content: const Text(
          'You will not be able to change your answers after submission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (shouldSubmit == true) {
      await _submitAttempt();
    }
  }

  Future<void> _submitAttempt({
    String? reason,
    bool autoTriggered = false,
  }) async {
    if (_submitting || _completed || _attempt.isEmpty) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final answersPayload = _answers.entries
          .where((entry) => entry.value.trim().isNotEmpty)
          .map(
            (entry) => {'question_id': entry.key, 'answer': entry.value.trim()},
          )
          .toList();

      final response = await ref
          .read(mobileRepositoryProvider)
          .submitStudentExamAttempt(
            attemptId: widget.attemptId,
            answers: answersPayload,
          );

      _timer?.cancel();
      _completed = true;
      _attempt = examAsMap(response['attempt']);
      _clearAttemptCache();
      await ExamSecurityService.setSecureScreen(false);
      final examId = _exam['id']?.toString();
      ref.invalidate(mobileExamsProvider);
      if (examId != null && examId.isNotEmpty) {
        ref.invalidate(mobileExamDetailProvider(examId));
      }
      await Future.wait<dynamic>([
        ref.read(mobileExamsProvider.future),
        if (examId != null && examId.isNotEmpty)
          ref.read(mobileExamDetailProvider(examId).future),
      ]);

      if (!mounted) return;

      if (autoTriggered && reason != null) {
        AppSnackBar.warning(context, reason);
      }

      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  List<Map<String, dynamic>> _resolveQuestionOrder(
    List<Map<String, dynamic>> questions,
  ) {
    if (questions.isEmpty) return const [];

    final stored = Hive.box(HiveKey.boxApp).get(_orderStorageKey);
    if (stored is List) {
      final ids = stored.map((item) => item.toString()).toList();
      final ordered = ids
          .map(
            (id) => questions.firstWhere(
              (question) => question['id']?.toString() == id,
              orElse: () => const {},
            ),
          )
          .where((question) => question.isNotEmpty)
          .map((question) => Map<String, dynamic>.from(question))
          .toList();

      if (ordered.length == questions.length) {
        return ordered;
      }
    }

    final shuffled = List<Map<String, dynamic>>.from(questions)
      ..shuffle(Random());
    Hive.box(HiveKey.boxApp).put(
      _orderStorageKey,
      shuffled.map((question) => question['id'].toString()).toList(),
    );
    return shuffled;
  }

  Map<String, String> _mergeAnswers(List<Map<String, dynamic>> answers) {
    final merged = <String, String>{};
    for (final answer in answers) {
      final questionId = answer['question_id']?.toString();
      final value = answer['answer']?.toString() ?? '';
      if (questionId != null && questionId.isNotEmpty && value.isNotEmpty) {
        merged[questionId] = value;
      }
    }

    final cached = Hive.box(HiveKey.boxApp).get(_answersStorageKey);
    if (cached is Map) {
      for (final entry in cached.entries) {
        final key = entry.key?.toString();
        final value = entry.value?.toString() ?? '';
        if (key != null && key.isNotEmpty && value.isNotEmpty) {
          merged[key] = value;
        }
      }
    }

    return merged;
  }

  int _initialQuestionIndex(
    List<Map<String, dynamic>> questions,
    Map<String, String> answers,
  ) {
    final unanswered = questions.indexWhere((question) {
      final id = question['id']?.toString() ?? '';
      return (answers[id] ?? '').trim().isEmpty;
    });
    return unanswered == -1 ? 0 : unanswered;
  }

  int _computeRemainingSeconds(Map<String, dynamic> attempt) {
    final startedAtRaw = attempt['started_at']?.toString();
    final durationMinutes = examIntValue(
      examAsMap(attempt['exam'])['duration_minutes'],
    );

    if (startedAtRaw == null || durationMinutes <= 0) {
      return 0;
    }

    try {
      final startedAt = DateTime.parse(startedAtRaw).toLocal();
      final endsAt = startedAt.add(Duration(minutes: durationMinutes));
      final diff = endsAt.difference(DateTime.now()).inSeconds;
      return diff > 0 ? diff : 0;
    } catch (_) {
      return 0;
    }
  }

  Set<String> _readStringSet(String key) {
    final stored = Hive.box(HiveKey.boxApp).get(key);
    if (stored is List) {
      return stored.map((item) => item.toString()).toSet();
    }
    return <String>{};
  }

  void _persistAnswers() {
    Hive.box(HiveKey.boxApp).put(_answersStorageKey, _answers);
  }

  void _persistFlagged() {
    Hive.box(HiveKey.boxApp).put(_flaggedStorageKey, _flagged.toList());
  }

  void _clearAttemptCache() {
    final box = Hive.box(HiveKey.boxApp);
    box.delete(_answersStorageKey);
    box.delete(_orderStorageKey);
    box.delete(_flaggedStorageKey);
  }

  String get _answersStorageKey => 'exam_attempt_answers_${widget.attemptId}';
  String get _orderStorageKey => 'exam_attempt_order_${widget.attemptId}';
  String get _flaggedStorageKey => 'exam_attempt_flagged_${widget.attemptId}';
}
