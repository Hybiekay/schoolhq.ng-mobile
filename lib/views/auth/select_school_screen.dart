import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/school_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/qr_scanner_screen.dart';

class SelectSchoolScreen extends ConsumerStatefulWidget {
  const SelectSchoolScreen({super.key});

  @override
  ConsumerState<SelectSchoolScreen> createState() => _SelectSchoolScreenState();
}

class _SelectSchoolScreenState extends ConsumerState<SelectSchoolScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    //   final schools = ref.watch(schoolProvider);
    final filtered = [];

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
            child: TextField(
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
              onChanged: (val) => setState(() => query = val),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("QR scanning is only available on mobile."),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Center(child: Text('No schools found')),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final school = filtered[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.school,
                            color: AppColors.primary,
                          ),
                          title: Text(school.name, style: AppTextStyles.body),
                          subtitle: Text(
                            school.location,
                            style: AppTextStyles.small,
                          ),
                          onTap: () async {
                            ref
                                .read(schoolProvider.notifier)
                                .selectSchool(school);
                            context.go('/login');
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
