import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class ProfileInfoEntry {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoEntry({
    required this.icon,
    required this.label,
    required this.value,
  });
}

Map<String, dynamic> profileAsMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

Map<String, dynamic> extractProfileData(Map<String, dynamic> data, String role) {
  if (role == 'parent') {
    return profileAsMap(data['parent']);
  }

  if (role == 'student') {
    return profileAsMap(data['student']);
  }

  return profileAsMap(data['user']);
}

String profileDisplayValue(dynamic value, {String fallback = '-'}) {
  final text = '${value ?? ''}'.trim();
  if (text.isEmpty || text.toLowerCase() == 'null') {
    return fallback;
  }
  return text;
}

String profileInitials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((item) => item.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return '?';
  }

  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }

  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

String profileRoleLabel(String role) {
  switch (role.toLowerCase()) {
    case 'parent':
      return 'Parent';
    case 'teacher':
      return 'Teacher';
    case 'admin':
      return 'Admin';
    default:
      return 'Student';
  }
}

String profileSubtitle(Map<String, dynamic> profile, String role) {
  if (role == 'parent') {
    final relationship = profileDisplayValue(
      profileAsMap(profile['profile'])['relationship_to_student'],
      fallback: '',
    );
    return relationship.isEmpty ? 'Parent account' : relationship;
  }

  final className = profileDisplayValue(
    profileAsMap(profile['class'])['name'],
    fallback: '',
  );
  if (className.isNotEmpty) {
    return className;
  }

  return '${profileRoleLabel(role)} account';
}

String profileStatusText(Map<String, dynamic> profile) {
  return profileDisplayValue(profile['status'], fallback: 'Active');
}

Color profileStatusColor(String status) {
  final normalized = status.toLowerCase();

  if (normalized.contains('active') || normalized.contains('approved')) {
    return AppColors.success;
  }

  if (normalized.contains('pending') || normalized.contains('review')) {
    return AppColors.warning;
  }

  if (normalized.contains('inactive') ||
      normalized.contains('suspend') ||
      normalized.contains('block')) {
    return AppColors.error;
  }

  return AppColors.accent;
}

LinearGradient profileGradientForRole(String role) {
  return role == 'parent' ? AppColors.accentGradient : AppColors.brandGradient;
}

List<ProfileInfoEntry> profileBasicInfoEntries(
  Map<String, dynamic> profile,
  String role,
) {
  return [
    ProfileInfoEntry(
      icon: Icons.person_rounded,
      label: 'Full Name',
      value: profileDisplayValue(profile['full_name']),
    ),
    ProfileInfoEntry(
      icon: Icons.mail_outline_rounded,
      label: 'Email',
      value: profileDisplayValue(profile['email']),
    ),
    ProfileInfoEntry(
      icon: Icons.phone_rounded,
      label: 'Phone',
      value: profileDisplayValue(profile['phone']),
    ),
    ProfileInfoEntry(
      icon: Icons.shield_outlined,
      label: 'Role',
      value: profileRoleLabel(role),
    ),
    ProfileInfoEntry(
      icon: Icons.verified_user_rounded,
      label: 'Status',
      value: profileStatusText(profile),
    ),
  ];
}

List<ProfileInfoEntry> profileAcademicEntries(Map<String, dynamic> profile) {
  return [
    ProfileInfoEntry(
      icon: Icons.badge_outlined,
      label: 'Admission Number',
      value: profileDisplayValue(profile['admission_number']),
    ),
    ProfileInfoEntry(
      icon: Icons.class_rounded,
      label: 'Class',
      value: profileDisplayValue(profileAsMap(profile['class'])['name']),
    ),
    ProfileInfoEntry(
      icon: Icons.account_tree_rounded,
      label: 'Department',
      value: profileDisplayValue(profileAsMap(profile['department'])['name']),
    ),
  ];
}

List<ProfileInfoEntry> profileParentEntries(Map<String, dynamic> profile) {
  final parentProfile = profileAsMap(profile['profile']);
  return [
    ProfileInfoEntry(
      icon: Icons.work_outline_rounded,
      label: 'Occupation',
      value: profileDisplayValue(parentProfile['occupation']),
    ),
    ProfileInfoEntry(
      icon: Icons.favorite_border_rounded,
      label: 'Relationship',
      value: profileDisplayValue(parentProfile['relationship_to_student']),
    ),
    ProfileInfoEntry(
      icon: Icons.child_care_rounded,
      label: 'Children',
      value: profileDisplayValue(parentProfile['number_of_children']),
    ),
  ];
}
