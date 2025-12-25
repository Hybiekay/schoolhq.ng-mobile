// ==================== Reusable Widgets ====================
import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index == currentStep;
            final isCompleted = index < currentStep;

            return Expanded(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.primary
                              : isActive
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCompleted || isActive
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                      if (index < totalSteps - 1)
                        Positioned(
                          left: 40,
                          right: -40,
                          child: Container(
                            height: 2,
                            color: isCompleted
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStepLabel(index),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isActive
                          ? AppColors.primary
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _getStepDescription(currentStep),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getStepLabel(int index) {
    switch (index) {
      case 0:
        return 'Role';
      case 1:
        return 'Details';
      case 2:
        return 'Account';
      default:
        return 'Step ${index + 1}';
    }
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Select your role to customize your experience';
      case 1:
        return 'Enter your personal information';
      case 2:
        return 'Create your secure account';
      default:
        return '';
    }
  }
}
