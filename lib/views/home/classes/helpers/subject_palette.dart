import 'package:flutter/material.dart';

class SubjectPalette {
  final LinearGradient gradient;
  final Color primary;
  final Color soft;

  const SubjectPalette({
    required this.gradient,
    required this.primary,
    required this.soft,
  });
}

const List<SubjectPalette> _palettes = [
  SubjectPalette(
    gradient: LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primary: Color(0xFF5B5CEB),
    soft: Color(0xFFEEF2FF),
  ),
  SubjectPalette(
    gradient: LinearGradient(
      colors: [Color(0xFFEC4899), Color(0xFFF97316)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primary: Color(0xFFEC4899),
    soft: Color(0xFFFDF2F8),
  ),
  SubjectPalette(
    gradient: LinearGradient(
      colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primary: Color(0xFF0891B2),
    soft: Color(0xFFECFEFF),
  ),
  SubjectPalette(
    gradient: LinearGradient(
      colors: [Color(0xFF22C55E), Color(0xFF14B8A6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primary: Color(0xFF16A34A),
    soft: Color(0xFFF0FDF4),
  ),
];

SubjectPalette paletteForIndex(dynamic rawIndex) {
  final index = rawIndex is num
      ? rawIndex.toInt()
      : int.tryParse(rawIndex?.toString() ?? '') ?? 0;
  return _palettes[index % _palettes.length];
}
