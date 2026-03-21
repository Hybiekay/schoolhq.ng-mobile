import 'dart:math';

class WordBuilderLetterTile {
  final int id;
  final String letter;

  const WordBuilderLetterTile({required this.id, required this.letter});
}

class WordBuilderPuzzleSeed {
  final String word;
  final String category;
  final String hint;
  final int extraLetters;
  final int minRound;
  final int maxRound;

  const WordBuilderPuzzleSeed({
    required this.word,
    required this.category,
    required this.hint,
    required this.extraLetters,
    required this.minRound,
    required this.maxRound,
  });

  bool matchesRound(int round) {
    return round >= minRound && round <= maxRound;
  }
}

class WordBuilderPuzzleModel {
  final int round;
  final String word;
  final String category;
  final String hint;
  final List<WordBuilderLetterTile> tiles;

  const WordBuilderPuzzleModel({
    required this.round,
    required this.word,
    required this.category,
    required this.hint,
    required this.tiles,
  });

  String get displayWord => word.toUpperCase();

  int get letterCount => word.length;

  factory WordBuilderPuzzleModel.generate(int round, Random random) {
    final seed = _pickSeed(round, random);
    final normalizedWord = seed.word.trim().toLowerCase();
    final letters = normalizedWord.toUpperCase().split('');
    final decoys = _buildDecoyLetters(
      word: normalizedWord,
      count: seed.extraLetters + (round >= 8 ? 1 : 0),
      random: random,
    );

    final tiles = <WordBuilderLetterTile>[
      for (var i = 0; i < letters.length; i++)
        WordBuilderLetterTile(id: i, letter: letters[i]),
      for (var i = 0; i < decoys.length; i++)
        WordBuilderLetterTile(id: letters.length + i, letter: decoys[i]),
    ]..shuffle(random);

    return WordBuilderPuzzleModel(
      round: round,
      word: normalizedWord,
      category: seed.category,
      hint: seed.hint,
      tiles: tiles,
    );
  }

  static WordBuilderPuzzleSeed _pickSeed(int round, Random random) {
    final candidates = wordBuilderPuzzleBank
        .where((seed) => seed.matchesRound(round))
        .toList();
    final pool = candidates.isEmpty ? wordBuilderPuzzleBank : candidates;
    return pool[random.nextInt(pool.length)];
  }

  static List<String> _buildDecoyLetters({
    required String word,
    required int count,
    required Random random,
  }) {
    final blockedLetters = word.toUpperCase().split('').toSet();
    final alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    final pool =
        alphabet.where((letter) => !blockedLetters.contains(letter)).toList()
          ..shuffle(random);

    final decoys = <String>[];
    while (decoys.length < count) {
      if (pool.isEmpty) {
        pool.addAll(
          alphabet.where((letter) => !blockedLetters.contains(letter)),
        );
        pool.shuffle(random);
      }

      decoys.add(pool.removeLast());
    }

    return decoys;
  }
}

const wordBuilderPuzzleBank = <WordBuilderPuzzleSeed>[
  WordBuilderPuzzleSeed(
    word: 'book',
    category: 'Reading',
    hint: 'A bundle of pages bound together.',
    extraLetters: 2,
    minRound: 1,
    maxRound: 3,
  ),
  WordBuilderPuzzleSeed(
    word: 'quiz',
    category: 'Assessment',
    hint: 'A quick check of what you know.',
    extraLetters: 2,
    minRound: 1,
    maxRound: 3,
  ),
  WordBuilderPuzzleSeed(
    word: 'class',
    category: 'School Life',
    hint: 'Where the lesson happens.',
    extraLetters: 2,
    minRound: 1,
    maxRound: 4,
  ),
  WordBuilderPuzzleSeed(
    word: 'notes',
    category: 'Study Skill',
    hint: 'Short reminders to remember later.',
    extraLetters: 2,
    minRound: 1,
    maxRound: 4,
  ),
  WordBuilderPuzzleSeed(
    word: 'school',
    category: 'Campus Life',
    hint: 'The place where learning happens.',
    extraLetters: 3,
    minRound: 1,
    maxRound: 5,
  ),
  WordBuilderPuzzleSeed(
    word: 'future',
    category: 'Vision',
    hint: 'The days ahead.',
    extraLetters: 3,
    minRound: 1,
    maxRound: 5,
  ),
  WordBuilderPuzzleSeed(
    word: 'reading',
    category: 'Literacy',
    hint: 'Turning symbols into meaning.',
    extraLetters: 3,
    minRound: 1,
    maxRound: 5,
  ),
  WordBuilderPuzzleSeed(
    word: 'planet',
    category: 'Science',
    hint: 'A world that orbits a star.',
    extraLetters: 3,
    minRound: 2,
    maxRound: 5,
  ),
  WordBuilderPuzzleSeed(
    word: 'teacher',
    category: 'Classroom',
    hint: 'The person who leads the lesson.',
    extraLetters: 3,
    minRound: 3,
    maxRound: 6,
  ),
  WordBuilderPuzzleSeed(
    word: 'library',
    category: 'Literacy',
    hint: 'A quiet place full of books.',
    extraLetters: 3,
    minRound: 3,
    maxRound: 6,
  ),
  WordBuilderPuzzleSeed(
    word: 'project',
    category: 'Assignment',
    hint: 'A piece of work built over time.',
    extraLetters: 3,
    minRound: 3,
    maxRound: 6,
  ),
  WordBuilderPuzzleSeed(
    word: 'chapter',
    category: 'Reading',
    hint: 'A section of a book.',
    extraLetters: 3,
    minRound: 4,
    maxRound: 7,
  ),
  WordBuilderPuzzleSeed(
    word: 'science',
    category: 'STEM',
    hint: 'The study of how things work.',
    extraLetters: 3,
    minRound: 4,
    maxRound: 7,
  ),
  WordBuilderPuzzleSeed(
    word: 'balance',
    category: 'Math',
    hint: 'A steady, even state.',
    extraLetters: 3,
    minRound: 4,
    maxRound: 7,
  ),
  WordBuilderPuzzleSeed(
    word: 'curious',
    category: 'Growth',
    hint: 'Wanting to learn more.',
    extraLetters: 4,
    minRound: 5,
    maxRound: 8,
  ),
  WordBuilderPuzzleSeed(
    word: 'equation',
    category: 'Math',
    hint: 'A statement with equal parts.',
    extraLetters: 4,
    minRound: 5,
    maxRound: 8,
  ),
  WordBuilderPuzzleSeed(
    word: 'language',
    category: 'Literacy',
    hint: 'Words people use to communicate.',
    extraLetters: 4,
    minRound: 5,
    maxRound: 8,
  ),
  WordBuilderPuzzleSeed(
    word: 'discover',
    category: 'Exploration',
    hint: 'Find something new.',
    extraLetters: 4,
    minRound: 6,
    maxRound: 9,
  ),
  WordBuilderPuzzleSeed(
    word: 'strategy',
    category: 'Thinking',
    hint: 'A smart plan for a goal.',
    extraLetters: 4,
    minRound: 6,
    maxRound: 9,
  ),
  WordBuilderPuzzleSeed(
    word: 'teamwork',
    category: 'Collaboration',
    hint: 'People working together.',
    extraLetters: 4,
    minRound: 6,
    maxRound: 9,
  ),
  WordBuilderPuzzleSeed(
    word: 'vocabulary',
    category: 'Language',
    hint: 'The words you know and use.',
    extraLetters: 4,
    minRound: 7,
    maxRound: 10,
  ),
  WordBuilderPuzzleSeed(
    word: 'brilliant',
    category: 'Achievement',
    hint: 'Full of shining skill.',
    extraLetters: 4,
    minRound: 7,
    maxRound: 10,
  ),
  WordBuilderPuzzleSeed(
    word: 'momentum',
    category: 'Progress',
    hint: 'Moving force that keeps going.',
    extraLetters: 4,
    minRound: 8,
    maxRound: 12,
  ),
];
