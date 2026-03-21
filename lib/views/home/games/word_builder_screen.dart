import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/models/word_builder_puzzle_model.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';

const _gameSeconds = 75;

enum _WordBuilderStatus { idle, playing, finished }

class WordBuilderScreen extends ConsumerStatefulWidget {
  const WordBuilderScreen({super.key});

  @override
  ConsumerState<WordBuilderScreen> createState() => _WordBuilderScreenState();
}

class _WordBuilderScreenState extends ConsumerState<WordBuilderScreen> {
  final Random _random = Random();

  Timer? _timer;
  Timer? _advanceTimer;
  late WordBuilderPuzzleModel _puzzle;
  List<WordBuilderLetterTile> _tiles = [];
  List<int> _selectedTileIds = [];

  _WordBuilderStatus _status = _WordBuilderStatus.idle;
  int _timeLeft = _gameSeconds;
  int _round = 1;
  int _score = 0;
  int _solved = 0;
  int _attempted = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _mistakes = 0;
  String? _feedbackMessage;
  Color? _feedbackColor;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _loadPuzzle(round: 1);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _loadPuzzle({required int round}) {
    _puzzle = WordBuilderPuzzleModel.generate(round, _random);
    _tiles = List<WordBuilderLetterTile>.from(_puzzle.tiles);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_timeLeft <= 1) {
        timer.cancel();
        _advanceTimer?.cancel();
        setState(() {
          _timeLeft = 0;
          _status = _WordBuilderStatus.finished;
          _selectedTileIds = [];
          _isTransitioning = false;
          _feedbackMessage = 'Time is up. Your builder run is locked in.';
          _feedbackColor = AppColors.warning;
        });
        return;
      }

      setState(() {
        _timeLeft -= 1;
      });
    });
  }

  void _startBuilder() {
    _advanceTimer?.cancel();

    setState(() {
      _status = _WordBuilderStatus.playing;
      _timeLeft = _gameSeconds;
      _round = 1;
      _score = 0;
      _solved = 0;
      _attempted = 0;
      _streak = 0;
      _bestStreak = 0;
      _mistakes = 0;
      _selectedTileIds = [];
      _feedbackMessage = null;
      _feedbackColor = null;
      _isTransitioning = false;
      _loadPuzzle(round: 1);
    });

    _startTimer();
  }

  void _advancePuzzle() {
    if (!mounted || _status != _WordBuilderStatus.playing) return;

    setState(() {
      _round += 1;
      _selectedTileIds = [];
      _feedbackMessage = null;
      _feedbackColor = null;
      _isTransitioning = false;
      _loadPuzzle(round: _round);
    });
  }

  void _selectTile(int tileId) {
    if (_status != _WordBuilderStatus.playing ||
        _isTransitioning ||
        _selectedTileIds.contains(tileId)) {
      return;
    }

    setState(() {
      _selectedTileIds.add(tileId);
      _feedbackMessage = null;
      _feedbackColor = null;
    });
  }

  void _removeTile(int tileId) {
    if (_status != _WordBuilderStatus.playing || _isTransitioning) return;

    setState(() {
      _selectedTileIds.remove(tileId);
      _feedbackMessage = null;
      _feedbackColor = null;
    });
  }

  void _clearSelection() {
    if (_status != _WordBuilderStatus.playing || _isTransitioning) return;

    setState(() {
      _selectedTileIds = [];
      _feedbackMessage = null;
      _feedbackColor = null;
    });
  }

  void _shuffleTiles() {
    if (_status != _WordBuilderStatus.playing || _isTransitioning) return;

    setState(() {
      _tiles.shuffle(_random);
      _feedbackMessage = null;
      _feedbackColor = null;
    });
  }

  void _submitWord() {
    if (_status != _WordBuilderStatus.playing ||
        _isTransitioning ||
        _selectedTileIds.length != _puzzle.letterCount) {
      return;
    }

    final tileById = {for (final tile in _tiles) tile.id: tile};
    final candidate = _selectedTileIds
        .map((id) => tileById[id]?.letter ?? '')
        .join()
        .toLowerCase();

    setState(() {
      _attempted += 1;
    });

    if (candidate == _puzzle.word) {
      final bonus = (_timeLeft / 8).floor();
      final reward = 12 + _puzzle.letterCount * 2 + min(_streak, 5) * 3 + bonus;
      final nextStreak = _streak + 1;

      setState(() {
        _score += reward;
        _solved += 1;
        _streak = nextStreak;
        _bestStreak = max(_bestStreak, nextStreak);
        _feedbackMessage = 'Correct! +$reward points.';
        _feedbackColor = AppColors.success;
        _isTransitioning = true;
      });

      _advanceTimer?.cancel();
      _advanceTimer = Timer(const Duration(milliseconds: 800), _advancePuzzle);
      return;
    }

    setState(() {
      _mistakes += 1;
      _streak = 0;
      _feedbackMessage = 'Not quite. Rearrange the letters and try again.';
      _feedbackColor = AppColors.error;
    });
  }

  void _goBackToGames() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(RouteNames.games);
  }

  List<WordBuilderLetterTile> get _selectedTiles {
    final tileById = {for (final tile in _tiles) tile.id: tile};
    return _selectedTileIds.map((id) => tileById[id]!).toList();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final role = ref.watch(currentUserRoleProvider);
    final accuracy = _attempted == 0
        ? 0
        : ((_solved / _attempted) * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF8),
      body: Stack(
        children: [
          Positioned(
            top: -36,
            right: -32,
            child: _Glow(
              size: 150,
              colors: const [Color(0xFF10B981), Color(0xFF22D3EE)],
            ),
          ),
          Positioned(
            left: -36,
            bottom: 180,
            child: _Glow(
              size: 120,
              colors: const [Color(0xFFF59E0B), Color(0xFF34D399)],
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
                        'Word Builder',
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
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      _BannerCard(
                        role: role,
                        isActive: _status == _WordBuilderStatus.playing,
                        isFinished: _status == _WordBuilderStatus.finished,
                        round: _round,
                        timeLeft: _timeLeft,
                        onStart: _startBuilder,
                        onRestart: _startBuilder,
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      _Scoreboard(
                        score: _score,
                        solved: _solved,
                        streak: _streak,
                        bestStreak: _bestStreak,
                        timeLeft: _timeLeft,
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      _ChallengeCard(
                        puzzle: _puzzle,
                        isPlaying: _status == _WordBuilderStatus.playing,
                        selectedCount: _selectedTileIds.length,
                        feedbackMessage: _feedbackMessage,
                        feedbackColor: _feedbackColor,
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      _AnswerRack(
                        puzzle: _puzzle,
                        selectedTiles: _selectedTiles,
                        isPlaying: _status == _WordBuilderStatus.playing,
                        onTileRemoved: _removeTile,
                        onClear: _clearSelection,
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      _LetterGrid(
                        tiles: _tiles,
                        selectedTileIds: _selectedTileIds.toSet(),
                        isPlaying: _status == _WordBuilderStatus.playing,
                        isLocked: _isTransitioning,
                        onTileSelected: _selectTile,
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      _ActionBar(
                        isPlaying: _status == _WordBuilderStatus.playing,
                        hasSelection: _selectedTileIds.isNotEmpty,
                        canSubmit:
                            _selectedTileIds.length == _puzzle.letterCount,
                        onShuffle: _shuffleTiles,
                        onClear: _clearSelection,
                        onSubmit: _submitWord,
                      ),
                      if (_status == _WordBuilderStatus.finished) ...[
                        SizedBox(height: compact ? 12 : 16),
                        _SummaryCard(
                          score: _score,
                          solved: _solved,
                          attempted: _attempted,
                          accuracy: accuracy,
                          bestStreak: _bestStreak,
                          mistakes: _mistakes,
                          onRestart: _startBuilder,
                          onBackToGames: _goBackToGames,
                        ),
                      ] else ...[
                        SizedBox(height: compact ? 12 : 16),
                        _TipCard(
                          message: _status == _WordBuilderStatus.playing
                              ? 'Build the answer one letter at a time. Use shuffle if you want a fresh angle.'
                              : 'Tap start when you are ready. The builder launches instantly on mobile and web.',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final String role;
  final bool isActive;
  final bool isFinished;
  final int round;
  final int timeLeft;
  final VoidCallback onStart;
  final VoidCallback onRestart;

  const _BannerCard({
    required this.role,
    required this.isActive,
    required this.isFinished,
    required this.round,
    required this.timeLeft,
    required this.onStart,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final copy = role == 'teacher'
        ? 'Use this as a fast literacy warm-up before class or a sharp revision burst between lessons.'
        : 'Build words fast, keep your vocabulary hot, and stay locked into the streak.';

    final actionLabel = isFinished
        ? 'Play again'
        : isActive
        ? 'Restart builder'
        : 'Start builder';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0F766E), Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -24,
            child: _GlowDot(size: 118, opacity: 0.12),
          ),
          Positioned(
            left: -18,
            bottom: -18,
            child: _GlowDot(size: 88, opacity: 0.08),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isFinished
                            ? 'Builder complete'
                            : isActive
                            ? 'Builder active'
                            : 'Ready to build',
                        style: AppTextStyles.small.copyWith(
                          color: Colors.white,
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
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${timeLeft}s left',
                        style: AppTextStyles.small.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 10 : 14),
                Text(
                  'Word Builder',
                  style: AppTextStyles.headingLarge.copyWith(
                    fontSize: compact ? 22 : 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: compact ? 6 : 8),
                Text(
                  copy,
                  style: AppTextStyles.body.copyWith(
                    fontSize: compact ? 13 : 16,
                    color: Colors.white.withOpacity(0.84),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: compact ? 12 : 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: const [
                    _HeroChip(
                      icon: Icons.text_fields_rounded,
                      label: 'Tap letters',
                    ),
                    _HeroChip(
                      icon: Icons.shuffle_rounded,
                      label: 'Shuffle grid',
                    ),
                    _HeroChip(
                      icon: Icons.language_rounded,
                      label: 'Mobile + web',
                    ),
                  ],
                ),
                SizedBox(height: compact ? 14 : 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isActive ? onRestart : onStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: compact ? 12 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: Icon(
                          isActive
                              ? Icons.refresh_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          actionLabel,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (isActive) ...[
                      SizedBox(width: compact ? 10 : 12),
                      TextButton(
                        onPressed: onRestart,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: compact ? 12 : 14,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                        ),
                        child: Text(
                          'Reset',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isActive) ...[
                  SizedBox(height: compact ? 8 : 10),
                  Text(
                    'Round $round is live. Assemble the right word and submit it before the timer runs out.',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.75),
                      height: 1.4,
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

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
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

class _GlowDot extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlowDot({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  final int score;
  final int solved;
  final int streak;
  final int bestStreak;
  final int timeLeft;

  const _Scoreboard({
    required this.score,
    required this.solved,
    required this.streak,
    required this.bestStreak,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceMuted),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: compact ? 10 : 12,
        crossAxisSpacing: compact ? 10 : 12,
        childAspectRatio: compact ? 1.88 : 1.68,
        children: [
          _StatTile(
            icon: Icons.emoji_events_rounded,
            label: 'Score',
            value: '$score',
            accent: const Color(0xFF0F766E),
          ),
          _StatTile(
            icon: Icons.spellcheck_rounded,
            label: 'Words',
            value: '$solved',
            accent: const Color(0xFF16A34A),
          ),
          _StatTile(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '$streak',
            accent: const Color(0xFFF59E0B),
          ),
          _StatTile(
            icon: Icons.timer_rounded,
            label: 'Time left',
            value: '$timeLeft s',
            accent: const Color(0xFF06B6D4),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 38 : 42,
            height: compact ? 38 : 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final WordBuilderPuzzleModel puzzle;
  final bool isPlaying;
  final int selectedCount;
  final String? feedbackMessage;
  final Color? feedbackColor;

  const _ChallengeCard({
    required this.puzzle,
    required this.isPlaying,
    required this.selectedCount,
    required this.feedbackMessage,
    required this.feedbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final progress = puzzle.letterCount == 0
        ? 0.0
        : selectedCount / puzzle.letterCount;
    final borderColor =
        feedbackColor?.withOpacity(0.2) ?? AppColors.surfaceMuted;

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Round ${puzzle.round}',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 11,
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
                  color: isPlaying
                      ? const Color(0xFFE0F2FE)
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isPlaying ? 'Live word' : 'Ready',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 11,
                    color: isPlaying
                        ? const Color(0xFF0369A1)
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 18),
          Text(
            'Decode the clue',
            style: AppTextStyles.headingLarge.copyWith(
              fontSize: compact ? 22 : 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            'Use the hint, assemble the letters in order, and submit the completed word.',
            style: AppTextStyles.subtitle.copyWith(fontSize: compact ? 12 : 14),
          ),
          SizedBox(height: compact ? 14 : 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.category_outlined, label: puzzle.category),
              _InfoChip(
                icon: Icons.short_text_rounded,
                label: '${puzzle.letterCount} letters',
              ),
              _InfoChip(
                icon: Icons.auto_awesome_rounded,
                label: '$selectedCount/${puzzle.letterCount} placed',
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 18),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 14 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hint',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF0F766E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  puzzle.hint,
                  style: AppTextStyles.body.copyWith(
                    fontSize: compact ? 14 : 16,
                    color: AppColors.textPrimary,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 14 : 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF14B8A6)),
            ),
          ),
          SizedBox(height: compact ? 8 : 10),
          Row(
            children: [
              Text(
                '${(progress.clamp(0.0, 1.0) * 100).round()}% filled',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                isPlaying
                    ? 'Tap letters to build'
                    : 'Start the builder to begin',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (feedbackMessage != null) ...[
            SizedBox(height: compact ? 12 : 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(compact ? 12 : 14),
              decoration: BoxDecoration(
                color: (feedbackColor ?? AppColors.primary).withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                feedbackMessage!,
                style: AppTextStyles.body.copyWith(
                  fontSize: compact ? 14 : 16,
                  color: feedbackColor ?? AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerRack extends StatelessWidget {
  final WordBuilderPuzzleModel puzzle;
  final List<WordBuilderLetterTile> selectedTiles;
  final bool isPlaying;
  final ValueChanged<int> onTileRemoved;
  final VoidCallback onClear;

  const _AnswerRack({
    required this.puzzle,
    required this.selectedTiles,
    required this.isPlaying,
    required this.onTileRemoved,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceMuted),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your word',
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: isPlaying && selectedTiles.isNotEmpty
                    ? onClear
                    : null,
                child: Text(
                  'Clear',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(puzzle.letterCount, (index) {
              if (index < selectedTiles.length) {
                final tile = selectedTiles[index];
                return _FilledSlot(
                  letter: tile.letter,
                  position: index + 1,
                  onTap: () => onTileRemoved(tile.id),
                );
              }

              return _EmptySlot(position: index + 1);
            }),
          ),
          SizedBox(height: compact ? 10 : 12),
          Text(
            isPlaying
                ? 'Tap any filled slot to remove that letter.'
                : 'Start the builder to unlock the answer rack.',
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilledSlot extends StatelessWidget {
  final String letter;
  final int position;
  final VoidCallback onTap;

  const _FilledSlot({
    required this.letter,
    required this.position,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: compact ? 50 : 56,
          height: compact ? 58 : 62,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF22C55E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14B8A6).withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  letter,
                  style: AppTextStyles.headingLarge.copyWith(
                    fontSize: compact ? 22 : 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
              Positioned(
                left: 6,
                bottom: 5,
                child: Text(
                  '$position',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final int position;

  const _EmptySlot({required this.position});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Container(
      width: compact ? 50 : 56,
      height: compact ? 58 : 62,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grey.withOpacity(0.9)),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '_',
              style: AppTextStyles.headingLarge.copyWith(
                fontSize: compact ? 20 : 22,
                color: AppColors.grey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            left: 6,
            bottom: 5,
            child: Text(
              '$position',
              style: AppTextStyles.small.copyWith(
                fontSize: 9,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterGrid extends StatelessWidget {
  final List<WordBuilderLetterTile> tiles;
  final Set<int> selectedTileIds;
  final bool isPlaying;
  final bool isLocked;
  final ValueChanged<int> onTileSelected;

  const _LetterGrid({
    required this.tiles,
    required this.selectedTileIds,
    required this.isPlaying,
    required this.isLocked,
    required this.onTileSelected,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 380;
    final crossAxisCount = width >= 900
        ? 5
        : width >= 640
        ? 4
        : 3;

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceMuted),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Letter bank',
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isPlaying
                      ? const Color(0xFFE0F2FE)
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isPlaying ? 'Tap to place' : 'Locked',
                  style: AppTextStyles.small.copyWith(
                    color: isPlaying
                        ? const Color(0xFF0369A1)
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 12),
          GridView.builder(
            itemCount: tiles.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: compact ? 10 : 12,
              crossAxisSpacing: compact ? 10 : 12,
              childAspectRatio: width >= 900
                  ? 1.15
                  : compact
                  ? 0.98
                  : 1.02,
            ),
            itemBuilder: (context, index) {
              final tile = tiles[index];
              final isSelected = selectedTileIds.contains(tile.id);
              final locked = !isPlaying || isLocked || isSelected;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: locked ? null : () => onTileSelected(tile.id),
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF0F766E), Color(0xFF22C55E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : isPlaying
                          ? const Color(0xFFF8FAFC)
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.grey.withOpacity(0.75),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF14B8A6).withOpacity(0.18)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            tile.letter,
                            style: AppTextStyles.headingLarge.copyWith(
                              fontSize: compact ? 24 : 26,
                              color: isSelected
                                  ? Colors.white
                                  : isPlaying
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.add_circle_outline_rounded,
                            size: 16,
                            color: isSelected
                                ? Colors.white.withOpacity(0.9)
                                : AppColors.textSecondary.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: compact ? 10 : 12),
          Text(
            isPlaying
                ? 'Use the grid like tiles on a table. Selected letters stay locked until you remove them.'
                : 'Start the builder to unlock the letter bank.',
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool isPlaying;
  final bool hasSelection;
  final bool canSubmit;
  final VoidCallback onShuffle;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const _ActionBar({
    required this.isPlaying,
    required this.hasSelection,
    required this.canSubmit,
    required this.onShuffle,
    required this.onClear,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceMuted),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Word tools',
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: compact ? 18 : 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: compact ? 8 : 10),
          Text(
            isPlaying
                ? 'Shuffle the board if the letters feel stuck, clear the rack when you want a fresh start, then submit the word.'
                : 'The tools unlock once the builder starts.',
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: compact ? 14 : 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionButton(
                icon: Icons.shuffle_rounded,
                label: 'Shuffle board',
                onPressed: isPlaying ? onShuffle : null,
                filled: false,
              ),
              _ActionButton(
                icon: Icons.backspace_outlined,
                label: 'Clear word',
                onPressed: isPlaying && hasSelection ? onClear : null,
                filled: false,
              ),
              _ActionButton(
                icon: Icons.send_rounded,
                label: 'Submit word',
                onPressed: isPlaying && canSubmit ? onSubmit : null,
                filled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    final enabled = onPressed != null;

    final button = filled
        ? ElevatedButton.icon(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled
                  ? const Color(0xFF0F766E)
                  : AppColors.surfaceMuted,
              foregroundColor: enabled ? Colors.white : AppColors.textSecondary,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                vertical: compact ? 12 : 14,
                horizontal: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: Icon(icon),
            label: Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: enabled ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: enabled
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              backgroundColor: enabled ? Colors.white : AppColors.surfaceMuted,
              side: BorderSide(
                color: enabled
                    ? AppColors.surfaceMuted
                    : AppColors.surfaceMuted.withOpacity(0.7),
              ),
              padding: EdgeInsets.symmetric(
                vertical: compact ? 12 : 14,
                horizontal: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: Icon(icon),
            label: Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: enabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          );

    return compact ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class _SummaryCard extends StatelessWidget {
  final int score;
  final int solved;
  final int attempted;
  final int accuracy;
  final int bestStreak;
  final int mistakes;
  final VoidCallback onRestart;
  final VoidCallback onBackToGames;

  const _SummaryCard({
    required this.score,
    required this.solved,
    required this.attempted,
    required this.accuracy,
    required this.bestStreak,
    required this.mistakes,
    required this.onRestart,
    required this.onBackToGames,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Builder complete',
                    style: AppTextStyles.small.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 10 : 14),
                Text(
                  'Great word work. Keep the streak alive.',
                  style: AppTextStyles.headingLarge.copyWith(
                    fontSize: compact ? 22 : 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: compact ? 6 : 8),
                Text(
                  'Your last run is locked in below. Play again to chase a higher score or smoother accuracy.',
                  style: AppTextStyles.body.copyWith(
                    fontSize: compact ? 13 : 16,
                    color: Colors.white.withOpacity(0.82),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: compact ? 14 : 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SummaryChip(label: 'Score', value: '$score'),
                    _SummaryChip(label: 'Words', value: '$solved'),
                    _SummaryChip(label: 'Attempts', value: '$attempted'),
                    _SummaryChip(label: 'Mistakes', value: '$mistakes'),
                    _SummaryChip(label: 'Accuracy', value: '$accuracy%'),
                    _SummaryChip(label: 'Best streak', value: '$bestStreak'),
                  ],
                ),
                SizedBox(height: compact ? 14 : 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onRestart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: compact ? 12 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          'Play again',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: compact ? 10 : 12),
                    Expanded(
                      child: TextButton(
                        onPressed: onBackToGames,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: compact ? 12 : 14,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                        ),
                        child: Text(
                          'Back to games',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontSize: 11,
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String message;

  const _TipCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Container(
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
                colors: [Color(0xFF0F766E), Color(0xFF22C55E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Colors.white),
          ),
          SizedBox(width: compact ? 10 : 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(
                fontSize: compact ? 14 : 16,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
