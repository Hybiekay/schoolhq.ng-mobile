import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/messages/chat_realtime_service.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/message_realtime_chip.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/messages_metric_pill.dart';

class MessagesIntroCard extends StatelessWidget {
  final String role;
  final int contactCount;
  final int conversationCount;
  final ChatRealtimeStatus realtimeStatus;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const MessagesIntroCard({
    super.key,
    required this.role,
    required this.contactCount,
    required this.conversationCount,
    required this.realtimeStatus,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final copy = role == 'teacher'
        ? 'Reach students in your assigned classes and keep school follow-up simple.'
        : 'Chat with classmates and teachers from one bright, easy message space.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.forum_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message World',
                      style: AppTextStyles.headingMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(copy, style: AppTextStyles.small),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MessageRealtimeChip(status: realtimeStatus),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MessagesMetricPill(
                  label: 'Contacts',
                  value: '$contactCount',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MessagesMetricPill(
                  label: 'Chats',
                  value: '$conversationCount',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search people or chats',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
