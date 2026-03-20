import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/feedback/app_snackbar.dart';
import 'package:schoolhq_ng/providers/chat_realtime_provider.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/views/home/messages/helpers/messages_helpers.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/message_bubble.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/message_composer_card.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/message_conversation_header_card.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/messages_empty_state.dart';

class MessageConversationScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const MessageConversationScreen({super.key, required this.conversationId});

  @override
  ConsumerState<MessageConversationScreen> createState() =>
      _MessageConversationScreenState();
}

class _MessageConversationScreenState
    extends ConsumerState<MessageConversationScreen> {
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  int _lastRenderedMessageCount = -1;
  Map<String, dynamic>? _conversationOverride;
  StreamSubscription? _realtimeEventsSubscription;
  late final VoidCallback _realtimeStatusListener;
  Future<void>? _refreshConversationOperation;

  @override
  void initState() {
    super.initState();
    final realtimeService = ref.read(chatRealtimeServiceProvider);

    _realtimeEventsSubscription = realtimeService.events.listen((event) {
      if (event.name != 'chat.message.created') {
        return;
      }

      ref.invalidate(mobileMessagesInboxProvider);

      final conversationId = event.data['conversation_id']?.toString();
      if (conversationId == widget.conversationId) {
        unawaited(_refreshConversation());
      }
    });

    _realtimeStatusListener = () {
      if (mounted) {
        setState(() {});
      }
    };

    realtimeService.statusNotifier.addListener(_realtimeStatusListener);
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    _realtimeEventsSubscription?.cancel();
    ref
        .read(chatRealtimeServiceProvider)
        .statusNotifier
        .removeListener(_realtimeStatusListener);
    super.dispose();
  }

  Future<void> _refreshConversation() async {
    final existingOperation = _refreshConversationOperation;
    if (existingOperation != null) {
      return existingOperation;
    }

    final operation = () async {
      ref.invalidate(mobileMessageConversationProvider(widget.conversationId));
      final refreshedPayload = await ref.read(
        mobileMessageConversationProvider(widget.conversationId).future,
      );
      ref.invalidate(mobileMessagesInboxProvider);
      ref.invalidate(mobileNotificationsProvider);
      ref.invalidate(mobileNotificationsSummaryProvider);

      if (mounted) {
        final refreshedConversation = messagesAsMap(
          refreshedPayload['conversation'],
        );
        final refreshedMessages = messagesAsList(
          refreshedConversation['messages'],
        );
        final optimisticMessages = messagesAsList(
          _conversationOverride?['messages'],
        );

        if (optimisticMessages.isEmpty ||
            _containsAllMessageIds(refreshedMessages, optimisticMessages)) {
          setState(() {
            _conversationOverride = null;
          });
        }
      }

      _scrollToLatest();
    }();

    _refreshConversationOperation = operation;
    await operation.whenComplete(() {
      if (identical(_refreshConversationOperation, operation)) {
        _refreshConversationOperation = null;
      }
    });
  }

  void _syncRealtime(dynamic value) {
    final realtimePayload = messagesAsMap(value);
    unawaited(
      ref.read(chatRealtimeServiceProvider).connectFromPayload(realtimePayload),
    );
  }

  Future<void> _sendMessage() async {
    final body = _composerController.text.trim();
    if (body.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final response = await ref
          .read(mobileRepositoryProvider)
          .sendMessage(conversationId: widget.conversationId, body: body);
      final sentMessage = messagesAsMap(response['message']);
      final currentPayload = ref
          .read(mobileMessageConversationProvider(widget.conversationId))
          .asData
          ?.value;
      final baseConversation = _displayConversation(
        messagesAsMap(currentPayload?['conversation']),
      );

      if (mounted) {
        setState(() {
          _conversationOverride = _appendMessageToConversation(
            conversation: baseConversation,
            message: sentMessage,
          );
        });
      }

      _composerController.clear();
      ref.invalidate(mobileMessagesInboxProvider);
      ref.invalidate(mobileNotificationsProvider);
      ref.invalidate(mobileNotificationsSummaryProvider);
      unawaited(_refreshConversation());
      _scrollToLatest();
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToLatest({bool animated = true}) {
    unawaited(_performScrollToLatest(animated: animated));
  }

  Future<void> _performScrollToLatest({required bool animated}) async {
    if (!mounted) {
      return;
    }

    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;

    if (!_scrollController.hasClients) {
      return;
    }

    final targetOffset = _scrollController.position.maxScrollExtent;

    if (!animated) {
      _scrollController.jumpTo(targetOffset);
      return;
    }

    final currentOffset = _scrollController.offset;
    if ((targetOffset - currentOffset).abs() < 4) {
      return;
    }

    try {
      await _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {
      return;
    }

    if (!_scrollController.hasClients) {
      return;
    }

    final settledOffset = _scrollController.position.maxScrollExtent;
    if ((_scrollController.offset - settledOffset).abs() > 4) {
      _scrollController.jumpTo(settledOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final realtimeStatus = ref
        .read(chatRealtimeServiceProvider)
        .statusNotifier
        .value;
    final conversationAsync = ref.watch(
      mobileMessageConversationProvider(widget.conversationId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: conversationAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Column(
              children: [
                MessageConversationHeaderCard(
                  participant: const {
                    'full_name': 'Messages',
                    'role': 'student',
                    'subtitle': 'Conversation unavailable',
                  },
                  realtimeStatus: realtimeStatus,
                  onBack: () {
                    context.pop();
                  },
                  onRefresh: _refreshConversation,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: MessagesEmptyState(
                    icon: Icons.wifi_off_rounded,
                    title: 'Conversation unavailable',
                    message: error.toString(),
                  ),
                ),
              ],
            ),
            data: (payload) {
              _syncRealtime(payload['realtime']);
              final conversation = _displayConversation(
                messagesAsMap(payload['conversation']),
              );
              final participant = messagesAsMap(conversation['participant']);
              final messages = messagesAsList(conversation['messages']);
              final previousMessageCount = _lastRenderedMessageCount;
              if (previousMessageCount != messages.length) {
                _lastRenderedMessageCount = messages.length;
                _scrollToLatest(animated: previousMessageCount >= 0);
              }

              return Column(
                children: [
                  MessageConversationHeaderCard(
                    participant: participant,
                    realtimeStatus: realtimeStatus,
                    onBack: () {
                      context.pop();
                    },
                    onRefresh: _refreshConversation,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.surfaceMuted),
                      ),
                      child: RefreshIndicator(
                        onRefresh: _refreshConversation,
                        child: ListView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: messages.isEmpty
                              ? const [
                                  MessagesEmptyState(
                                    icon: Icons.chat_bubble_outline_rounded,
                                    title: 'No messages yet',
                                    message:
                                        'Send the first message to begin this conversation.',
                                  ),
                                ]
                              : messages
                                    .map(
                                      (message) =>
                                          MessageBubble(message: message),
                                    )
                                    .toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  MessageComposerCard(
                    controller: _composerController,
                    isSending: _isSending,
                    onSend: _sendMessage,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _displayConversation(Map<String, dynamic> conversation) {
    final override = _conversationOverride;
    if (override == null || override.isEmpty) {
      return conversation;
    }

    final providerMessages = messagesAsList(conversation['messages']);
    final optimisticMessages = messagesAsList(override['messages']);

    if (_containsAllMessageIds(providerMessages, optimisticMessages) &&
        providerMessages.length >= optimisticMessages.length) {
      return conversation;
    }

    return override;
  }

  Map<String, dynamic> _appendMessageToConversation({
    required Map<String, dynamic> conversation,
    required Map<String, dynamic> message,
  }) {
    final existingMessages = messagesAsList(conversation['messages']);
    final messageId = message['id']?.toString();

    final alreadyExists = existingMessages.any(
      (item) => item['id']?.toString() == messageId,
    );

    return {
      ...conversation,
      'messages': alreadyExists
          ? existingMessages
          : [...existingMessages, message],
    };
  }

  bool _containsAllMessageIds(
    List<Map<String, dynamic>> currentMessages,
    List<Map<String, dynamic>> expectedMessages,
  ) {
    final currentIds = currentMessages
        .map((message) => message['id']?.toString())
        .whereType<String>()
        .toSet();

    final expectedIds = expectedMessages
        .map((message) => message['id']?.toString())
        .whereType<String>()
        .toSet();

    return expectedIds.every(currentIds.contains);
  }
}
