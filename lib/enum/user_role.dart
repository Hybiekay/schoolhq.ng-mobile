// Enum for user roles
import 'package:flutter/material.dart';

enum UserRole {
  student(
    'Student',
    Icons.school_outlined,
    'For students to access classes and assignments',
  ),
  teacher(
    'Teacher',
    Icons.people_alt_outlined,
    'For teachers to manage classes and students',
  ),
  parent(
    'Parent',
    Icons.family_restroom_outlined,
    'For parents to track student progress',
  ),
  staff('Staff', Icons.badge_outlined, 'For school staff and administrators');

  final String label;
  final IconData icon;
  final String description;

  const UserRole(this.label, this.icon, this.description);
}
