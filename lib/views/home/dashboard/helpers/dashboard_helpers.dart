import 'package:schoolhq_ng/core/formatters/school_currency_formatter.dart';

Map<String, dynamic> asDashboardMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> asDashboardList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

int dashboardIntValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String dashboardMoney(dynamic value) {
  return formatSchoolMoney(value);
}

String dashboardFirstWord(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  return parts.isEmpty ? value : parts.first;
}

String dashboardInitials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

String? dashboardFormatIso(dynamic raw) {
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
    return '$month ${dt.day}';
  } catch (_) {
    return null;
  }
}

String? dashboardFormatIsoDate(dynamic raw) {
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
    return '$month ${dt.day}, ${dt.year}';
  } catch (_) {
    return raw.toString();
  }
}

String dashboardFormatTimeRange(dynamic start, dynamic end) {
  final startLabel = (start ?? '').toString();
  final endLabel = (end ?? '').toString();

  if (startLabel.isEmpty && endLabel.isEmpty) {
    return 'Time not set';
  }

  if (startLabel.isNotEmpty && endLabel.isNotEmpty) {
    return '$startLabel - $endLabel';
  }
  return startLabel.isNotEmpty ? startLabel : endLabel;
}
