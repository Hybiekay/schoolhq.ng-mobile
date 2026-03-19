import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class ProfileLoadingState extends StatelessWidget {
  const ProfileLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _placeholderCard(height: 240, gradient: AppColors.brandGradient),
        const SizedBox(height: 16),
        _placeholderCard(height: 230),
        const SizedBox(height: 14),
        _placeholderCard(height: 190),
        const SizedBox(height: 14),
        _placeholderCard(height: 132),
      ],
    );
  }

  Widget _placeholderCard({
    required double height,
    LinearGradient? gradient,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.white : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.first ?? AppColors.primary).withOpacity(
              0.10,
            ),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            color: gradient == null ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}
