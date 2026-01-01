import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/messeges/cubits/message_cubit.dart';
import 'package:repair_cms/features/messeges/models/conversation_model.dart';
import 'package:repair_cms/features/messeges/models/message_model.dart';
import 'package:repair_cms/features/messeges/models/sub_user_model.dart';

class ChatConversationScreen extends StatefulWidget {
  final String conversationId;
  final String? recipientEmail;
  final String? recipientName;

  const ChatConversationScreen({super.key, required this.conversationId, this.recipientEmail, this.recipientName});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final storage = GetStorage();
  String? _loggedUserEmail;
  String? _fallbackRecipientEmail;
  String? _fallbackRecipientName;
  bool _isInternalMode = false;
  final List<String> _mentionIds = [];
  String _searchQuery = '';
  bool _showMentionSuggestions = false;
  int _mentionStartIndex = -1;
  List<SubUser> _subUsers = [];
  List<Conversation> _messages = [];
  @override
  void initState() {
    super.initState();
    _loggedUserEmail = storage.read('email');
    _fallbackRecipientEmail = widget.recipientEmail;
    _fallbackRecipientName = widget.recipientName;
    debugPrint('🚀 [ChatConversationScreen] Loading messages for conversation: ${widget.conversationId}');
    if (_fallbackRecipientEmail != null) {
      debugPrint('ℹ️ [ChatConversationScreen] Using fallback recipient: $_fallbackRecipientEmail');
    }

    // Load messages for this conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageCubit>().loadConversation(conversationId: widget.conversationId);

      // Load sub users for mentions
      final userId = storage.read('userId');
      if (userId != null) {
        context.read<MessageCubit>().getSubUsers(userId: userId);
      }
    });

    // Listen to text changes for @ mention detection
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _messageController.text;
    final cursorPosition = _messageController.selection.baseOffset;

    if (cursorPosition < 0) return;

    // Find the last @ before cursor
    int atIndex = -1;
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        atIndex = i;
        break;
      }
      if (text[i] == ' ' || text[i] == '\n') {
        break;
      }
    }

    if (atIndex != -1 && _isInternalMode) {
      // Extract search query after @
      final searchText = text.substring(atIndex + 1, cursorPosition).toLowerCase();
      setState(() {
        _mentionStartIndex = atIndex;
        _searchQuery = searchText;
        _showMentionSuggestions = true;
      });
    } else {
      setState(() {
        _showMentionSuggestions = false;
        _searchQuery = '';
        _mentionStartIndex = -1;
      });
    }
  }

  List<SubUser> _getFilteredSubUsers() {
    if (_searchQuery.isEmpty) return _subUsers;
    return _subUsers.where((user) {
      return (user.fullName ?? '').toLowerCase().contains(_searchQuery) ||
          (user.email ?? '').toLowerCase().contains(_searchQuery) ||
          (user.shortName ?? '').toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _insertMention(SubUser user) {
    final text = _messageController.text;
    final beforeMention = text.substring(0, _mentionStartIndex);
    final afterMention = text.substring(_messageController.selection.baseOffset);
    final displayName = user.fullName ?? user.email ?? 'Unknown';
    final newText = '$beforeMention@$displayName $afterMention';

    _messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: beforeMention.length + displayName.length + 2),
    );

    // Add to mentions list
    final mentionId = user.sId ?? user.email!;
    if (mentionId.isNotEmpty && !_mentionIds.contains(mentionId)) {
      _mentionIds.add(mentionId);
    }

    setState(() {
      _showMentionSuggestions = false;
      _searchQuery = '';
      _mentionStartIndex = -1;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _sendMessage(List<Conversation> currentMessages) {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    debugPrint('📤 [ChatConversationScreen] Sending message: $messageText');
    debugPrint('🔒 [ChatConversationScreen] Internal mode: $_isInternalMode');
    debugPrint('👥 [ChatConversationScreen] Mentions: $_mentionIds');

    final userEmail = storage.read('email') ?? '';
    final userName = storage.read('fullName') ?? '';
    final userId = storage.read('userId') ?? '';

    if (_isInternalMode) {
      // Send internal comment (not visible to regular receiver)
      _sendInternalComment(messageText, userEmail, userName, userId);
    } else {
      // Send regular message
      _sendRegularMessage(messageText, userEmail, userName, userId, currentMessages);
    }

    _messageController.clear();
    _mentionIds.clear();

    // Reset internal mode after sending
    setState(() {
      _isInternalMode = false;
    });

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _sendInternalComment(String messageText, String userEmail, String userName, String userId) {
    debugPrint('💬 Sending internal comment with mentions: $_mentionIds');

    // Build HTML text for the comment: replace plain @mentions with styled spans and exclude raw @names
    String buildCommentHtmlText(String text) {
      // Build mention spans from _mentionIds using _subUsers lookup
      final List<String> spans = [];
      for (final id in _mentionIds) {
        final sub = _subUsers.firstWhere(
          (s) => (s.sId != null && s.sId == id) || (s.email != null && s.email == id),
          orElse: () => SubUser(),
        );
        final displayName = sub.fullName ?? sub.email ?? id;
        spans.add('<span style="color:#ffe500;" class="internal-user input__mod1">@$displayName</span>');
        // Remove the plain @DisplayName occurrence from the text (first occurrence)
        final plain = '@$displayName';
        if (text.contains(plain)) {
          text = text.replaceFirst(plain, '');
        }
      }

      // Trim leftover whitespace
      final remaining = text.trim();

      // Join spans and remaining text with non-breaking space as in examples
      final joinedSpans = spans.isNotEmpty ? '${spans.join('&nbsp;')}&nbsp;' : '';
      return '$joinedSpans$remaining';
    }

    // Determine target message id (message being commented on) and parentCommentId if replying to a comment
    String? getTargetMessageId() {
      try {
        // Find most recent conversation entry that has a message with an id
        for (var i = _messages.length - 1; i >= 0; i--) {
          final m = _messages[i];
          if (m.sId != null && m.message != null) return m.sId;
        }
      } catch (_) {}
      return null;
    }

    final targetMessageId = getTargetMessageId() ?? widget.conversationId;
    // For now we don't support replying to a specific comment in UI; parentCommentId == targetMessageId
    final parentCommentId = targetMessageId;

    final htmlText = buildCommentHtmlText(messageText);

    // Build combined payload (message + comment) to send via socket
    final participants = _fallbackRecipientEmail ?? userEmail;

    final payload = {
      'message': {
        'sender': {'email': userEmail, 'name': userName},
        'seen': true,
        'message': {'message': '', 'messageType': 'comment', 'jobId': widget.conversationId},
        'conversationId': widget.conversationId,
        'userId': userId,
        'participants': participants,
        'loggedUserId': userId,
      },
      'comment': {
        'text': htmlText,
        'authorId': userId,
        'userId': userId,
        'messageId': targetMessageId,
        'parentCommentId': parentCommentId,
        'conversationId': widget.conversationId,
        'mentions': _mentionIds,
      },
    };

    debugPrint(payload.toString());

    // Send via cubit - cubit will optimistically add to local list and emit state
    context.read<MessageCubit>().sendInternalComment(comment: payload);

    //SnackbarDemo(message: 'Internal comment sent to ${_mentionIds.length} team members').showCustomSnackbar(context);
  }

  void _sendRegularMessage(
    String messageText,
    String userEmail,
    String userName,
    String userId,
    List<Conversation> currentMessages,
  ) {
    // Find the other participant in the conversation (not the logged-in user)
    SenderReceiver? otherParticipant;
    for (var message in currentMessages) {
      // Check sender: if they sent a message and it's not me, they're the other participant
      if (message.sender?.email != null && message.sender?.email != userEmail) {
        otherParticipant = SenderReceiver(email: message.sender!.email, name: message.sender!.name);
        break;
      }
      // Check receiver: if they received a message and it's not me, they're the other participant
      if (message.receiver?.email != null && message.receiver?.email != userEmail) {
        otherParticipant = SenderReceiver(email: message.receiver!.email, name: message.receiver!.name);
        break;
      }
    }

    // Fallback if no messages exist yet (empty conversation)
    if (otherParticipant == null) {
      if (_fallbackRecipientEmail != null) {
        debugPrint('ℹ️ [ChatConversationScreen] Using fallback recipient for sending: $_fallbackRecipientEmail');
        otherParticipant = SenderReceiver(email: _fallbackRecipientEmail!, name: _fallbackRecipientName ?? 'User');
      } else {
        SnackbarDemo(message: 'Cannot determine conversation participant').showCustomSnackbar(context);
        return;
      }
    }

    context.read<MessageCubit>().sendMessage(
      conversationId: widget.conversationId,
      sender: SenderReceiver(email: userEmail, name: userName),
      receiver: otherParticipant,
      messageText: messageText,
      messageType: 'standard',
      userId: userId,
      loggedUserId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessageCubit, MessageState>(
      listener: (context, state) {
        if (state is MessagesLoaded) {
          // Update local messages and scroll
          setState(() => _messages = List.from(state.messages));
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

          // Mark unread messages as read
          for (var message in _messages) {
            if (message.seen == false && message.receiver?.email == _loggedUserEmail) {
              context.read<MessageCubit>().markAsRead(message);
            }
          }
        }

        if (state is MessageReceived) {
          // New message received via socket
          if (state.message.conversationId == widget.conversationId) {
            debugPrint('✅ [ChatConversationScreen] New message received via socket');
            // Update local messages
            setState(() => _messages = List.from(state.messages));
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
        }

        if (state is MessageSent) {
          debugPrint('✅ [ChatConversationScreen] Message sent successfully');
          setState(() => _messages = List.from(state.messages));
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        }

        if (state is MessageError) {
          SnackbarDemo(message: state.message).showCustomSnackbar(context);
        }

        if (state is SubUsersLoaded) {
          setState(() {
            _subUsers = state.subUsers;
          });
          debugPrint('✅ [ChatConversationScreen] Loaded ${state.subUsers.length} sub users for mentions');
        }

        if (state is SubUsersError) {
          debugPrint('❌ [ChatConversationScreen] Failed to load sub users: ${state.message}');
        }
      },
      builder: (context, state) {
        // Use locally stored messages to avoid losing them on unrelated state emissions
        final messages = _messages;

        // Debug: log messages count to help diagnose empty UI
        debugPrint('📊 [ChatConversationScreen] Resolved messages count: ${messages.length}');
        if (messages.isNotEmpty) {
          debugPrint('   First message id: ${messages.first.sId}, conversationId: ${messages.first.conversationId}');
        }

        // Determine participant name for the app bar
        String participantName = _fallbackRecipientName ?? 'Conversation';
        for (var message in messages) {
          if (message.sender?.email != null && message.sender?.email != _loggedUserEmail) {
            participantName = message.sender!.name ?? participantName;
            break;
          }
          if (message.receiver?.email != null && message.receiver?.email != _loggedUserEmail) {
            participantName = message.receiver!.name ?? participantName;
            break;
          }
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participantName,
                  style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Online',
                  style: TextStyle(color: Colors.green[600], fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(color: const Color(0xFF4A90E2), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: state is MessageLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: messages.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                // With reverse: true, index 0 is the last item (latest message)
                                // So we need to access messages in reverse order
                                final reversedIndex = messages.length - 1 - index;
                                final message = messages[reversedIndex];
                                final isMe = message.sender?.email == _loggedUserEmail;

                                return _buildMessageBubble(message, isMe);
                              },
                            ),
                    ),
                    // Mention suggestions overlay
                    if (_showMentionSuggestions && _isInternalMode) _buildMentionSuggestions(),
                    _buildMessageInput(messages),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildMentionSuggestions() {
    final filteredUsers = _getFilteredSubUsers();

    if (filteredUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          final displayName = user.fullName ?? user.email ?? 'Unknown';
          final displayEmail = user.email ?? '';
          final avatarText = displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : '?';

          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF4A90E2),
              backgroundImage: user.avatar != null && user.avatar!.isNotEmpty ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null || user.avatar!.isEmpty
                  ? Text(
                      avatarText,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    )
                  : null,
            ),
            title: Text(displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(displayEmail, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            onTap: () => _insertMention(user),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF4A90E2).withValues(alpha: 0.3), const Color(0xFF4A90E2)],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(Icons.chat_bubble_outline, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            'Empty Inbox',
            style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no messages\nin your inbox',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Conversation message, bool isMe) {
    final messageText = message.message?.message ?? '';
    final messageType = message.message?.messageType ?? 'standard';
    final hasAttachments = false; // Conversation model doesn't have attachments field
    final hasQuotation = messageType == 'quotation' && message.message?.quotation != null;
    final hasComment = message.comment != null || (message.comments != null && message.comments!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe) ...[
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF4A90E2),
                    child: Text(
                      message.sender?.name?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          message.sender?.name ?? 'Unknown',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ),
                    if (hasComment) ...[
                      if (message.comments != null && message.comments!.isNotEmpty)
                        for (var c in message.comments!) _buildCommentMessage(c)
                      else if (message.comment != null)
                        _buildCommentMessage(message.comment!),
                    ] else if (hasQuotation)
                      _buildQuotationCard(message.message!.quotation!, isMe)
                    else
                      _buildStandardMessage(messageText, messageType, hasAttachments, message, isMe),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasComment) ...[
                          Icon(Icons.lock, size: 14, color: Colors.yellow[700]),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          messageText.isNotEmpty || hasQuotation || hasComment
                              ? (messageText.isNotEmpty || hasComment ? 'Today' : 'Today')
                              : '',
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeOnly(_parseDateTime(message.createdAt)),
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.seen == true ? Icons.done_all : Icons.done,
                            size: 12,
                            color: message.seen == true ? const Color(0xFF4A90E2) : Colors.grey[400],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardMessage(
    String messageText,
    String messageType,
    bool hasAttachments,
    Conversation message,
    bool isMe,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFD6E8FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (messageType == 'comment')
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.white.withValues(alpha: 0.5) : Colors.orange[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Internal Comment',
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? const Color(0xFF4A90E2) : Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (messageText.isNotEmpty)
                  Text(
                    messageText,
                    style: TextStyle(color: isMe ? const Color(0xFF1E3A5F) : Colors.black87, fontSize: 14, height: 1.4),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentMessage(Comment comment) {
    // Determine if this comment was authored by the logged-in user
    final storedUserId = GetStorage().read('userId') as String?;
    final isMe =
        (comment.authorId != null && comment.authorId == storedUserId) ||
        (comment.userId != null && comment.userId == storedUserId);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFFFF3CD) : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange[200]!, width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment header
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.comment, size: 12, color: Colors.orange[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Internal Comment',
                        style: TextStyle(fontSize: 10, color: Colors.orange[700], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Comment text with inline mentions highlighted
                Builder(
                  builder: (context) {
                    final raw = comment.text ?? '';
                    // Strip simple HTML tags and decode non-breaking spaces for display
                    String cleaned = raw.replaceAll(RegExp(r'<[^>]*>'), '');
                    cleaned = cleaned.replaceAll('&nbsp;', ' ');

                    return RichText(
                      text: TextSpan(
                        children: [
                          // if (comment.mentions != null && comment.mentions!.isNotEmpty)
                          //   TextSpan(
                          //     text: '${comment.mentions!.map((m) => '@${m.split('@').first}').join(' ')} ',
                          //     style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold, fontSize: 14),
                          //   ),
                          TextSpan(
                            text: cleaned,
                            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuotationCard(Quotation quotation, bool isMe) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFD6E8FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quotation',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[800]),
              ),
              const Spacer(),
              Text(
                _formatTimeOnly(_parseDateTime(quotation.createdAt)),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Service header row
          Row(
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  'Service',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Text(
                  'Unit',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Text(
                  'Price',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Service details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quotation.quotationName ?? 'Service',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    if (quotation.text != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(quotation.text!, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${quotation.serviceItemList?.length ?? 0} items',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '€${((quotation.subTotal ?? 0) / 100).toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 12),
          // Subtotal and VAT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal excl. VAT', style: TextStyle(fontSize: 12, color: Colors.black54)),
              Text(
                '€${((quotation.subTotal ?? 0) / 100).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('VAT', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              Text(
                '€${((quotation.vat?.toInt() ?? 0) / 100).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Total amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              Text(
                '€${((quotation.total?.toInt() ?? 0) / 100).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
            ],
          ),
          if (quotation.accepted == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Quotation Accepted',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
          ],
          if (quotation.paymentStatus != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: quotation.paymentStatus == 'Paid' ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    quotation.paymentStatus == 'Paid' ? Icons.credit_card : Icons.credit_card_off,
                    color: quotation.paymentStatus == 'Paid' ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Online Payment Status',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: quotation.paymentStatus == 'Paid' ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      quotation.paymentStatus!,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(List<Conversation> currentMessages) {
    // Compact single-line message input
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.grey[700], size: 22),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _isInternalMode ? const Color(0xFF5B6B7D) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      style: TextStyle(color: _isInternalMode ? Colors.white : Colors.black87, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: _isInternalMode ? 'Internal message... @mention' : 'Write a message...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      maxLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(currentMessages),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isInternalMode ? Icons.lock : Icons.lock_open,
                      color: _isInternalMode ? Colors.yellow[700] : Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isInternalMode = !_isInternalMode;
                        if (!_isInternalMode) {
                          _mentionIds.clear();
                          _showMentionSuggestions = false;
                        }
                      });
                      // SnackbarDemo(
                      //   message: _isInternalMode
                      //       ? 'Internal mode ON - Message will be private'
                      //       : 'Internal mode OFF - Message will be visible to all',
                      // ).showCustomSnackbar(context);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file, color: _isInternalMode ? Colors.white70 : Colors.grey[600], size: 20),
                    onPressed: _showAttachmentOptions,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isInternalMode
                    ? [const Color(0xFF5B6B7D), const Color(0xFF404955)]
                    : [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(currentMessages),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('Attach Files', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    // SnackbarDemo(message: 'Gallery picker coming soon').showCustomSnackbar(context);
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    //  SnackbarDemo(message: 'Camera coming soon').showCustomSnackbar(context);
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    //(message: 'Document picker coming soon').showCustomSnackbar(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  String _formatTimeOnly(DateTime? timestamp) {
    if (timestamp == null) return '';

    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      debugPrint('❌ Error parsing date: $dateString');
      return null;
    }
  }
}
