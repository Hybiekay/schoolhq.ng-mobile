import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/models/user_school.dart';
import 'package:schoolhq_ng/views/home/profile/helpers/profile_helpers.dart';
import 'package:schoolhq_ng/views/home/profile/widgets/profile_glow_bubble.dart';
import 'package:schoolhq_ng/views/home/profile/widgets/profile_stat_chip.dart';
import 'package:schoolhq_ng/widget/school_logo.dart';

class ProfileHeaderCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String role;
  final UserSchool school;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.role,
    required this.school,
  });

  @override
  Widget build(BuildContext context) {
    final name = profileDisplayValue(profile['full_name'], fallback: 'User');
    final subtitle = profileSubtitle(profile, role);
    final statusText = profileStatusText(profile);
    final statusColor = profileStatusColor(statusText);
    final extraChip = _extraChipLabel();
    final gradient = profileGradientForRole(role);

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.20),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -10,
            child: ProfileGlowBubble(
              size: 116,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Positioned(
            bottom: -48,
            left: -16,
            child: ProfileGlowBubble(
              size: 144,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SchoolLogo(logo: school.logo, size: 22, radius: 7),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 170),
                            child: Text(
                              school.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.small.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.manage_accounts_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                        ),
                      ),
                      child: Text(
                        profileInitials(name),
                        style: AppTextStyles.headingLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.headingLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: AppTextStyles.subtitle.copyWith(
                              color: Colors.white.withOpacity(0.92),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ProfileStatChip(
                      icon: Icons.verified_user_rounded,
                      label: profileRoleLabel(role),
                      backgroundColor: Colors.white.withOpacity(0.14),
                      foregroundColor: Colors.white,
                    ),
                    ProfileStatChip(
                      icon: _statusIcon(statusText),
                      label: statusText,
                      backgroundColor: statusColor.withOpacity(0.24),
                      foregroundColor: Colors.white,
                    ),
                    if (extraChip != null)
                      ProfileStatChip(
                        icon: _extraChipIcon(),
                        label: extraChip,
                        backgroundColor: Colors.white.withOpacity(0.14),
                        foregroundColor: Colors.white,
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Your account details, school access, and essential identity info are all organized here for quick review.',
                  style: AppTextStyles.subtitle.copyWith(
                    color: Colors.white.withOpacity(0.90),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _extraChipLabel() {
    if (role == 'student') {
      final className = profileDisplayValue(
        profileAsMap(profile['class'])['name'],
        fallback: '',
      );
      if (className.isNotEmpty) {
        return className;
      }

      final department = profileDisplayValue(
        profileAsMap(profile['department'])['name'],
        fallback: '',
      );
      if (department.isNotEmpty) {
        return department;
      }
    }

    if (role == 'parent') {
      final childCount = profileDisplayValue(
        profileAsMap(profile['profile'])['number_of_children'],
        fallback: '',
      );
      if (childCount.isNotEmpty) {
        return '$childCount children';
      }
    }

    return null;
  }

  IconData _extraChipIcon() {
    if (role == 'parent') {
      return Icons.family_restroom_rounded;
    }

    return Icons.school_rounded;
  }

  IconData _statusIcon(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('active') || normalized.contains('approved')) {
      return Icons.check_circle_rounded;
    }

    if (normalized.contains('pending') || normalized.contains('review')) {
      return Icons.schedule_rounded;
    }

    if (normalized.contains('inactive') ||
        normalized.contains('suspend') ||
        normalized.contains('block')) {
      return Icons.lock_outline_rounded;
    }

    return Icons.shield_outlined;
  }
}
