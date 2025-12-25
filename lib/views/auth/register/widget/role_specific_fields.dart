import 'package:flutter/material.dart';
import 'package:schoolhq_ng/enum/user_role.dart';
import 'package:schoolhq_ng/widget/app_text_field.dart';

class RoleSpecificFields extends StatelessWidget {
  final UserRole? selectedRole;
  final TextEditingController studentIdController;
  final TextEditingController staffIdController;
  final TextEditingController childNameController;
  final TextEditingController childGradeController;

  const RoleSpecificFields({
    super.key,
    required this.selectedRole,
    required this.studentIdController,
    required this.staffIdController,
    required this.childNameController,
    required this.childGradeController,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedRole == null) return const SizedBox.shrink();

    switch (selectedRole!) {
      case UserRole.student:
        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Student Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your student details for verification',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: studentIdController,
              label: 'Student ID *',
              hintText: 'Enter your student ID',
              icon: Icons.badge_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Student ID is required';
                }
                return null;
              },
            ),
          ],
        );

      case UserRole.teacher:
        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Teaching Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your teaching credentials will be verified by the school administration within 24-48 hours.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: TextEditingController(),
              label: 'Subject/Department',
              hintText: 'e.g., Mathematics, Science',
              icon: Icons.subject_outlined,
              enabled: false,
              validator: null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: TextEditingController(),
              label: 'Years of Experience',
              hintText: 'Enter years of teaching experience',
              icon: Icons.timeline_outlined,
              enabled: false,
              keyboardType: TextInputType.number,
              validator: null,
            ),
          ],
        );

      case UserRole.parent:
        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Child Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide information about your child for account linking',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: childNameController,
              label: "Child's Full Name *",
              hintText: 'Enter your child\'s name',
              icon: Icons.child_care_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Child's name is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: childGradeController,
              label: "Child's Grade/Class *",
              hintText: 'e.g., Grade 5, Class 10B',
              icon: Icons.school_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Child's grade is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: TextEditingController(),
              label: 'Student ID (Optional)',
              hintText: 'If you know your child\'s student ID',
              icon: Icons.numbers_outlined,
              enabled: false,
              validator: null,
            ),
          ],
        );

      case UserRole.staff:
        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Staff Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your staff details for verification',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: staffIdController,
              label: 'Staff ID *',
              hintText: 'Enter your staff ID',
              icon: Icons.work_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Staff ID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: TextEditingController(),
              label: 'Department',
              hintText: 'e.g., Administration, IT, Finance',
              icon: Icons.business_outlined,
              enabled: false,
              validator: null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: TextEditingController(),
              label: 'Position',
              hintText: 'e.g., Administrator, Coordinator',
              icon: Icons.work_history_outlined,
              enabled: false,
              validator: null,
            ),
          ],
        );
    }
  }
}
