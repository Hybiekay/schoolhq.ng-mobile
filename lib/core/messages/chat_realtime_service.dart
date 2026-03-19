import 'dart:async';

import 'package:flint_client/flint_client.dart';
import 'package:flutter/foundation.dart';

enum ChatRealtimeStatus {
  offline,
  connecting,
  live,
  reconnecting,
}

class ChatRealtimeEvent {
  final String name;
  final Map<String, dynamic> data;

  const ChatRealtimeEvent({
    required this.name,
    required this.data,
  });
}

class ChatRealtimeService {
  FlintClient? _client;
  FlintWebSocketClient? _socket;
  final StreamController<ChatRealtimeEvent> _eventsController =
      StreamController<ChatRealtimeEvent>.broadcast();
  final ValueNotifier<ChatRealtimeStatus> statusNotifier =
      ValueNotifier<ChatRealtimeStatus>(ChatRealtimeStatus.offline);
  String? _connectionKey;

  Stream<ChatRealtimeEvent> get events => _eventsController.stream;

  ChatRealtimeStatus get status => statusNotifier.value;

  Future<void> connectFromPayload(Map<String, dynamic> payload) async {
    final enabled = payload['enabled'] == true;
    final httpBaseUrl = _stringValue(payload['http_base_url']);
    final path = _stringValue(payload['path']) ?? '/ws';
    final token = _stringValue(payload['token']);

    if (!enabled || httpBaseUrl == null || token == null) {
      await disconnect();
      return;
    }

    final nextConnectionKey = '$httpBaseUrl|$path|$token';
    if (_hasActiveConnection(nextConnectionKey)) {
      return;
    }

    _disposeSocket();

    _connectionKey = nextConnectionKey;
    _client = FlintClient(
      baseUrl: httpBaseUrl,
      timeout: const Duration(seconds: 15),
    );

    final socket = _client!.ws(
      path,
      params: {'token': token},
    );

    _socket = socket;
    _bindSocket(socket);
    _setStatus(ChatRealtimeStatus.connecting);
    unawaited(socket.connect());
  }

  Future<void> disconnect() async {
    _connectionKey = null;
    _disposeSocket();
    _setStatus(ChatRealtimeStatus.offline);
  }

  void dispose() {
    _connectionKey = null;
    _disposeSocket();
    if (!_eventsController.isClosed) {
      unawaited(_eventsController.close());
    }
    statusNotifier.dispose();
  }

  void _bindSocket(FlintWebSocketClient socket) {
    socket.on('connect', (_) {
      if (!identical(_socket, socket)) {
        return;
      }

      _setStatus(ChatRealtimeStatus.live);
    });

    socket.on('state_change', (dynamic state) {
      if (!identical(_socket, socket)) {
        return;
      }

      _setStatus(_statusFromState(state));
    });

    socket.on('disconnect', (_) {
      if (!identical(_socket, socket)) {
        return;
      }

      if (_connectionKey != null) {
        _setStatus(ChatRealtimeStatus.reconnecting);
      }
    });

    socket.on('reconnect_failed', (_) {
      if (!identical(_socket, socket)) {
        return;
      }

      _setStatus(ChatRealtimeStatus.offline);
    });

    socket.on('chat.connected', (dynamic data) {
      if (!identical(_socket, socket)) {
        return;
      }

      _setStatus(ChatRealtimeStatus.live);
      _emit('chat.connected', data);
    });

    socket.on('chat.message.created', (dynamic data) {
      if (!identical(_socket, socket)) {
        return;
      }

      _emit('chat.message.created', data);
    });
  }

  void _disposeSocket() {
    final socket = _socket;
    _socket = null;

    if (socket != null) {
      socket.dispose();
    }

    _client?.dispose();
    _client = null;
  }

  bool _hasActiveConnection(String connectionKey) {
    if (_connectionKey != connectionKey || _socket == null) {
      return false;
    }

    final state = _socket!.state;
    return state == WebSocketConnectionState.connected ||
        state == WebSocketConnectionState.connecting ||
        state == WebSocketConnectionState.reconnecting;
  }

  void _emit(String name, dynamic data) {
    if (_eventsController.isClosed) {
      return;
    }

    _eventsController.add(
      ChatRealtimeEvent(
        name: name,
        data: _mapValue(data),
      ),
    );
  }

  void _setStatus(ChatRealtimeStatus nextStatus) {
    if (statusNotifier.value == nextStatus) {
      return;
    }

    statusNotifier.value = nextStatus;
  }

  ChatRealtimeStatus _statusFromState(dynamic state) {
    if (state is WebSocketConnectionState) {
      switch (state) {
        case WebSocketConnectionState.connected:
          return ChatRealtimeStatus.live;
        case WebSocketConnectionState.connecting:
          return ChatRealtimeStatus.connecting;
        case WebSocketConnectionState.reconnecting:
          return ChatRealtimeStatus.reconnecting;
        case WebSocketConnectionState.disconnected:
          return ChatRealtimeStatus.offline;
      }
    }

    final normalized = state.toString().split('.').last.toLowerCase();
    switch (normalized) {
      case 'connected':
        return ChatRealtimeStatus.live;
      case 'connecting':
        return ChatRealtimeStatus.connecting;
      case 'reconnecting':
        return ChatRealtimeStatus.reconnecting;
      case 'disconnected':
      default:
        return ChatRealtimeStatus.offline;
    }
  }

  String? _stringValue(dynamic value) {
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Map<String, dynamic> _mapValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const <String, dynamic>{};
  }
}
