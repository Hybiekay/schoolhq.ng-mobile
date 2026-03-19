import 'package:flutter/material.dart';

List<Map<String, dynamic>> asClassList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Map<String, dynamic> asClassMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

int classIntValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? classStringOrNull(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

IconData classResourceIcon(String type) {
  switch (type) {
    case 'file':
      return Icons.insert_drive_file_outlined;
    case 'link':
      return Icons.link_rounded;
    default:
      return Icons.notes_rounded;
  }
}

String classResourceLabel(String type) {
  switch (type) {
    case 'file':
      return 'File';
    case 'link':
      return 'Link';
    default:
      return 'Text';
  }
}
