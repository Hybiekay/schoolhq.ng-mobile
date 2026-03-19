import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/models/user_school.dart';
import 'package:schoolhq_ng/views/home/profile/helpers/profile_helpers.dart';
import 'package:schoolhq_ng/views/home/profile/widgets/profile_info_row.dart';
import 'package:schoolhq_ng/views/home/profile/widgets/profile_section_card.dart';
import 'package:schoolhq_ng/widget/school_logo.dart';

class ProfileSchoolCard extends StatelessWidget {
  final UserSchool school;
  final Future<void> Function() onClearSchoolData;

  const ProfileSchoolCard({
    super.key,
    required this.school,
    required this.onClearSchoolData,
  });

  @override
  Widget build(BuildContext context) {
    final entries = _schoolEntries();

    return ProfileSectionCard(
      title: 'School Access',
      subtitle:
          'This school is stored locally on this device so the app knows where to connect.',
      icon: Icons.apartment_rounded,
      accentColor: AppColors.secondary,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withOpacity(0.10),
                AppColors.accent.withOpacity(0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SchoolLogo(logo: school.logo, size: 54, radius: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connected school on this device',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
        if (entries.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...entries.asMap().entries.map((item) {
            final index = item.key;
            final entry = item.value;
            return ProfileInfoRow(
              entry: entry,
              showDivider: index != entries.length - 1,
            );
          }),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clear School Data',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remove the saved school from this device, sign out, and return to onboarding.',
                      style: AppTextStyles.subtitle.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => onClearSchoolData(),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Clear School Data'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withOpacity(0.24)),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  List<ProfileInfoEntry> _schoolEntries() {
    final entries = <ProfileInfoEntry>[];

    if (school.email.trim().isNotEmpty) {
      entries.add(
        ProfileInfoEntry(
          icon: Icons.mail_outline_rounded,
          label: 'School Email',
          value: school.email,
        ),
      );
    }

    if (school.phone.trim().isNotEmpty) {
      entries.add(
        ProfileInfoEntry(
          icon: Icons.phone_in_talk_rounded,
          label: 'School Phone',
          value: school.phone,
        ),
      );
    }

    if (school.address.trim().isNotEmpty) {
      entries.add(
        ProfileInfoEntry(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value: school.address,
        ),
      );
    }

    return entries;
  }
}
