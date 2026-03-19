import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class StudentExamCompletedState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onClose;

  const StudentExamCompletedState({
    super.key,
    required this.title,
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_rounded,
              size: 48,
              color: Color(0xFF16A34A),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onClose,
              child: const Text('Back to Exams'),
            ),
          ],
        ),
      ),
    );
  }
}
