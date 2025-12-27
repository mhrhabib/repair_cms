import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/services/socket_service.dart';
import 'package:repair_cms/core/services/local_notification_service.dart';
import 'package:repair_cms/features/messeges/models/conversation_model.dart';
import 'package:repair_cms/features/messeges/models/message_model.dart';
import 'package:repair_cms/features/messeges/models/sub_user_model.dart';
import 'package:repair_cms/features/messeges/repository/message_repository.dart';

part 'message_state.dart';

/// Custom exception for message operations
class MessageException implements Exception {
  final String message;
  final int? statusCode;

  MessageException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

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

  /// Sort messages by createdAt to ensure chronological order (oldest first)
  void _sortMessages() {
    _conversations.sort((a, b) {
      final dateA = _parseDateTime(a.createdAt);
      final dateB = _parseDateTime(b.createdAt);
      if (dateA == null || dateB == null) return 0;
      return dateA.compareTo(dateB); // Oldest first
    });
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
        _sortMessages();

        debugPrint('📋 [MessageCubit] Messages sorted by date (oldest first)');
        if (_conversations.isNotEmpty) {
          debugPrint('   First message: ${_conversations.first.message?.message} (${_conversations.first.createdAt})');
          debugPrint('   Last message: ${_conversations.last.message?.message} (${_conversations.last.createdAt})');
        }
      }

      final messageCount = conversationModel.data?.length ?? 0;
      debugPrint(
        '✅ [MessageCubit] Loaded $messageCount messages (Page info: ${conversationModel.pages} pages, ${conversationModel.total} total)',
      );

      // Always emit MessagesLoaded, even if empty (let UI show empty state)
      emit(MessagesLoaded(messages: List.from(_conversations), conversationId: conversationId));

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

  /// Load sub users for the current user (for internal messaging)
  Future<void> getSubUsers({required String userId}) async {
    try {
      debugPrint('🔄 [MessageCubit] Loading sub users for user: $userId');
      emit(MessageLoading());

      final subUsers = await messageRepository.getSubUsers(userId: userId);

      debugPrint('✅ [MessageCubit] Loaded ${subUsers.length} sub users');
      emit(SubUsersLoaded(subUsers: subUsers));
    } on MessageException catch (e) {
      debugPrint('❌ [MessageCubit] MessageException: ${e.message}');
      emit(SubUsersError(message: e.message));
    } catch (e) {
      debugPrint('❌ [MessageCubit] Error loading sub users: $e');
      emit(SubUsersError(message: 'Failed to load sub users: $e'));
    }
  }

  void _initializeListeners() {
    debugPrint('🚀 [MessageCubit] Initializing socket listeners');

    // Listen for new messages
    socketService.on('onUpdateMessage', (data) {
      debugPrint('📩 [MessageCubit] onUpdateMessage event: $data');
      _handleIncomingSocketMessage(data);
    });

    // Alias for new messages
    socketService.on('newMessage', (data) {
      debugPrint('📩 [MessageCubit] newMessage event: $data');
      _handleIncomingSocketMessage(data);
    });

    // Generic message listener
    socketService.on('message', (data) {
      debugPrint('📩 [MessageCubit] message event: $data');
      _handleIncomingSocketMessage(data);
    });

    // Receive message listener - used by some backend versions
    socketService.on('receiveMessage', (data) {
      debugPrint('📩 [MessageCubit] receiveMessage event: $data');
      _handleIncomingSocketMessage(data);
    });

    // Listen for message seen updates
    socketService.on('messageSeen', (data) {
      debugPrint('👁️ [MessageCubit] messageSeen event: $data');
      _handleMessageSeen(data);
    });

    // Listen for internal comment updates
    socketService.on('updateInternalComment', (data) {
      debugPrint('💬 [MessageCubit] updateInternalComment: $data');
      _handleInternalComment(data);
    });

    // Listen for internal comments from RCMS
    socketService.on('internalCommentFromRCMS', (data) {
      debugPrint('💬 [MessageCubit] internalCommentFromRCMS: $data');
      _handleInternalCommentFromRCMS(data);
    });
  }

  /// Helper to handle incoming socket messages for any message-related event
  void _handleIncomingSocketMessage(dynamic data) {
    debugPrint('📩 [MessageCubit] ========================================');
    debugPrint('📩 [MessageCubit] Handling incoming socket data');
    debugPrint('📩 [MessageCubit] Data Type: ${data.runtimeType}');
    debugPrint('📩 [MessageCubit] ========================================');

    try {
      if (data == null) return;
      final message = Conversation.fromJson(data is String ? jsonDecode(data) : data);
      _handleNewMessage(message);
    } catch (e) {
      debugPrint('❌ [MessageCubit] Error parsing socket message: $e');
    }
  }

  void _handleNewMessage(Conversation message) {
    // If we're viewing this conversation, add it to current messages
    if (_currentConversationId == message.conversationId) {
      // Check for duplicates (by id or content/timestamp)
      final isDuplicate = _conversations.any((c) {
        // Match by server-side ID if available
        if (c.sId != null && message.sId != null && c.sId == message.sId) return true;
        if (c.id != null && message.id != null && c.id == message.id) return true;

        // Fallback: match by sender, message content and timestamp
        // (with a small tolerance for local vs server timestamps)
        final sameSender = c.sender?.email == message.sender?.email;
        final sameContent = c.message?.message == message.message?.message;
        if (sameSender && sameContent) {
          final dateA = _parseDateTime(c.createdAt);
          final dateB = _parseDateTime(message.createdAt);
          if (dateA != null && dateB != null) {
            final diff = dateA.difference(dateB).abs();
            return diff.inSeconds < 5; // Allow for 5 seconds variation
          }
        }
        return false;
      });

      if (isDuplicate) {
        debugPrint('ℹ️ [MessageCubit] Duplicate message received, skipping addition to list');
      } else {
        _conversations.add(message);
        _sortMessages();
        debugPrint('📝 [MessageCubit] Added new socket message to list. Total: ${_conversations.length}');
      }
    }

    // Update conversations list (latest message summary)
    _updateConversationWithNewMessage(message);

    emit(
      MessageReceived(
        message: message,
        messages: List.from(_conversations),
        conversationId: _currentConversationId ?? message.conversationId ?? '',
      ),
    );

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

  void _handleInternalCommentFromRCMS(dynamic data) {
    debugPrint('💬 [MessageCubit] Handling internal comment from RCMS: $data');

    try {
      if (data == null) return;

      // Parse the {message, comment} structure
      final Map<String, dynamic> parsedData = data is String ? jsonDecode(data) : data;

      // Extract message and comment
      final messageData = parsedData['message'];
      final commentData = parsedData['comment'];

      if (messageData != null) {
        final message = Conversation.fromJson(messageData);
        debugPrint('💬 [MessageCubit] Processing message part: ${message.conversationId}');

        // Handle the message part like a regular incoming message
        _handleNewMessage(message);
      }

      if (commentData != null) {
        final comment = Comment.fromJson(commentData);
        debugPrint('💬 [MessageCubit] Processing comment part: ${comment.messageId}');

        // For now, just log the comment. You can emit a specific state or handle it differently
        // TODO: Add comment-specific handling, e.g., emit a CommentReceived state
        debugPrint('💬 [MessageCubit] Comment received: ${comment.text} by ${comment.authorId}');
        // Attach comment to existing conversation if possible
        try {
          // Find existing conversation by message id or conversationId
          final existingIndex = _conversations.indexWhere(
            (c) =>
                (comment.messageId != null && c.sId != null && c.sId == comment.messageId) ||
                (comment.conversationId != null &&
                    c.conversationId != null &&
                    c.conversationId == comment.conversationId),
          );

          if (existingIndex != -1) {
            final existing = _conversations[existingIndex];
            existing.comments = existing.comments ?? [];
            existing.comments!.add(comment);
            debugPrint('📝 [MessageCubit] Attached comment to existing conversation at index $existingIndex');
            _sortMessages();
            emit(
              MessageReceived(
                message: existing,
                messages: List.from(_conversations),
                conversationId: _currentConversationId ?? existing.conversationId ?? '',
              ),
            );
          } else {
            // Create a new conversation entry for this comment
            final newConv = Conversation(
              comment: comment,
              conversationId: comment.conversationId,
              createdAt: DateTime.now().toIso8601String(),
            );
            _conversations.add(newConv);
            debugPrint('📝 [MessageCubit] Added new conversation for comment');
            emit(
              MessageReceived(
                message: newConv,
                messages: List.from(_conversations),
                conversationId: comment.conversationId ?? '',
              ),
            );
          }
        } catch (e) {
          debugPrint('❌ [MessageCubit] Error attaching comment: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ [MessageCubit] Error handling internal comment from RCMS: $e');
    }
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

    // Group messages by conversationId and get only the latest message for each conversation
    final Map<String, Conversation> conversationMap = {};

    for (var message in _conversations) {
      final convId = message.conversationId ?? '';
      if (convId.isEmpty) continue;

      // If this conversation doesn't exist yet, or this message is newer, update it
      if (!conversationMap.containsKey(convId)) {
        conversationMap[convId] = message;
      } else {
        // Compare timestamps to keep the latest message
        final existingDate = _parseDateTime(conversationMap[convId]!.createdAt);
        final newDate = _parseDateTime(message.createdAt);

        if (newDate != null && (existingDate == null || newDate.isAfter(existingDate))) {
          conversationMap[convId] = message;
        }
      }
    }

    // Convert map to list and sort by date (newest first)
    final uniqueConversations = conversationMap.values.toList();
    uniqueConversations.sort((a, b) {
      final dateA = _parseDateTime(a.createdAt);
      final dateB = _parseDateTime(b.createdAt);
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA); // Newest first
    });

    debugPrint(
      '✅ [MessageCubit] Loaded ${uniqueConversations.length} unique conversations from ${_conversations.length} messages',
    );
    emit(ConversationsLoaded(conversations: uniqueConversations));
  }

  DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
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
  }) async {
    debugPrint('📤 [MessageCubit] Sending message');
    debugPrint('📤 [MessageCubit] Current conversation ID: $_currentConversationId');
    debugPrint('📤 [MessageCubit] Target conversation ID: $conversationId');
    debugPrint('📤 [MessageCubit] Socket connected: ${socketService.isConnected}');

    // Check if socket is connected, if not, try to reconnect
    if (!socketService.isConnected) {
      debugPrint('⚠️ [MessageCubit] Socket disconnected. Attempting to reconnect...');
      socketService.reconnect();

      // Wait a bit for reconnection (max 2 seconds)
      int attempts = 0;
      while (!socketService.isConnected && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (socketService.isConnected) {
        debugPrint('✅ [MessageCubit] Socket reconnected successfully!');
      } else {
        debugPrint('❌ [MessageCubit] Failed to reconnect socket. Message will be sent but may not reach server.');
      }
    }

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
    );

    debugPrint('➡️ [MessageCubit] Emitting sendMessage via socket');
    debugPrint('➡️ [MessageCubit] Message data: ${messageModel.toJson()}');

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
    debugPrint('📝 [MessageCubit] Added message to list. Total messages: ${_conversations.length}');
    debugPrint('📝 [MessageCubit] Emitting MessageSent with ${_conversations.length} messages');
    emit(MessageSent(message: localConversation, messages: List.from(_conversations), conversationId: conversationId));
  }

  void markAsRead(Conversation message) {
    debugPrint('✅ [MessageCubit] Marking message as read');
    if (!socketService.isConnected) {
      debugPrint('⚠️ [MessageCubit] Socket not connected, cannot mark as read');
      return;
    }
    socketService.markAsRead(message.toJson());
  }

  Future<void> sendInternalComment({required Map<String, dynamic> comment}) async {
    debugPrint('💬 [MessageCubit] Sending internal comment');
    debugPrint('💬 [MessageCubit] Socket connected: ${socketService.isConnected}');

    // Check if socket is connected, if not, try to reconnect
    if (!socketService.isConnected) {
      debugPrint('⚠️ [MessageCubit] Socket disconnected for comment. Attempting to reconnect...');
      socketService.reconnect();

      // Wait a bit for reconnection (max 2 seconds)
      int attempts = 0;
      while (!socketService.isConnected && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (socketService.isConnected) {
        debugPrint('✅ [MessageCubit] Socket reconnected successfully!');
      } else {
        debugPrint('❌ [MessageCubit] Failed to reconnect socket. Comment will be sent but may not reach server.');
      }
    }

    // Build local Comment model for optimistic UI update
    try {
      String? readField(String key) {
        try {
          if (comment.containsKey(key) && comment[key] != null) return comment[key] as String?;
        } catch (_) {}
        try {
          final nested = comment['comment'];
          if (nested is Map && nested.containsKey(key) && nested[key] != null) return nested[key] as String?;
        } catch (_) {}
        return null;
      }

      dynamic readMentions() {
        try {
          if (comment.containsKey('mentions') && comment['mentions'] != null) return comment['mentions'];
        } catch (_) {}
        try {
          final nested = comment['comment'];
          if (nested is Map && nested.containsKey('mentions') && nested['mentions'] != null) return nested['mentions'];
        } catch (_) {}
        return null;
      }

      final localComment = Comment(
        text: readField('text'),
        authorId: readField('authorId') ?? readField('userId'),
        userId: readField('userId'),
        messageId: readField('messageId'),
        conversationId: readField('conversationId'),
        parentCommentId: readField('parentCommentId'),
        mentions: readMentions() != null ? List<String>.from(readMentions()) : null,
      );

      // Try to populate sender/receiver from payload for better optimistic UI
      Sender? optimisticSender;
      Sender? optimisticReceiver;
      try {
        final senderData = comment['sender'] ?? (comment['message'] != null ? comment['message']['sender'] : null);
        if (senderData != null && senderData is Map<String, dynamic>) {
          optimisticSender = Sender.fromJson(senderData);
        }

        final receiverData =
            comment['receiver'] ?? (comment['message'] != null ? comment['message']['receiver'] : null);
        if (receiverData != null && receiverData is Map<String, dynamic>) {
          optimisticReceiver = Sender.fromJson(receiverData);
        }
      } catch (_) {
        // ignore parsing issues
      }

      final localConversation = Conversation(
        sender: optimisticSender,
        receiver: optimisticReceiver,
        comment: localComment,
        seen: false,
        conversationId: comment['conversationId'] as String?,
        participants: '',
        loggedUserId: comment['userId'] as String?,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Optimistically add to local list and emit state so UI updates immediately
      _conversations.add(localConversation);
      emit(
        MessageSent(
          message: localConversation,
          messages: List.from(_conversations),
          conversationId: localConversation.conversationId ?? '',
        ),
      );
    } catch (e) {
      debugPrint('❌ [MessageCubit] Error creating local comment: $e');
    }

    // Send to server via socket so other participants (and server) can persist/distribute
    socketService.sendInternalComment(comment);
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
