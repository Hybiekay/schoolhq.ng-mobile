import 'dart:math';

class MathSprintQuestionModel {
  final int round;
  final int left;
  final int right;
  final String operator;
  final int answer;
  final List<int> choices;

  const MathSprintQuestionModel({
    required this.round,
    required this.left,
    required this.right,
    required this.operator,
    required this.answer,
    required this.choices,
  });

  factory MathSprintQuestionModel.fromJson(Map<String, dynamic> json) {
    return MathSprintQuestionModel(
      round: ((json['round'] ?? 0) as num).toInt(),
      left: ((json['left'] ?? 0) as num).toInt(),
      right: ((json['right'] ?? 0) as num).toInt(),
      operator: (json['operator'] ?? '+').toString(),
      answer: ((json['answer'] ?? 0) as num).toInt(),
      choices: (json['choices'] as List? ?? const [])
          .map((value) => (value as num).toInt())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'round': round,
    'left': left,
    'right': right,
    'operator': operator,
    'answer': answer,
    'choices': choices,
  };

  factory MathSprintQuestionModel.generate(int round, Random random) {
    const operators = ['+', '-', '×'];
    final operator = operators[random.nextInt(operators.length)];

    late final int left;
    late final int right;
    late final int answer;

    switch (operator) {
      case '+':
        left = random.nextInt(25) + 4;
        right = random.nextInt(23) + 2;
        answer = left + right;
        break;
      case '-':
        left = random.nextInt(39) + 10;
        right = random.nextInt(left - 1) + 1;
        answer = left - right;
        break;
      default:
        left = random.nextInt(11) + 2;
        right = random.nextInt(11) + 2;
        answer = left * right;
        break;
    }

    return MathSprintQuestionModel(
      round: round,
      left: left,
      right: right,
      operator: operator,
      answer: answer,
      choices: _buildChoices(answer, random),
    );
  }

  String get expression => '$left $operator $right';

  String get prompt => 'What is $expression?';

  static List<int> _buildChoices(int answer, Random random) {
    final choices = <int>{answer};

    while (choices.length < 4) {
      final spread = answer < 10 ? 8 : 14;
      final delta = random.nextInt(spread) + 1;
      final candidate = answer + (random.nextBool() ? delta : -delta);
      choices.add(candidate < 0 ? 0 : candidate);
    }

    final shuffled = choices.toList();
    shuffled.shuffle(random);
    return shuffled;
  }
}
