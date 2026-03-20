import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/feedback/app_snackbar.dart';
import 'package:schoolhq_ng/providers/chat_realtime_provider.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/views/home/messages/helpers/messages_helpers.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/message_contact_chip.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/message_conversation_card.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/messages_empty_state.dart';
import 'package:schoolhq_ng/views/home/messages/widgets/messages_intro_card.dart';
import 'package:schoolhq_ng/views/home/shared/widgets/mobile_top_action_bar.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _startingContactId;
  StreamSubscription? _realtimeEventsSubscription;
  late final VoidCallback _realtimeStatusListener;
  Future<void>? _refreshInboxOperation;

  @override
  void initState() {
    super.initState();
    final realtimeService = ref.read(chatRealtimeServiceProvider);

    _realtimeEventsSubscription = realtimeService.events.listen((event) {
      if (event.name != 'chat.message.created') {
        return;
      }

      unawaited(_refreshInbox());
    });

    _realtimeStatusListener = () {
      if (mounted) {
        setState(() {});
      }
    };

    realtimeService.statusNotifier.addListener(_realtimeStatusListener);
  }

  Future<void> _refreshInbox() async {
    final existingOperation = _refreshInboxOperation;
    if (existingOperation != null) {
      return existingOperation;
    }

    final operation = () async {
      ref.invalidate(mobileMessagesInboxProvider);
      ref.invalidate(mobileNotificationsProvider);
      ref.invalidate(mobileNotificationsSummaryProvider);
      await ref.read(mobileMessagesInboxProvider.future);
    }();

    _refreshInboxOperation = operation;
    await operation.whenComplete(() {
      if (identical(_refreshInboxOperation, operation)) {
        _refreshInboxOperation = null;
      }
    });
  }

  void _syncRealtime(dynamic value) {
    final realtimePayload = messagesAsMap(value);
    unawaited(
      ref.read(chatRealtimeServiceProvider).connectFromPayload(realtimePayload),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _realtimeEventsSubscription?.cancel();
    ref
        .read(chatRealtimeServiceProvider)
        .statusNotifier
        .removeListener(_realtimeStatusListener);
    super.dispose();
  }

  Future<void> _openConversation(Map<String, dynamic> conversation) async {
    final conversationId = conversation['id']?.toString();
    if (conversationId == null || conversationId.isEmpty) {
      return;
    }

    await context.push(RouteNames.messageConversationPath(conversationId));
    await _refreshInbox();
  }

  Future<void> _openContact(Map<String, dynamic> contact) async {
    final contactId = contact['id']?.toString();
    if (contactId == null || contactId.isEmpty) {
      return;
    }

    setState(() {
      _startingContactId = contactId;
    });

    try {
      final payload = await ref
          .read(mobileRepositoryProvider)
          .startMessageConversation(contactId);
      ref.invalidate(mobileMessagesInboxProvider);

      final conversation = messagesAsMap(payload['conversation']);
      final conversationId = conversation['id']?.toString();

      if (conversationId != null && conversationId.isNotEmpty && mounted) {
        await context.push(RouteNames.messageConversationPath(conversationId));
        await _refreshInbox();
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _startingContactId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserRoleProvider);
    final realtimeStatus = ref
        .read(chatRealtimeServiceProvider)
        .statusNotifier
        .value;
    final messagingEnabled = role == 'student' || role == 'teacher';
    final inboxAsync = messagingEnabled
        ? ref.watch(mobileMessagesInboxProvider)
        : const AsyncValue<Map<String, dynamic>>.data({
            'contacts': <Map<String, dynamic>>[],
            'conversations': <Map<String, dynamic>>[],
          });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: messagingEnabled ? _refreshInbox : () async {},
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              MobileTopActionBar(
                title: 'Messages',
                subtitle:
                    'Open direct school conversations and stay in sync with the backend.',
                gradient: AppColors.accentGradient,
                onRefresh: messagingEnabled ? _refreshInbox : null,
              ),
              const SizedBox(height: 16),
              if (!messagingEnabled)
                const MessagesEmptyState(
                  icon: Icons.lock_outline_rounded,
                  title: 'Messaging is not enabled here',
                  message:
                      'Student and teacher accounts can open the message world and chat with approved school contacts.',
                )
              else
                inboxAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => MessagesEmptyState(
                    icon: Icons.wifi_off_rounded,
                    title: 'Messages could not load',
                    message: error.toString(),
                  ),
                  data: (payload) {
                    _syncRealtime(payload['realtime']);
                    final contacts = messagesAsList(payload['contacts']);
                    final conversations = messagesAsList(
                      payload['conversations'],
                    );
                    final search = _searchQuery.trim().toLowerCase();

                    final filteredContacts = search.isEmpty
                        ? contacts
                        : contacts.where((contact) {
                            final combined = [
                              contact['full_name'],
                              contact['subtitle'],
                              contact['role'],
                            ].join(' ').toLowerCase();
                            return combined.contains(search);
                          }).toList();

                    final filteredConversations = search.isEmpty
                        ? conversations
                        : conversations.where((conversation) {
                            final participant = messagesAsMap(
                              conversation['participant'],
                            );
                            final combined = [
                              participant['full_name'],
                              participant['subtitle'],
                              conversation['last_message_preview'],
                            ].join(' ').toLowerCase();
                            return combined.contains(search);
                          }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MessagesIntroCard(
                          role: role,
                          contactCount: contacts.length,
                          conversationCount: conversations.length,
                          realtimeStatus: realtimeStatus,
                          searchController: _searchController,
                          onSearchChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Start a New Chat',
                          style: AppTextStyles.headingMedium,
                        ),
                        const SizedBox(height: 10),
                        if (filteredContacts.isEmpty)
                          const MessagesEmptyState(
                            icon: Icons.group_outlined,
                            title: 'No contacts found',
                            message:
                                'When classmates or students are available for you, they will show here.',
                          )
                        else
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredContacts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final contact = filteredContacts[index];
                                final contactId = contact['id']?.toString();

                                return MessageContactChip(
                                  contact: contact,
                                  isLoading: _startingContactId == contactId,
                                  onTap: () {
                                    _openContact(contact);
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          'Recent Conversations',
                          style: AppTextStyles.headingMedium,
                        ),
                        const SizedBox(height: 10),
                        if (filteredConversations.isEmpty)
                          const MessagesEmptyState(
                            icon: Icons.mark_chat_unread_outlined,
                            title: 'No conversations yet',
                            message:
                                'Start with a class contact to create your first conversation.',
                          )
                        else
                          ...filteredConversations.map(
                            (conversation) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: MessageConversationCard(
                                conversation: conversation,
                                onTap: () {
                                  _openConversation(conversation);
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
