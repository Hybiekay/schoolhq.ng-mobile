import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/auth_provider.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final profile = ref.watch(mobileProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(mobileProfileProvider),
          ),
        ],
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load profile\n$error',
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (data) {
          final profileMap = _extractProfile(data, role);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeaderCard(profile: profileMap, role: role),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Basic Info',
                entries: [
                  _Entry(
                    'Full Name',
                    (profileMap['full_name'] ?? '').toString(),
                  ),
                  _Entry('Email', (profileMap['email'] ?? '-').toString()),
                  _Entry('Phone', (profileMap['phone'] ?? '-').toString()),
                  _Entry('Role', role.toUpperCase()),
                  _Entry('Status', (profileMap['status'] ?? '-').toString()),
                ],
              ),
              if (role == 'student') ...[
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Academic',
                  entries: [
                    _Entry(
                      'Admission Number',
                      (profileMap['admission_number'] ?? '-').toString(),
                    ),
                    _Entry(
                      'Class',
                      (_asMap(profileMap['class'])['name'] ?? '-').toString(),
                    ),
                    _Entry(
                      'Department',
                      (_asMap(profileMap['department'])['name'] ?? '-')
                          .toString(),
                    ),
                  ],
                ),
              ],
              if (role == 'parent') ...[
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Parent Details',
                  entries: [
                    _Entry(
                      'Occupation',
                      (_asMap(profileMap['profile'])['occupation'] ?? '-')
                          .toString(),
                    ),
                    _Entry(
                      'Relationship',
                      (_asMap(
                                profileMap['profile'],
                              )['relationship_to_student'] ??
                              '-')
                          .toString(),
                    ),
                    _Entry(
                      'Children',
                      (_asMap(profileMap['profile'])['number_of_children'] ??
                              '-')
                          .toString(),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, dynamic> _extractProfile(Map<String, dynamic> data, String role) {
    if (role == 'parent') return _asMap(data['parent']);
    return _asMap(data['student']);
  }
}

class _HeaderCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String role;

  const _HeaderCard({required this.profile, required this.role});

  @override
  Widget build(BuildContext context) {
    final name = (profile['full_name'] ?? 'User').toString();
    final subtitle = role == 'parent'
        ? 'Parent Account'
        : (_asMap(profile['class'])['name'] ?? 'Student Account').toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            foregroundColor: AppColors.primary,
            child: Text(
              _initials(name),
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headingMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<_Entry> entries;

  const _SectionCard({required this.title, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...entries.asMap().entries.map((item) {
              final index = item.key;
              final entry = item.value;
              return Column(
                children: [
                  _InfoRow(entry: entry),
                  if (index != entries.length - 1)
                    const Divider(height: 18, thickness: 0.6),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Entry {
  final String label;
  final String value;

  const _Entry(this.label, this.value);
}

class _InfoRow extends StatelessWidget {
  final _Entry entry;

  const _InfoRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            entry.label,
            style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            entry.value.isEmpty ? '-' : entry.value,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
