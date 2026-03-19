Map<String, dynamic> resultsAsMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> resultsAsList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

List<Map<String, dynamic>> resultsTermsForSession(Map<String, dynamic>? session) {
  if (session == null) return const [];
  final terms = (session['terms'] as List?) ?? const [];
  return terms
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

double resultsNum(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? 0}') ?? 0;
}

double resultsAverageTotal(List<Map<String, dynamic>> scores) {
  if (scores.isEmpty) return 0;
  final total = scores.fold<double>(
    0,
    (sum, score) => sum + resultsNum(score['total']),
  );
  return total / scores.length;
}
