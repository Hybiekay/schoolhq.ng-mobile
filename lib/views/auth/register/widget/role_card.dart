import "package:flutter/material.dart";
import "package:schoolhq_ng/core/constants/app_colors.dart";
import "package:schoolhq_ng/enum/user_role.dart";

class RoleCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  role.icon,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: isMobile ? 24 : 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                role.label,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.grey.shade800,
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(height: 8),
                Text(
                  role.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
