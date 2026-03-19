import 'package:flutter/material.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/messages/chat_realtime_service.dart';

class MessageRealtimeChip extends StatelessWidget {
  final ChatRealtimeStatus status;
  final bool onDark;

  const MessageRealtimeChip({
    super.key,
    required this.status,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(status, onDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tone.showSpinner)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2.1,
                valueColor: AlwaysStoppedAnimation<Color>(tone.foreground),
              ),
            )
          else
            Icon(tone.icon, size: 14, color: tone.foreground),
          const SizedBox(width: 6),
          Text(
            tone.label,
            style: AppTextStyles.small.copyWith(
              color: tone.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _MessageRealtimeTone _toneFor(ChatRealtimeStatus status, bool onDark) {
    switch (status) {
      case ChatRealtimeStatus.live:
        return _MessageRealtimeTone(
          label: 'Live Sync',
          icon: Icons.wifi_tethering_rounded,
          foreground: onDark ? Colors.white : const Color(0xFF047857),
          background: onDark
              ? Colors.white.withOpacity(0.14)
              : const Color(0xFFECFDF5),
          border: onDark
              ? Colors.white.withOpacity(0.18)
              : const Color(0xFFA7F3D0),
        );
      case ChatRealtimeStatus.connecting:
        return _MessageRealtimeTone(
          label: 'Connecting',
          icon: Icons.sync_rounded,
          foreground: onDark ? Colors.white : const Color(0xFFB45309),
          background: onDark
              ? Colors.white.withOpacity(0.14)
              : const Color(0xFFFFFBEB),
          border: onDark
              ? Colors.white.withOpacity(0.18)
              : const Color(0xFFFDE68A),
          showSpinner: true,
        );
      case ChatRealtimeStatus.reconnecting:
        return _MessageRealtimeTone(
          label: 'Reconnecting',
          icon: Icons.sync_problem_rounded,
          foreground: onDark ? Colors.white : const Color(0xFF0F766E),
          background: onDark
              ? Colors.white.withOpacity(0.14)
              : const Color(0xFFECFEFF),
          border: onDark
              ? Colors.white.withOpacity(0.18)
              : const Color(0xFFA5F3FC),
          showSpinner: true,
        );
      case ChatRealtimeStatus.offline:
        return _MessageRealtimeTone(
          label: 'Offline',
          icon: Icons.wifi_off_rounded,
          foreground: onDark ? Colors.white70 : const Color(0xFF475569),
          background: onDark
              ? Colors.white.withOpacity(0.10)
              : const Color(0xFFF8FAFC),
          border: onDark
              ? Colors.white.withOpacity(0.16)
              : const Color(0xFFE2E8F0),
        );
    }
  }
}

class _MessageRealtimeTone {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color border;
  final bool showSpinner;

  const _MessageRealtimeTone({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.border,
    this.showSpinner = false,
  });
}
