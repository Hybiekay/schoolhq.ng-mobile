import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart' as reverb;
import 'package:schoolhq_ng/core/hive/hive_key.dart';
import 'package:schoolhq_ng/core/network/school_urls.dart';
import 'package:schoolhq_ng/models/school_model.dart';

enum ChatRealtimeStatus { offline, connecting, live, reconnecting }

class ChatRealtimeEvent {
  final String name;
  final Map<String, dynamic> data;

  const ChatRealtimeEvent({required this.name, required this.data});
}

class ChatRealtimeService {
  reverb.ReverbClient? _client;
  reverb.PrivateChannel? _channel;
  StreamSubscription<reverb.ConnectionState>? _connectionStateSubscription;
  StreamSubscription<reverb.ChannelEvent>? _channelEventSubscription;
  final StreamController<ChatRealtimeEvent> _eventsController =
      StreamController<ChatRealtimeEvent>.broadcast();
  final ValueNotifier<ChatRealtimeStatus> statusNotifier =
      ValueNotifier<ChatRealtimeStatus>(ChatRealtimeStatus.offline);
  String? _connectionKey;
  String? _channelName;

  Stream<ChatRealtimeEvent> get events => _eventsController.stream;

  ChatRealtimeStatus get status => statusNotifier.value;

  Future<void> connectFromPayload(Map<String, dynamic> payload) async {
    final enabled = payload['enabled'] == true;
    final appKey = _stringValue(payload['app_key']);
    final host = _normalizeHost(_stringValue(payload['host']));
    final port = _intValue(payload['port']);
    final scheme = (_stringValue(payload['scheme']) ?? 'http').toLowerCase();
    final wsPath = _normalizeWebSocketPath(
      path: _stringValue(payload['ws_path']),
      appKey: appKey,
    );
    final authEndpoint = _resolveAuthEndpoint(
      _stringValue(payload['auth_path']),
    );
    final channelName = _stringValue(payload['channel_name']);
    final token = _currentToken();

    if (!enabled ||
        appKey == null ||
        host == null ||
        port == null ||
        authEndpoint == null ||
        channelName == null ||
        token == null) {
      await disconnect();
      return;
    }

    final nextConnectionKey =
        '$host|$port|$scheme|$appKey|$wsPath|$authEndpoint|$channelName|$token';

    if (_hasActiveConnection(nextConnectionKey, channelName)) {
      return;
    }

    await disconnect();
    // ignore: invalid_use_of_visible_for_testing_member
    reverb.ReverbClient.resetInstance();

    final client = reverb.ReverbClient.instance(
      host: host,
      port: port,
      appKey: appKey,
      authEndpoint: authEndpoint,
      wsPath: wsPath,
      useTLS: scheme == 'https',
      authorizer: (_, __) async => _authorizationHeaders(token),
      onConnecting: () => _setStatus(ChatRealtimeStatus.connecting),
      onConnected: (_) => _setStatus(ChatRealtimeStatus.live),
      onReconnecting: () => _setStatus(ChatRealtimeStatus.reconnecting),
      onDisconnected: () => _setStatus(ChatRealtimeStatus.offline),
      onError: (_) {
        _setStatus(
          _connectionKey == null
              ? ChatRealtimeStatus.offline
              : ChatRealtimeStatus.reconnecting,
        );
      },
    );

    _client = client;
    _connectionKey = nextConnectionKey;
    _channelName = channelName;

    _connectionStateSubscription = client.onConnectionStateChange.listen((
      state,
    ) {
      _setStatus(_statusFromState(state));

      if (state == reverb.ConnectionState.connected) {
        unawaited(_ensureChannelSubscription(forceResubscribe: true));
      }
    });

    await client.connect();
  }

  Future<void> disconnect() async {
    _connectionKey = null;

    final client = _client;
    final channelName = _channelName;

    await _channelEventSubscription?.cancel();
    _channelEventSubscription = null;

    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    if (client != null && channelName != null) {
      client.unsubscribeFromChannel(channelName);
    }

    _channel = null;
    _channelName = null;

    client?.disconnect();
    _client = null;
    // ignore: invalid_use_of_visible_for_testing_member
    reverb.ReverbClient.resetInstance();

    _setStatus(ChatRealtimeStatus.offline);
  }

  void dispose() {
    unawaited(disconnect());
    if (!_eventsController.isClosed) {
      unawaited(_eventsController.close());
    }
    statusNotifier.dispose();
  }

  Future<void> _ensureChannelSubscription({
    required bool forceResubscribe,
  }) async {
    final client = _client;
    final channelName = _channelName;

    if (client == null || channelName == null) {
      return;
    }

    if (forceResubscribe && _channel != null) {
      await _channelEventSubscription?.cancel();
      _channelEventSubscription = null;
      client.unsubscribeFromChannel(channelName);
      _channel = null;
    }

    if (_channel != null) {
      return;
    }

    final channel = client.subscribeToPrivateChannel(channelName);
    _channel = channel;
    _channelEventSubscription = channel
        .on('chat.message.created')
        .listen(
          (event) => _emit(event.eventName, _normalizeEventData(event.data)),
        );
  }

  bool _hasActiveConnection(String connectionKey, String channelName) {
    if (_connectionKey != connectionKey ||
        _channelName != channelName ||
        _client == null) {
      return false;
    }

    return status != ChatRealtimeStatus.offline;
  }

  void _emit(String name, dynamic data) {
    if (_eventsController.isClosed) {
      return;
    }

    _eventsController.add(ChatRealtimeEvent(name: name, data: _mapValue(data)));
  }

  void _setStatus(ChatRealtimeStatus nextStatus) {
    if (statusNotifier.value == nextStatus) {
      return;
    }

    statusNotifier.value = nextStatus;
  }

  ChatRealtimeStatus _statusFromState(reverb.ConnectionState state) {
    switch (state) {
      case reverb.ConnectionState.connected:
        return ChatRealtimeStatus.live;
      case reverb.ConnectionState.connecting:
        return ChatRealtimeStatus.connecting;
      case reverb.ConnectionState.reconnecting:
        return ChatRealtimeStatus.reconnecting;
      case reverb.ConnectionState.disconnected:
      case reverb.ConnectionState.error:
        return ChatRealtimeStatus.offline;
    }
  }

  String? _resolveAuthEndpoint(String? authPath) {
    if (authPath == null) {
      return null;
    }

    final box = Hive.box(HiveKey.boxApp);
    final school =
        SchoolModel.fromDynamic(box.get(HiveKey.selectedSchool)) ??
        SchoolModel.fromDynamic(box.get(HiveKey.userSchool));
    final baseUrl = resolveSchoolApiBaseUrl(school);
    final baseUri = Uri.tryParse(baseUrl);

    return baseUri?.resolve(authPath).toString();
  }

  String? _currentToken() {
    final token = Hive.box(HiveKey.boxApp).get(HiveKey.token);
    if (token is! String) {
      return null;
    }

    final trimmed = token.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Map<String, String> _authorizationHeaders(String token) {
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  String? _normalizeHost(String? host) {
    if (host == null) {
      return null;
    }

    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        (host == 'localhost' || host == '127.0.0.1')) {
      return '10.0.2.2';
    }

    return host;
  }

  String? _normalizeWebSocketPath({
    required String? path,
    required String? appKey,
  }) {
    if (path == null || appKey == null) {
      return null;
    }

    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final trimmedPath =
        normalizedPath.endsWith('/')
            ? normalizedPath.substring(0, normalizedPath.length - 1)
            : normalizedPath;

    if (trimmedPath.contains('/app/')) {
      return trimmedPath;
    }

    return '$trimmedPath/app/$appKey';
  }

  int? _intValue(dynamic value) {
    if (value is int) {
      return value > 0 ? value : null;
    }

    final parsed = int.tryParse('${value ?? ''}');
    if (parsed == null || parsed <= 0) {
      return null;
    }

    return parsed;
  }

  String? _stringValue(dynamic value) {
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  dynamic _normalizeEventData(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return const <String, dynamic>{};
      }

      try {
        return jsonDecode(trimmed);
      } catch (_) {
        return {'value': trimmed};
      }
    }

    return value;
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
