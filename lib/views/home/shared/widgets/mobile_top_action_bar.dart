import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/views/home/shared/helpers/mobile_top_bar_actions.dart';
import 'package:schoolhq_ng/views/home/shared/widgets/mobile_top_action_button.dart';

class MobileTopActionBar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsSummary = ref.watch(mobileNotificationsSummaryProvider);
    final unreadCount = notificationsSummary.maybeWhen(
      data: (summary) => int.tryParse('${summary['unread_count'] ?? 0}') ?? 0,
      orElse: () => 0,
    );

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
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    title,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MobileTopActionButton(
                    icon: Icons.manage_search_rounded,
                    onTap: () {
                      openMobileQuickSearch(context);
                    },
                  ),
                  MobileTopActionButton(
                    icon: Icons.notifications_active_rounded,
                    badgeCount: unreadCount,
                    onTap: () {
                      showMobileNotificationsPreview(context);
                    },
                  ),
                  if (mobileMessagingEnabled())
                    MobileTopActionButton(
                      icon: Icons.forum_rounded,
                      onTap: () {
                        showMobileChatPreview(context);
                      },
                    ),
                  if (onRefresh != null)
                    MobileTopActionButton(
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
}
