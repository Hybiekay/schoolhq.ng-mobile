import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class InlineStatusCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isError;

  const InlineStatusCard({
    super.key,
    required this.message,
    required this.icon,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.replaceFirst('Exception: ', ''),
              style: AppTextStyles.subtitle.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
