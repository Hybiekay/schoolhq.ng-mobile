import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/views/home/notifications/helpers/notifications_helpers.dart';

class NotificationItemCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final bool isMarkingRead;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;

  const NotificationItemCard({
    super.key,
    required this.notification,
    required this.isMarkingRead,
    required this.onTap,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification['is_read'] == true;
    final accent = notification['accent']?.toString();
    final colors = notificationAccentColors(accent);
    final sender = notificationsAsMap(notification['sender']);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isRead ? AppColors.grey : const Color(0xFFBFDBFE),
            ),
            boxShadow: isRead
                ? null
                : [
                    BoxShadow(
                      color: colors.first.withOpacity(0.12),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  notificationIcon(notification['icon']?.toString()),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title']?.toString() ?? 'Notification',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          notificationTimeLabel(
                            notification['created_at']?.toString(),
                          ),
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['body']?.toString() ?? '',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sender['full_name']?.toString().isNotEmpty == true
                                ? 'From ${sender['full_name']}'
                                : (isRead ? 'Read' : 'Needs attention'),
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          TextButton.icon(
                            onPressed: isMarkingRead ? null : onMarkRead,
                            icon: isMarkingRead
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.done_rounded, size: 18),
                            label: const Text('Read'),
                          ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
