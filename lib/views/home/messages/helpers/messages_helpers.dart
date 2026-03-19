import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

Map<String, dynamic> messagesAsMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> messagesAsList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String messagesInitials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .toList();

  if (parts.isEmpty) {
    return 'C';
  }

  return parts.map((part) => part[0].toUpperCase()).join();
}

Color messagesRoleAccent(String role) {
  switch (role.toLowerCase()) {
    case 'teacher':
      return AppColors.warning;
    case 'student':
      return AppColors.primary;
    default:
      return AppColors.textSecondary;
  }
}

LinearGradient messagesRoleGradient(String role) {
  switch (role.toLowerCase()) {
    case 'teacher':
      return const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'student':
      return AppColors.coolGradient;
    default:
      return const LinearGradient(
        colors: [Color(0xFF64748B), Color(0xFF334155)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}

String messagesConversationTimeLabel(String? value) {
  final date = _parseDate(value);
  if (date == null) {
    return 'Now';
  }

  final now = DateTime.now();
  final local = date.toLocal();
  final sameDay =
      now.year == local.year && now.month == local.month && now.day == local.day;

  if (sameDay) {
    return _timeLabel(local);
  }

  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday = yesterday.year == local.year &&
      yesterday.month == local.month &&
      yesterday.day == local.day;
  if (isYesterday) {
    return 'Yesterday';
  }

  return '${_monthLabel(local.month)} ${local.day}';
}

String messagesBubbleTimeLabel(String? value) {
  final date = _parseDate(value);
  if (date == null) {
    return 'Now';
  }

  final local = date.toLocal();
  return '${_monthLabel(local.month)} ${local.day}, ${_timeLabel(local)}';
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
}

String _timeLabel(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String _monthLabel(int month) {
  const months = <String>[
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
  ];

  if (month < 1 || month > months.length) {
    return 'Date';
  }

  return months[month - 1];
}
