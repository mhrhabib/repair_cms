import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/core/services/socket_service.dart';
import 'package:repair_cms/features/messeges/models/message_model.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final SocketService socketService;
  final List<ConversationModel> _conversations = [];
  final List<MessageModel> _currentMessages = [];
  String? _currentConversationId;

  MessageCubit({required this.socketService}) : super(MessageInitial()) {
    _initializeListeners();
  }

  void _initializeListeners() {
    debugPrint('🚀 [MessageCubit] Initializing socket listeners');

    // Listen for new messages
    socketService.on('onUpdateMessage', (data) {
      debugPrint('📩 [MessageCubit] Received new message: $data');
      try {
        final message = MessageModel.fromJson(data);
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

  void _handleNewMessage(MessageModel message) {
    // If we're viewing this conversation, add it to current messages
    if (_currentConversationId == message.conversationId) {
      _currentMessages.add(message);
      emit(MessagesLoaded(messages: List.from(_currentMessages), conversationId: _currentConversationId!));
    }

    // Update conversations list
    _updateConversationWithNewMessage(message);
    emit(MessageReceived(message: message));
  }

  void _handleMessageSeen(dynamic data) {
    // Update seen status in current messages
    if (data is Map<String, dynamic> && data.containsKey('messageId')) {
      final messageId = data['messageId'];
      for (var msg in _currentMessages) {
        if (msg.id == messageId) {
          // Create updated message with seen = true
          final updatedMsg = MessageModel(
            id: msg.id,
            sender: msg.sender,
            receiver: msg.receiver,
            message: msg.message,
            seen: true,
            conversationId: msg.conversationId,
            userId: msg.userId,
            participants: msg.participants,
            loggedUserId: msg.loggedUserId,
            attachments: msg.attachments,
            createdAt: msg.createdAt,
            updatedAt: msg.updatedAt,
          );
          _currentMessages[_currentMessages.indexOf(msg)] = updatedMsg;
          break;
        }
      }
      if (_currentConversationId != null) {
        emit(MessagesLoaded(messages: List.from(_currentMessages), conversationId: _currentConversationId!));
      }
    }
  }

  void _handleInternalComment(dynamic data) {
    // Handle internal comment updates
    debugPrint('💬 Internal comment: $data');
    // You can emit a specific state for comments if needed
  }

  void _updateConversationWithNewMessage(MessageModel message) {
    final existingIndex = _conversations.indexWhere((c) => c.conversationId == message.conversationId);

    if (existingIndex != -1) {
      // Update existing conversation
      final existing = _conversations[existingIndex];
      final updated = ConversationModel(
        conversationId: existing.conversationId,
        participants: existing.participants,
        lastMessage: message,
        unreadCount: existing.unreadCount + 1,
        otherParticipant: existing.otherParticipant,
        lastMessageTime: message.createdAt ?? DateTime.now(),
      );
      _conversations[existingIndex] = updated;
    } else {
      // Add new conversation
      final newConversation = ConversationModel(
        conversationId: message.conversationId,
        participants: message.participants,
        lastMessage: message,
        unreadCount: 1,
        otherParticipant: message.sender,
        lastMessageTime: message.createdAt ?? DateTime.now(),
      );
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
    emit(MessagesLoaded(messages: List.from(_currentMessages), conversationId: conversationId));
  }

  void sendMessage({
    required String conversationId,
    required SenderReceiver sender,
    required SenderReceiver receiver,
    required String messageText,
    String messageType = 'standard',
    String? jobId,
    List<AttachmentModel>? attachments,
    required String userId,
    required String loggedUserId,
  }) {
    debugPrint('📤 [MessageCubit] Sending message');

    final messageData = {
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'message': {'message': messageText, 'messageType': messageType, if (jobId != null) 'jobId': jobId},
      'seen': false,
      'conversationId': conversationId,
      'userId': userId,
      'participants': '${sender.email}-${jobId ?? 'general'}-${receiver.email}',
      'loggedUserId': loggedUserId,
      if (attachments != null && attachments.isNotEmpty) 'attachment': attachments.map((a) => a.toJson()).toList(),
    };

    socketService.sendMessage(messageData);

    // Create local message and add to current messages
    final localMessage = MessageModel.fromJson(messageData);
    _currentMessages.add(localMessage);
    emit(MessagesLoaded(messages: List.from(_currentMessages), conversationId: conversationId));
    emit(MessageSent(message: localMessage));
  }

  void markAsRead(MessageModel message) {
    debugPrint('✅ [MessageCubit] Marking message as read');
    socketService.markAsRead(message.toJson());
  }

  void sendInternalComment({required Map<String, dynamic> message, required Map<String, dynamic> comment}) {
    debugPrint('💬 [MessageCubit] Sending internal comment');
    socketService.sendInternalComment({'message': message, 'comment': comment});
  }

  @override
  Future<void> close() {
    // Clean up socket listeners if needed
    debugPrint('🔌 [MessageCubit] Closing cubit');
    return super.close();
  }
}
