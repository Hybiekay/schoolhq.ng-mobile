import 'package:flutter/material.dart';

enum AppSnackBarTone { info, success, warning, error }

class AppSnackBar {
  static void info(BuildContext context, String message) {
    show(context, message, tone: AppSnackBarTone.info);
  }

  static void success(BuildContext context, String message) {
    show(context, message, tone: AppSnackBarTone.success);
  }

  static void warning(BuildContext context, String message) {
    show(context, message, tone: AppSnackBarTone.warning);
  }

  static void error(BuildContext context, String message) {
    show(context, message, tone: AppSnackBarTone.error);
  }

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarTone tone = AppSnackBarTone.info,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final config = _SnackBarConfig.fromTone(tone);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: config.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Icon(config.icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class _SnackBarConfig {
  final Color backgroundColor;
  final IconData icon;

  const _SnackBarConfig({required this.backgroundColor, required this.icon});

  factory _SnackBarConfig.fromTone(AppSnackBarTone tone) {
    switch (tone) {
      case AppSnackBarTone.success:
        return const _SnackBarConfig(
          backgroundColor: Color(0xFF15803D),
          icon: Icons.check_circle_outline_rounded,
        );
      case AppSnackBarTone.warning:
        return const _SnackBarConfig(
          backgroundColor: Color(0xFFD97706),
          icon: Icons.warning_amber_rounded,
        );
      case AppSnackBarTone.error:
        return const _SnackBarConfig(
          backgroundColor: Color(0xFFDC2626),
          icon: Icons.error_outline_rounded,
        );
      case AppSnackBarTone.info:
        return const _SnackBarConfig(
          backgroundColor: Color(0xFF2563EB),
          icon: Icons.info_outline_rounded,
        );
    }
  }
}
