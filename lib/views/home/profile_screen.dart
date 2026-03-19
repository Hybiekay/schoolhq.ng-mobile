import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/school/current_school.dart';
import 'package:schoolhq_ng/providers/auth_provider.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/providers/onboarding_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/views/home/profile/profile_body.dart';
import 'package:schoolhq_ng/views/home/shared/widgets/mobile_top_action_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _refreshProfile(WidgetRef ref) async {
    ref.invalidate(mobileProfileProvider);
    await ref.read(mobileProfileProvider.future);
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      context.go(RouteNames.login);
    }
  }

  Future<void> _clearSchoolData(BuildContext context, WidgetRef ref) async {
    final school = currentSchool();
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear school data?'),
        content: Text(
          'This will sign you out of ${school.name}, remove the saved school on this device, and return to onboarding.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );

    if (shouldClear != true) {
      return;
    }

    await ref.read(authProvider.notifier).logout(clearSchool: true);
    resetOnboarding(ref);

    if (context.mounted) {
      context.go(RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final profileAsync = ref.watch(mobileProfileProvider);
    final school = currentSchool();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ProfileBody(
          role: role,
          school: school,
          profileAsync: profileAsync,
          topHeader: MobileTopActionBar(
            title: 'Profile',
            subtitle:
                'Manage your account, school access, notifications, and quick tools from here.',
            gradient: AppColors.brandGradient,
            onRefresh: () => _refreshProfile(ref),
          ),
          onRefresh: () => _refreshProfile(ref),
          onLogout: () => _logout(context, ref),
          onClearSchoolData: () => _clearSchoolData(context, ref),
        ),
      ),
    );
  }
}
