import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/feedback/app_snackbar.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/views/home/notifications/helpers/notifications_helpers.dart';
import 'package:schoolhq_ng/views/home/notifications/widgets/notification_item_card.dart';
import 'package:schoolhq_ng/views/home/notifications/widgets/notifications_empty_state.dart';
import 'package:schoolhq_ng/views/home/notifications/widgets/notifications_summary_card.dart';
import 'package:schoolhq_ng/views/home/shared/widgets/mobile_top_action_bar.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String? _markingNotificationId;
  bool _markingAll = false;

  Future<void> _refreshNotifications() async {
    ref.invalidate(mobileNotificationsProvider);
    ref.invalidate(mobileNotificationsSummaryProvider);
    await ref.read(mobileNotificationsProvider.future);
  }

  Future<void> _markRead(String notificationId) async {
    if (_markingNotificationId == notificationId) {
      return;
    }

    setState(() {
      _markingNotificationId = notificationId;
    });

    try {
      await ref
          .read(mobileRepositoryProvider)
          .markNotificationRead(notificationId);
      await _refreshNotifications();
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _markingNotificationId = null;
        });
      }
    }
  }

  Future<void> _markAllRead(int unreadCount) async {
    if (_markingAll || unreadCount == 0) {
      return;
    }

    setState(() {
      _markingAll = true;
    });

    try {
      await ref.read(mobileRepositoryProvider).markAllNotificationsRead();
      await _refreshNotifications();
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _markingAll = false;
        });
      }
    }
  }

  Future<void> _openNotification(Map<String, dynamic> notification) async {
    final notificationId = notification['id']?.toString();
    if (notificationId == null || notificationId.isEmpty) {
      return;
    }

    if (notification['is_read'] != true) {
      await _markRead(notificationId);
    }

    final action = notificationsAsMap(notification['action']);
    final actionType = action['type']?.toString();

    if (actionType == 'message_conversation') {
      final conversationId = action['conversation_id']?.toString();
      if (conversationId != null && conversationId.isNotEmpty && mounted) {
        await context.push(RouteNames.messageConversationPath(conversationId));
        ref.invalidate(mobileMessagesInboxProvider);
        await _refreshNotifications();
        return;
      }
    }

    if (mounted) {
      AppSnackBar.info(
        context,
        'This notification does not have an open destination yet.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(mobileNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshNotifications,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              const MobileTopActionBar(
                title: 'Notifications',
                subtitle:
                    'Catch up on fresh messages and school updates from one modern feed.',
                gradient: AppColors.coolGradient,
              ),
              const SizedBox(height: 18),
              notificationsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 56),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => NotificationsEmptyState(),
                data: (payload) {
                  final summary = notificationsAsMap(payload['summary']);
                  final notifications = notificationsAsList(
                    payload['notifications'],
                  );
                  final unreadCount =
                      int.tryParse('${summary['unread_count'] ?? 0}') ?? 0;
                  final totalCount =
                      int.tryParse('${summary['total_count'] ?? 0}') ?? 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NotificationsSummaryCard(
                        unreadCount: unreadCount,
                        totalCount: totalCount,
                        markingAll: _markingAll,
                        onMarkAllRead: unreadCount > 0
                            ? () {
                                _markAllRead(unreadCount);
                              }
                            : null,
                      ),
                      const SizedBox(height: 18),
                      if (notifications.isEmpty)
                        const NotificationsEmptyState()
                      else
                        ...notifications.map(
                          (notification) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NotificationItemCard(
                              notification: notification,
                              isMarkingRead:
                                  _markingNotificationId ==
                                  notification['id']?.toString(),
                              onTap: () {
                                _openNotification(notification);
                              },
                              onMarkRead: () {
                                final notificationId = notification['id']
                                    ?.toString();
                                if (notificationId != null &&
                                    notificationId.isNotEmpty) {
                                  _markRead(notificationId);
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
