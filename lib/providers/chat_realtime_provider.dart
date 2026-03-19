import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/messages/chat_realtime_service.dart';

final chatRealtimeServiceProvider = Provider<ChatRealtimeService>((ref) {
  final service = ChatRealtimeService();
  ref.onDispose(service.dispose);
  return service;
});
