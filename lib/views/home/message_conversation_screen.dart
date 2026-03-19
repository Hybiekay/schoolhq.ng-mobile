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

  const MessageConversationScreen({
    super.key,
    required this.conversationId,
  });

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
      await ref.read(
        mobileMessageConversationProvider(widget.conversationId).future,
      );
      ref.invalidate(mobileMessagesInboxProvider);
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
      await ref.read(mobileRepositoryProvider).sendMessage(
            conversationId: widget.conversationId,
            body: body,
          );
      _composerController.clear();
      await _refreshConversation();
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

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final realtimeStatus =
        ref.read(chatRealtimeServiceProvider).statusNotifier.value;
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
              final conversation = messagesAsMap(payload['conversation']);
              final participant = messagesAsMap(conversation['participant']);
              final messages = messagesAsList(conversation['messages']);
              if (_lastRenderedMessageCount != messages.length) {
                _lastRenderedMessageCount = messages.length;
                _scrollToLatest();
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
                                    (message) => MessageBubble(message: message),
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
}
