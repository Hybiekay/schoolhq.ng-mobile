import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/messages/chat_realtime_service.dart';
import 'package:schoolhq_ng/views/home/messages/helpers/messages_helpers.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/message_header_action_button.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/message_realtime_chip.dart';

class MessageConversationHeaderCard extends StatelessWidget {
  final Map<String, dynamic> participant;
  final ChatRealtimeStatus realtimeStatus;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;

  const MessageConversationHeaderCard({
    super.key,
    required this.participant,
    required this.realtimeStatus,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final name = (participant['full_name'] ?? 'Conversation').toString();
    final role = (participant['role'] ?? 'student').toString();
    final subtitle = (participant['subtitle'] ?? 'School chat').toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.coolGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          MessageHeaderActionButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: messagesRoleGradient(role),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              messagesInitials(name),
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MessageRealtimeChip(
                status: realtimeStatus,
                onDark: true,
              ),
              const SizedBox(height: 10),
              MessageHeaderActionButton(
                icon: Icons.sync_rounded,
                onTap: () {
                  onRefresh();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
