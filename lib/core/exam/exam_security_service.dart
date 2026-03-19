import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ExamSecurityEvent {
  final String type;
  final bool active;

  const ExamSecurityEvent({required this.type, required this.active});
}

class ExamSecurityService {
  ExamSecurityService._();

  static const MethodChannel _methodChannel = MethodChannel(
    'schoolhq_ng/exam_security',
  );
  static const EventChannel _eventChannel = EventChannel(
    'schoolhq_ng/exam_security/events',
  );

  static bool get _supportsNativeChannels =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> setSecureScreen(bool enabled) async {
    if (!_supportsNativeChannels) return;

    try {
      await _methodChannel.invokeMethod<void>('setSecureScreen', {
        'enabled': enabled,
      });
    } catch (_) {
      // Keep the exam flow alive even if the platform hook is unavailable.
    }
  }

  static Future<bool> isInMultiWindow() async {
    if (!_supportsNativeChannels) return false;

    try {
      final result = await _methodChannel.invokeMethod<bool>('isInMultiWindow');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Stream<ExamSecurityEvent> get events {
    if (!_supportsNativeChannels) {
      return const Stream<ExamSecurityEvent>.empty();
    }

    return _eventChannel.receiveBroadcastStream().map((event) {
      final payload = event is Map ? Map<Object?, Object?>.from(event) : const {};
      return ExamSecurityEvent(
        type: (payload['type'] ?? '').toString(),
        active: payload['active'] == true,
      );
    });
  }
}
