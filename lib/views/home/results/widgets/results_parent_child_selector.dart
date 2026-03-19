import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/results/widgets/results_error_card.dart';

class ResultsParentChildSelector extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final String? selectedChildId;
  final ValueChanged<String> onSelected;

  const ResultsParentChildSelector({
    super.key,
    required this.children,
    required this.selectedChildId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const ResultsErrorCard(
        message: 'No children linked to this parent account.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: children.map((child) {
          final id = (child['id'] ?? '').toString();
          final selected =
              id == selectedChildId ||
              (selectedChildId == null && children.first == child);
          return ChoiceChip(
            label: Text((child['full_name'] ?? 'Student').toString()),
            selected: selected,
            onSelected: (_) => onSelected(id),
            selectedColor: AppColors.primary.withOpacity(0.15),
            labelStyle: AppTextStyles.small.copyWith(
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          );
        }).toList(),
      ),
    );
  }
}
