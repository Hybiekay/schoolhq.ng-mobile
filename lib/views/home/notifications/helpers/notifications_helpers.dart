import 'package:flutter/material.dart';

List<Map<String, dynamic>> notificationsAsList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  return const <Map<String, dynamic>>[];
}

Map<String, dynamic> notificationsAsMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return const <String, dynamic>{};
}

String notificationTimeLabel(String? value) {
  if (value == null || value.isEmpty) {
    return 'Just now';
  }

  final date = DateTime.tryParse(value)?.toLocal();
  if (date == null) {
    return 'Just now';
  }

  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) {
    return 'Just now';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours}h ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }

  return '${date.day}/${date.month}/${date.year}';
}

IconData notificationIcon(String? icon) {
  switch (icon) {
    case 'message-square-more':
      return Icons.forum_rounded;
    case 'sparkles':
      return Icons.auto_awesome_rounded;
    case 'bell':
    default:
      return Icons.notifications_active_rounded;
  }
}

List<Color> notificationAccentColors(String? accent) {
  switch (accent) {
    case 'amber':
      return const [Color(0xFFF59E0B), Color(0xFFF97316)];
    case 'rose':
      return const [Color(0xFFF43F5E), Color(0xFFFB7185)];
    case 'cyan':
      return const [Color(0xFF06B6D4), Color(0xFF38BDF8)];
    case 'indigo':
    default:
      return const [Color(0xFF6366F1), Color(0xFF06B6D4)];
  }
}
