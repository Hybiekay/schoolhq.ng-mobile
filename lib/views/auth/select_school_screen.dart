import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schoolhq_ng/core/constants/app_colors.dart';
import 'package:schoolhq_ng/core/constants/app_text_styles.dart';
import 'package:schoolhq_ng/provider/school_provider.dart';
import 'package:schoolhq_ng/routes/app_routes.dart';

class SelectSchoolScreen extends StatefulWidget {
  const SelectSchoolScreen({super.key});

  @override
  State<SelectSchoolScreen> createState() => _SelectSchoolScreenState();
}

class _SelectSchoolScreenState extends State<SelectSchoolScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final schools = Provider.of<SchoolProvider>(context).schools;
    final filtered = schools
        .where(
          (school) => school.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

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
            label: Text("Scan QR", style: AppTextStyles.body),
            onPressed: () {
              // TODO: Implement QR scanner
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
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
                            await Provider.of<SchoolProvider>(
                              context,
                              listen: false,
                            ).selectSchool(school);

                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
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
