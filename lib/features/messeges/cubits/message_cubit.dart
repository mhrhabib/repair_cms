import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/services/socket_service.dart';
import 'package:repair_cms/core/services/local_notification_service.dart';
import 'package:repair_cms/features/messeges/models/conversation_model.dart';
import 'package:repair_cms/features/messeges/models/message_model.dart';
import 'package:repair_cms/features/messeges/repository/message_repository.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final SocketService socketService;
  final MessageRepository messageRepository;
  final LocalNotificationService notificationService;
  final List<Conversation> _conversations = [];

  String? _currentConversationId;

  MessageCubit({required this.socketService, required this.messageRepository, required this.notificationService})
    : super(MessageInitial()) {
    _initializeListeners();
  }

  /// Load conversation messages from API
  Future<void> loadConversation({required String conversationId}) async {
    try {
      debugPrint('🔄 [MessageCubit] Loading conversation: $conversationId');
      emit(MessageLoading());

      _currentConversationId = conversationId;
      final conversationModel = await messageRepository.getConversation(conversationId: conversationId);

      // Clear existing conversations
      _conversations.clear();

      // Check if we have data (even if success is false, data might be empty list)
      if (conversationModel.data != null) {
        _conversations.addAll(conversationModel.data!);
      }

      final messageCount = conversationModel.data?.length ?? 0;
      debugPrint(
        '✅ [MessageCubit] Loaded $messageCount messages (Page info: ${conversationModel.pages} pages, ${conversationModel.total} total)',
      );

      // Always emit MessagesLoaded, even if empty (let UI show empty state)
      emit(MessagesLoaded(messages: _conversations, conversationId: conversationId));

      // Only emit error if there's an actual error AND no data was returned
      if (conversationModel.success == false && messageCount == 0) {
        final errorMsg = conversationModel.message ?? conversationModel.error ?? '';
        // Only log as info if it's just "not found" (empty conversation)
        if (errorMsg.toLowerCase().contains('not found')) {
          debugPrint('ℹ️ [MessageCubit] Empty conversation: $errorMsg');
        } else {
          // Real error - log and potentially show to user
          debugPrint('❌ [MessageCubit] API error: $errorMsg');
        }
      }
    } on MessageException catch (e) {
      debugPrint('❌ [MessageCubit] MessageException: ${e.message}');
      emit(MessageError(message: e.message));
    } catch (e) {
      debugPrint('❌ [MessageCubit] Error loading conversation: $e');
      emit(MessageError(message: 'Failed to load conversation: $e'));
    }
  }

  void _initializeListeners() {
    debugPrint('🚀 [MessageCubit] Initializing socket listeners');

    // Listen for new messages
    socketService.on('onUpdateMessage', (data) {
      debugPrint('📩 [MessageCubit] Received new message: $data');
      try {
        final message = Conversation.fromJson(data);
        _handleNewMessage(message);
      } catch (e) {
        debugPrint('❌ [MessageCubit] Error parsing message: $e');
      }
    });

    // Listen for message seen updates
    socketService.on('messageSeen', (data) {
      debugPrint('👁️ [MessageCubit] Message seen: $data');
      _handleMessageSeen(data);
    });
    socketService.on('receiveMessage', (data) {
      debugPrint('👁️ [MessageCubit] Message seen: $data');
      // _handleMessageSeen(data);
    });

    // Listen for internal comment updates
    socketService.on('updateInternalComment', (data) {
      debugPrint('💬 [MessageCubit] Internal comment update: $data');
      _handleInternalComment(data);
    });
  }

  void _handleNewMessage(Conversation message) {
    // If we're viewing this conversation, add it to current messages
    if (_currentConversationId == message.conversationId) {
      _conversations.add(message);
      emit(MessagesLoaded(messages: List.from(_conversations), conversationId: _currentConversationId!));
    }

    // Update conversations list
    _updateConversationWithNewMessage(message);
    emit(MessageReceived(message: message));

    // Show notification if message is from another user
    _showNotificationForNewMessage(message);
  }

  /// Show notification for new incoming message
  void _showNotificationForNewMessage(Conversation message) {
    try {
      final storage = GetStorage();
      final currentUserId = storage.read('userId');
      final currentUserEmail = storage.read('email');

      // Don't show notification if user sent this message
      final isOwnMessage = message.sender?.email == currentUserEmail || message.loggedUserId == currentUserId;

      if (isOwnMessage) {
        debugPrint('ℹ️ [MessageCubit] Skipping notification - own message');
        return;
      }

      // Extract message details
      final senderName = message.sender?.name ?? 'Someone';
      final messageText = message.message?.message ?? 'New message';
      final conversationId = message.conversationId ?? '';
      final jobId = message.message?.jobId;

      debugPrint('🔔 [MessageCubit] Showing notification from: $senderName');

      // Show notification
      notificationService.showMessageNotification(
        senderName: senderName,
        messageText: messageText,
        conversationId: conversationId,
        jobId: jobId,
      );
    } catch (e) {
      debugPrint('❌ [MessageCubit] Error showing notification: $e');
    }
  }

  void _handleMessageSeen(dynamic data) {
    // Update seen status in current messages
    if (data is Map<String, dynamic> && data.containsKey('messageId')) {
      final messageId = data['messageId'];
      for (var msg in _conversations) {
        if (msg.id == messageId) {
          // Create updated message with seen = true
          final updatedMsg = Conversation(
            id: msg.id,
            sender: msg.sender,
            receiver: msg.receiver,
            message: msg.message,
            seen: true,
            conversationId: msg.conversationId,
            userId: msg.userId,
            participants: msg.participants,
            loggedUserId: msg.loggedUserId,

            createdAt: msg.createdAt,
            updatedAt: msg.updatedAt,
          );
          _conversations[_conversations.indexOf(msg)] = updatedMsg;
          break;
        }
      }
      if (_currentConversationId != null) {
        emit(MessagesLoaded(messages: List.from(_conversations), conversationId: _currentConversationId!));
      }
    }
  }

  void _handleInternalComment(dynamic data) {
    // Handle internal comment updates
    debugPrint('💬 Internal comment: $data');
    // You can emit a specific state for comments if needed
  }

  void _updateConversationWithNewMessage(Conversation message) {
    final existingIndex = _conversations.indexWhere((c) => c.conversationId == message.conversationId);

    if (existingIndex != -1) {
      // Update existing conversation
      final existing = _conversations[existingIndex];
      final updated = Conversation(conversationId: existing.conversationId, participants: existing.participants);
      _conversations[existingIndex] = updated;
    } else {
      // Add new conversation
      final newConversation = Conversation(conversationId: message.conversationId, participants: message.participants);
      _conversations.insert(0, newConversation);
    }

    emit(ConversationsLoaded(conversations: List.from(_conversations)));
  }

  void loadConversations() {
    debugPrint('📋 [MessageCubit] Loading conversations');
    emit(MessageLoading());

    // For now, emit loaded with existing conversations
    // In production, fetch from API
    emit(ConversationsLoaded(conversations: List.from(_conversations)));
  }

  void loadMessages(String conversationId) {
    debugPrint('📋 [MessageCubit] Loading messages for conversation: $conversationId');
    emit(MessageLoading());
    _currentConversationId = conversationId;

    // In production, fetch messages from API
    // For now, emit empty list
    emit(MessagesLoaded(messages: List.from(_conversations), conversationId: conversationId));
  }

  void sendMessage({
    required String conversationId,
    required SenderReceiver sender,
    required SenderReceiver receiver,
    required String messageText,
    String messageType = 'standard',
    String? jobId,
    required String userId,
    required String loggedUserId,
  }) {
    debugPrint('📤 [MessageCubit] Sending message');

    // Create MessageModel for sending
    final messageModel = MessageModel(
      sender: sender,
      receiver: receiver,
      message: MessageContent(message: messageText, messageType: messageType, jobId: jobId),
      seen: false,
      conversationId: conversationId,
      userId: userId,
      participants: '${sender.email}-${jobId ?? 'general'}-${receiver.email}',
      loggedUserId: loggedUserId,
      createdAt: DateTime.now(),
    );

    socketService.sendMessage(messageModel.toJson());

    // Create local Conversation object from sent message for display
    final localConversation = Conversation(
      sender: Sender(email: sender.email, name: sender.name),
      receiver: Sender(email: receiver.email, name: receiver.name),
      message: Message(message: messageText, messageType: messageType, jobId: jobId),
      seen: false,
      conversationId: conversationId,
      participants: '${sender.email}-${jobId ?? 'general'}-${receiver.email}',
      loggedUserId: loggedUserId,
      createdAt: DateTime.now().toIso8601String(),
    );

    _conversations.add(localConversation);
    emit(MessagesLoaded(messages: List.from(_conversations), conversationId: conversationId));
    emit(MessageSent(message: localConversation));
  }

  void markAsRead(Conversation message) {
    debugPrint('✅ [MessageCubit] Marking message as read');
    if (!socketService.isConnected) {
      debugPrint('⚠️ [MessageCubit] Socket not connected, cannot mark as read');
      return;
    }
    socketService.markAsRead(message.toJson());
  }

  void sendInternalComment({required Map<String, dynamic> message, required Map<String, dynamic> comment}) {
    debugPrint('💬 [MessageCubit] Sending internal comment');
    if (!socketService.isConnected) {
      debugPrint('❌ [MessageCubit] Socket not connected, cannot send comment');
      emit(MessageError(message: 'Not connected to server. Please check your connection.'));
      return;
    }
    socketService.sendInternalComment({'message': message, 'comment': comment});
  }

  @override
  Future<void> close() {
    // Clean up socket listeners to prevent memory leaks
    debugPrint('🔌 [MessageCubit] Closing cubit and removing socket listeners');
    socketService.off('onUpdateMessage');
    socketService.off('messageSeen');
    socketService.off('receiveMessage');
    socketService.off('updateInternalComment');
    return super.close();
  }
}
