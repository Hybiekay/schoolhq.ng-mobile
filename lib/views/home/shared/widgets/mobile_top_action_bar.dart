import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/school/current_school.dart';
import 'package:schoolhq_ng/views/home/shared/helpers/mobile_top_bar_actions.dart';
import 'package:schoolhq_ng/widget/school_logo.dart';

class MobileTopActionBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Future<void> Function()? onRefresh;

  const MobileTopActionBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final school = currentSchool();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SchoolLogo(
                          logo: school.logo,
                          size: 18,
                          radius: 6,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            school.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.small.copyWith(
                              color: Colors.white.withOpacity(0.78),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small.copyWith(
                          color: Colors.white.withOpacity(0.82),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildActionButton(
                    icon: Icons.manage_search_rounded,
                    onTap: () {
                      openMobileQuickSearch(context);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.notifications_active_rounded,
                    onTap: () {
                      showMobileNotificationsPreview(context);
                    },
                  ),
                  if (mobileMessagingEnabled())
                    _buildActionButton(
                      icon: Icons.forum_rounded,
                      onTap: () {
                        showMobileChatPreview(context);
                      },
                    ),
                  if (onRefresh != null)
                    _buildActionButton(
                      icon: Icons.sync_rounded,
                      onTap: () {
                        onRefresh!();
                      },
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
