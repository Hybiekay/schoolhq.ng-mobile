import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/models/user_school.dart';
import 'package:schoolhq_ng/views/home/profile/helpers/profile_helpers.dart';
import 'package:schoolhq_ng/views/home/profile/widgets/profile_action_card.dart';
import 'package:schoolhq_ng/views/home/profile/widgets/profile_error_state.dart';
import 'package:schoolhq_ng/views/home/profile/widgets/profile_header_card.dart';
import 'package:schoolhq_ng/views/home/profile/widgets/profile_info_row.dart';
import 'package:schoolhq_ng/views/home/profile/widgets/profile_loading_state.dart';
import 'package:schoolhq_ng/views/home/profile/widgets/profile_school_card.dart';
import 'package:schoolhq_ng/views/home/profile/widgets/profile_section_card.dart';

class ProfileBody extends StatelessWidget {
  final String role;
  final UserSchool school;
  final AsyncValue<Map<String, dynamic>> profileAsync;
  final Widget? topHeader;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final Future<void> Function() onClearSchoolData;

  const ProfileBody({
    super.key,
    required this.role,
    required this.school,
    required this.profileAsync,
    this.topHeader,
    required this.onRefresh,
    required this.onLogout,
    required this.onClearSchoolData,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: profileAsync.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            if (topHeader != null) ...[topHeader!, const SizedBox(height: 16)],
            const ProfileLoadingState(),
          ],
        ),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            if (topHeader != null) ...[topHeader!, const SizedBox(height: 16)],
            ProfileErrorState(
              message: 'Failed to load your profile.\n$error',
              onRetry: onRefresh,
            ),
          ],
        ),
        data: (data) {
          final profile = extractProfileData(data, role);
          final detailEntries = role == 'student'
              ? profileAcademicEntries(profile)
              : role == 'parent'
              ? profileParentEntries(profile)
              : const <ProfileInfoEntry>[];

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              if (topHeader != null) ...[
                topHeader!,
                const SizedBox(height: 16),
              ],
              ProfileHeaderCard(profile: profile, role: role, school: school),
              const SizedBox(height: 16),
              ProfileSectionCard(
                title: 'Basic Info',
                subtitle:
                    'Identity and contact details linked to this account.',
                icon: Icons.badge_rounded,
                accentColor: AppColors.primary,
                children: _buildEntryRows(profileBasicInfoEntries(profile, role)),
              ),
              if (detailEntries.isNotEmpty) ...[
                const SizedBox(height: 14),
                ProfileSectionCard(
                  title: role == 'parent' ? 'Family Details' : 'Academic Info',
                  subtitle: role == 'parent'
                      ? 'Quick information about your family access.'
                      : 'Academic placement and school structure details.',
                  icon: role == 'parent'
                      ? Icons.family_restroom_rounded
                      : Icons.school_rounded,
                  accentColor: role == 'parent'
                      ? AppColors.secondary
                      : AppColors.accent,
                  children: _buildEntryRows(detailEntries),
                ),
              ],
              const SizedBox(height: 14),
              ProfileSchoolCard(
                school: school,
                onClearSchoolData: onClearSchoolData,
              ),
              const SizedBox(height: 14),
              ProfileActionCard(
                icon: Icons.sync_rounded,
                title: 'Refresh Profile',
                subtitle:
                    'Pull the latest profile details from the backend and sync this screen.',
                actionLabel: 'Refresh',
                accentColor: AppColors.accent,
                onPressed: onRefresh,
              ),
              const SizedBox(height: 12),
              ProfileActionCard(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle:
                    'Sign out from this device and return to the login screen for this school.',
                actionLabel: 'Sign Out',
                accentColor: AppColors.error,
                onPressed: onLogout,
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildEntryRows(List<ProfileInfoEntry> entries) {
    return entries.asMap().entries.map((item) {
      final index = item.key;
      final entry = item.value;
      return ProfileInfoRow(
        entry: entry,
        showDivider: index != entries.length - 1,
      );
    }).toList();
  }
}
