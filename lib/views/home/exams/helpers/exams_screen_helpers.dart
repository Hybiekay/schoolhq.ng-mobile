import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

List<Map<String, dynamic>> examsExtractExams(Map<String, dynamic> data) {
  final candidate = data['data'] ?? data['exams'];
  if (candidate is! List) return const [];
  return candidate
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Map<String, dynamic> examsAsMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

String examsStatusLabel(String status) {
  return status.toLowerCase().replaceAll('_', ' ').toUpperCase();
}

Color examsStatusColor(String status) {
  return switch (status.toLowerCase()) {
    'submitted' => const Color(0xFF16A34A),
    'in_progress' => const Color(0xFF2563EB),
    'draft' => const Color(0xFFF59E0B),
    _ => AppColors.primary,
  };
}

String? examsFormatIso(dynamic raw) {
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
    return '$month ${dt.day}, $hh:$mm $ampm';
  } catch (_) {
    return null;
  }
}
