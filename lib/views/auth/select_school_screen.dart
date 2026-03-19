import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/feedback/app_snackbar.dart';
import 'package:schoolhq_ng/providers/auth_provider.dart';
import 'package:schoolhq_ng/providers/school_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/widget/school_logo.dart';
import 'package:go_router/go_router.dart';
import '../widgets/qr_scanner_screen.dart';

class SelectSchoolScreen extends ConsumerStatefulWidget {
  const SelectSchoolScreen({super.key});

  @override
  ConsumerState<SelectSchoolScreen> createState() => _SelectSchoolScreenState();
}

class _SelectSchoolScreenState extends ConsumerState<SelectSchoolScreen> {
  String query = '';
  String dashboardQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schoolsAsync = ref.watch(
      schoolDirectorySearchProvider(dashboardQuery),
    );
    final selectedSchool = ref.watch(schoolProvider);

    // Skip school selection on Web
    if (kIsWeb) {
      Future.microtask(() => context.go('/login'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        title: Text('Select Your School', style: AppTextStyles.headingMedium),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse active schools from the dashboard directory.',
                  style: AppTextStyles.small,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search your school...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => query = val);
                    _debounce?.cancel();
                    _debounce = Timer(
                      const Duration(milliseconds: 300),
                      () => setState(() => dashboardQuery = val.trim()),
                    );
                  },
                ),
              ],
            ),
          ),
          if (selectedSchool != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.14),
                  ),
                ),
                child: Row(
                  children: [
                    SchoolLogo(logo: selectedSchool.logo, size: 44, radius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selected school', style: AppTextStyles.small),
                          const SizedBox(height: 4),
                          Text(
                            selectedSchool.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.login),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.white),
            label: Text("Scan QR", style: AppTextStyles.button),
            onPressed: () async {
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                final scannedSchoolId = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                );

                if (scannedSchoolId != null) {
                  // handle scanned school ID like before
                }
              } else {
                AppSnackBar.info(
                  context,
                  'QR scanning is only available on mobile.',
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(schoolDirectorySearchProvider(dashboardQuery));
              },
              child: schoolsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Unable to load schools right now.',
                          style: AppTextStyles.headingMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: AppTextStyles.small,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(
                            schoolDirectorySearchProvider(dashboardQuery),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (schools) {
                  if (schools.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No schools found')),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: schools.length,
                    itemBuilder: (_, index) {
                      final school = schools[index];
                      final isSelected = selectedSchool?.id == school.id;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: SchoolLogo(
                            logo: school.logo,
                            size: 44,
                            radius: 12,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  school.name,
                                  style: AppTextStyles.body,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Selected',
                                    style: AppTextStyles.small.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            school.location,
                            style: AppTextStyles.small,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                          onTap: () async {
                            final previousSchool = ref.read(schoolProvider);
                            if (previousSchool?.id != school.id) {
                              await ref.read(authProvider.notifier).logout();
                            }

                            ref
                                .read(schoolProvider.notifier)
                                .selectSchool(school);

                            if (context.mounted) {
                              context.go(RouteNames.login);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
