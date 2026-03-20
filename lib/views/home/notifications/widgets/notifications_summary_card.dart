import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';

class NotificationsSummaryCard extends StatelessWidget {
  final int unreadCount;
  final int totalCount;
  final bool markingAll;
  final VoidCallback? onMarkAllRead;

  const NotificationsSummaryCard({
    super.key,
    required this.unreadCount,
    required this.totalCount,
    required this.markingAll,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your alert feed',
                  style: AppTextStyles.headingMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: onMarkAllRead,
                icon: markingAll
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.done_all_rounded),
                label: const Text('Mark all read'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Stay on top of new messages and school updates from one place.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Unread',
                  value: '$unreadCount',
                  colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'Total',
                  value: '$totalCount',
                  colors: const [Color(0xFF06B6D4), Color(0xFF10B981)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final List<Color> colors;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
