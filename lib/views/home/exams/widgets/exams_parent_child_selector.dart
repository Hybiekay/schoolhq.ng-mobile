import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class ExamsParentChildSelector extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final String? selectedChildId;
  final ValueChanged<String> onSelected;

  const ExamsParentChildSelector({
    super.key,
    required this.children,
    required this.selectedChildId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Child',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: children.map((child) {
              final id = (child['id'] ?? '').toString();
              final selected =
                  id == selectedChildId ||
                  (selectedChildId == null && children.first == child);
              final label = (child['full_name'] ?? 'Student').toString();
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => onSelected(id),
                selectedColor: AppColors.primary.withOpacity(0.15),
                labelStyle: AppTextStyles.small.copyWith(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary
                      : AppColors.grey.withOpacity(0.4),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
