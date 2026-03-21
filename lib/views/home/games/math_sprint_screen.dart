import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/models/math_sprint_question_model.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/views/home/games/widgets/math_sprint/math_sprint_banner_card.dart';
import 'package:schoolhq_ng/views/home/games/widgets/math_sprint/math_sprint_choice_grid.dart';
import 'package:schoolhq_ng/views/home/games/widgets/math_sprint/math_sprint_question_card.dart';
import 'package:schoolhq_ng/views/home/games/widgets/math_sprint/math_sprint_scoreboard.dart';
import 'package:schoolhq_ng/views/home/games/widgets/math_sprint/math_sprint_summary_card.dart';

const _gameSeconds = 60;

enum _SprintStatus { idle, playing, finished }

class MathSprintScreen extends ConsumerStatefulWidget {
  const MathSprintScreen({super.key});

  @override
  ConsumerState<MathSprintScreen> createState() => _MathSprintScreenState();
}

class _MathSprintScreenState extends ConsumerState<MathSprintScreen> {
  final Random _random = Random();

  Timer? _timer;
  Timer? _answerTimer;
  late MathSprintQuestionModel _question;

  _SprintStatus _status = _SprintStatus.idle;
  int _timeLeft = _gameSeconds;
  int _round = 1;
  int _score = 0;
  int _correct = 0;
  int _attempted = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int? _selectedChoice;
  String? _feedbackMessage;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    _question = MathSprintQuestionModel.generate(1, _random);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerTimer?.cancel();
    super.dispose();
  }

  void _startSprint() {
    _timer?.cancel();
    _answerTimer?.cancel();

    setState(() {
      _status = _SprintStatus.playing;
      _timeLeft = _gameSeconds;
      _round = 1;
      _score = 0;
      _correct = 0;
      _attempted = 0;
      _streak = 0;
      _bestStreak = 0;
      _selectedChoice = null;
      _feedbackMessage = null;
      _feedbackColor = null;
      _question = MathSprintQuestionModel.generate(1, _random);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_timeLeft <= 1) {
        timer.cancel();
        _answerTimer?.cancel();
        setState(() {
          _timeLeft = 0;
          _status = _SprintStatus.finished;
          _selectedChoice = null;
          _feedbackMessage = 'Time is up. Final sprint complete.';
          _feedbackColor = AppColors.warning;
        });
        return;
      }

      setState(() {
        _timeLeft -= 1;
      });
    });
  }

  void _selectAnswer(int choice) {
    if (_status != _SprintStatus.playing || _selectedChoice != null) return;

    setState(() {
      _selectedChoice = choice;
      _attempted += 1;
    });

    final isCorrect = choice == _question.answer;
    final reward = isCorrect ? 10 + min(_streak, 4) * 2 : 0;
    final nextStreak = isCorrect ? _streak + 1 : 0;

    setState(() {
      if (isCorrect) {
        _score += reward;
        _correct += 1;
        _streak = nextStreak;
        _bestStreak = max(_bestStreak, nextStreak);
        _feedbackMessage = 'Correct! +$reward points.';
        _feedbackColor = AppColors.success;
      } else {
        _streak = 0;
        _feedbackMessage =
            'Not quite. ${_question.expression} = ${_question.answer}.';
        _feedbackColor = AppColors.error;
      }
    });

    _answerTimer?.cancel();
    final nextRound = _round + 1;
    _answerTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted || _status != _SprintStatus.playing) return;

      setState(() {
        _round = nextRound;
        _question = MathSprintQuestionModel.generate(nextRound, _random);
        _selectedChoice = null;
        _feedbackMessage = null;
        _feedbackColor = null;
      });
    });
  }

  void _goBackToGames() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(RouteNames.games);
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final role = ref.watch(currentUserRoleProvider);
    final accuracy = _attempted == 0
        ? 0
        : ((_correct / _attempted) * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          Positioned(
            top: -36,
            right: -32,
            child: _Glow(
              size: 150,
              colors: const [Color(0xFF818CF8), Color(0xFF22D3EE)],
            ),
          ),
          Positioned(
            left: -36,
            bottom: 200,
            child: _Glow(
              size: 120,
              colors: const [Color(0xFFEC4899), Color(0xFFF472B6)],
            ),
          ),
          SafeArea(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 20,
                compact ? 16 : 20,
                compact ? 16 : 20,
                compact ? 24 : 28,
              ),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _goBackToGames,
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.surfaceMuted),
                      ),
                      child: Text(
                        'Math Sprint',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        role == 'teacher'
                            ? 'Teacher warm-up'
                            : 'Student challenge',
                        style: AppTextStyles.small.copyWith(
                          color: const Color(0xFF0369A1),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 12 : 16),
                MathSprintBannerCard(
                  role: role,
                  isPlaying: _status == _SprintStatus.playing,
                  isFinished: _status == _SprintStatus.finished,
                  round: _round,
                  timeLeft: _timeLeft,
                  onStart: _startSprint,
                  onRestart: _startSprint,
                ),
                SizedBox(height: compact ? 12 : 16),
                MathSprintScoreboard(
                  score: _score,
                  streak: _streak,
                  bestStreak: _bestStreak,
                  timeLeft: _timeLeft,
                ),
                SizedBox(height: compact ? 12 : 16),
                MathSprintQuestionCard(
                  question: _question,
                  isPlaying: _status == _SprintStatus.playing,
                  feedbackMessage: _feedbackMessage,
                  feedbackColor: _feedbackColor,
                ),
                SizedBox(height: compact ? 10 : 12),
                MathSprintChoiceGrid(
                  question: _question,
                  isPlaying: _status == _SprintStatus.playing,
                  selectedChoice: _selectedChoice,
                  onChoiceSelected: _selectAnswer,
                ),
                if (_status == _SprintStatus.finished) ...[
                  SizedBox(height: compact ? 12 : 16),
                  MathSprintSummaryCard(
                    score: _score,
                    correct: _correct,
                    attempted: _attempted,
                    accuracy: accuracy,
                    bestStreak: _bestStreak,
                    onRestart: _startSprint,
                    onBackToGames: _goBackToGames,
                  ),
                ] else ...[
                  SizedBox(height: compact ? 12 : 16),
                  Container(
                    padding: EdgeInsets.all(compact ? 14 : 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.surfaceMuted),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.lightbulb_rounded,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: compact ? 10 : 12),
                        Expanded(
                          child: Text(
                            _status == _SprintStatus.playing
                                ? 'Keep moving. A new round appears immediately after each answer.'
                                : 'Tap start when you are ready. The sprint launches instantly.',
                            style: AppTextStyles.body.copyWith(
                              fontSize: compact ? 14 : 16,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _Glow({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors.map((color) => color.withOpacity(0.18)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
