import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/base/base_client.dart';
import 'package:repair_cms/core/helpers/api_endpoints.dart';
import 'package:repair_cms/core/services/file_service.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/messeges/cubits/message_cubit.dart';
import 'package:repair_cms/features/messeges/models/conversation_model.dart';
import 'package:repair_cms/features/messeges/models/message_model.dart';
import 'package:repair_cms/features/messeges/models/sub_user_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:repair_cms/features/myJobs/widgets/files_screen.dart'
    show FullscreenImageViewer;

class ChatConversationScreen extends StatefulWidget {
  final String conversationId;
  final String? recipientEmail;
  final String? recipientName;

  const ChatConversationScreen({
    super.key,
    required this.conversationId,
    this.recipientEmail,
    this.recipientName,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  final storage = GetStorage();
  String? _loggedUserEmail;
  String? _ownerEmail;
  String? _fallbackRecipientEmail;
  String? _fallbackRecipientName;
  bool _isInternalMode = false;
  bool _isUploading = false;
  final List<String> _mentionIds = [];
  String _searchQuery = '';
  bool _showMentionSuggestions = false;
  int _mentionStartIndex = -1;
  List<SubUser> _subUsers = [];
  List<Conversation> _messages = [];
  final Map<String, Future<String>> _imageUrlCache = {};
  @override
  void initState() {
    super.initState();
    _loggedUserEmail = storage.read('email');

    // Extract owner/company email from companyData
    try {
      final companyDataStr = storage.read('companyData');
      if (companyDataStr != null) {
        final companyData = jsonDecode(companyDataStr);
        _ownerEmail = companyData['companyEmail'];
        debugPrint(
          '🏢 [ChatConversationScreen] Owner/Company Email: $_ownerEmail',
        );
      }
    } catch (e) {
      debugPrint('⚠️ [ChatConversationScreen] Could not parse companyData: $e');
    }

    _fallbackRecipientEmail = widget.recipientEmail;
    _fallbackRecipientName = widget.recipientName;
    debugPrint(
      '🚀 [ChatConversationScreen] Loading messages for conversation: ${widget.conversationId}',
    );
    if (_fallbackRecipientEmail != null) {
      debugPrint(
        'ℹ️ [ChatConversationScreen] Using fallback recipient: $_fallbackRecipientEmail',
      );
    }

    // Load messages for this conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageCubit>().loadConversation(
        conversationId: widget.conversationId,
      );

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
      final searchText = text
          .substring(atIndex + 1, cursorPosition)
          .toLowerCase();
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
    if (!mounted) {
      debugPrint(
        '⚠️ [ChatConversationScreen] Widget not mounted, skipping mention',
      );
      return;
    }

    try {
      final text = _messageController.text;
      final beforeMention = text.substring(0, _mentionStartIndex);
      final afterMention = text.substring(
        _messageController.selection.baseOffset,
      );
      final displayName = user.fullName ?? user.email ?? 'Unknown';
      final newText = '$beforeMention@$displayName $afterMention';

      _messageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: beforeMention.length + displayName.length + 2,
        ),
      );

      // Add to mentions list
      final mentionId = user.sId ?? user.email!;
      if (mentionId.isNotEmpty && !_mentionIds.contains(mentionId)) {
        _mentionIds.add(mentionId);
        debugPrint('👤 [ChatConversationScreen] Added mention: $displayName');
      }

      if (mounted) {
        setState(() {
          _showMentionSuggestions = false;
          _searchQuery = '';
          _mentionStartIndex = -1;
        });
      }
    } catch (e) {
      debugPrint('❌ [ChatConversationScreen] Error inserting mention: $e');
    }
  }

  void _scrollToBottom() {
    if (!mounted) {
      debugPrint(
        '⚠️ [ChatConversationScreen] Widget not mounted, skipping scroll',
      );
      return;
    }

    try {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      debugPrint('❌ [ChatConversationScreen] Error scrolling: $e');
    }
  }

  void _sendMessage(List<Conversation> currentMessages) {
    if (!mounted) {
      debugPrint(
        '⚠️ [ChatConversationScreen] Widget not mounted, skipping send',
      );
      return;
    }

    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      debugPrint('📤 [ChatConversationScreen] Sending message: $messageText');
      debugPrint('🔒 [ChatConversationScreen] Internal mode: $_isInternalMode');
      debugPrint('👥 [ChatConversationScreen] Mentions: $_mentionIds');

      final userEmail = storage.read('email') ?? '';
      final userName = storage.read('fullName') ?? '';
      final userId = storage.read('userId') ?? '';
      final loggedInUserId = storage.read('loginUserId') ?? '';

      if (_isInternalMode) {
        // Send internal comment (not visible to regular receiver)
        _sendInternalComment(
          messageText,
          userEmail,
          userName,
          userId,
          loggedInUserId,
        );
      } else {
        // Send regular message
        _sendRegularMessage(
          messageText,
          userEmail,
          userName,
          userId,
          loggedInUserId,
          currentMessages,
        );
      }

      _messageController.clear();
      _mentionIds.clear();

      // Reset internal mode after sending
      if (mounted) {
        setState(() {
          _isInternalMode = false;
        });
      }

      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e, stackTrace) {
      debugPrint('❌ [ChatConversationScreen] Error sending message: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      if (mounted) {
        SnackbarDemo(
          message: 'Failed to send message',
        ).showCustomSnackbar(context);
      }
    }
  }

  void _sendInternalComment(
    String messageText,
    String userEmail,
    String userName,
    String userId,
    String loggedInUserId,
  ) {
    debugPrint('💬 Sending internal comment with mentions: $_mentionIds');

    // Build HTML text for the comment: replace plain @mentions with styled spans and exclude raw @names
    String buildCommentHtmlText(String text) {
      // Build mention spans from _mentionIds using _subUsers lookup
      final List<String> spans = [];
      for (final id in _mentionIds) {
        final sub = _subUsers.firstWhere(
          (s) =>
              (s.sId != null && s.sId == id) ||
              (s.email != null && s.email == id),
          orElse: () => SubUser(),
        );
        final displayName = sub.fullName ?? sub.email ?? id;
        spans.add(
          '<span style="color:#ffe500;" class="internal-user input__mod1">@$displayName</span>',
        );
        // Remove the plain @DisplayName occurrence from the text (first occurrence)
        final plain = '@$displayName';
        if (text.contains(plain)) {
          text = text.replaceFirst(plain, '');
        }
      }

      // Trim leftover whitespace
      final remaining = text.trim();

      // Join spans and remaining text with non-breaking space as in examples
      final joinedSpans = spans.isNotEmpty
          ? '${spans.join('&nbsp;')}&nbsp;'
          : '';
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

    // Find the other participant in the conversation (not the logged-in user)
    SenderReceiver? otherParticipant;
    for (var message in _messages) {
      if (message.sender?.email != null && message.sender?.email != userEmail) {
        otherParticipant = SenderReceiver(
          email: message.sender!.email,
          name: message.sender!.name,
        );
        break;
      }
      if (message.receiver?.email != null &&
          message.receiver?.email != userEmail) {
        otherParticipant = SenderReceiver(
          email: message.receiver!.email,
          name: message.receiver!.name,
        );
        break;
      }
    }

    // Fallback if no messages exist yet
    if (otherParticipant == null) {
      if (_fallbackRecipientEmail != null) {
        otherParticipant = SenderReceiver(
          email: _fallbackRecipientEmail!,
          name: _fallbackRecipientName ?? 'User',
        );
      } else {
        SnackbarDemo(
          message: 'Cannot determine conversation participant',
        ).showCustomSnackbar(context);
        return;
      }
    }

    // Build combined payload (message + comment) to send via socket
    final participantsString =
        '$userEmail-${widget.conversationId}-${otherParticipant.email}';

    final payload = {
      'message': {
        'sender': {'email': userEmail, 'name': userName},
        // 'receiver': {
        //   'email': otherParticipant.email,
        //   'name': otherParticipant.name,
        // },
        'seen': true,
        'message': {
          'message': '',
          'messageType': 'comment',
          'jobId': widget.conversationId,
        },
        'conversationId': widget.conversationId,
        'userId': userId,
        'participants': participantsString,
        'loggedUserId': loggedInUserId,
      },
      'comment': {
        'text': htmlText,
        'authorId': userId,
        'userId': userId,
        'messageId': targetMessageId,
        // 'parentCommentId': parentCommentId,
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
    String loggedInUserId,
    List<Conversation> currentMessages,
  ) {
    // Find the other participant in the conversation (not the logged-in user)
    SenderReceiver? otherParticipant;
    for (var message in currentMessages) {
      // Check sender: if they sent a message and it's not me, they're the other participant
      if (message.sender?.email != null && message.sender?.email != userEmail) {
        otherParticipant = SenderReceiver(
          email: message.sender!.email,
          name: message.sender!.name,
        );
        break;
      }
      // Check receiver: if they received a message and it's not me, they're the other participant
      if (message.receiver?.email != null &&
          message.receiver?.email != userEmail) {
        otherParticipant = SenderReceiver(
          email: message.receiver!.email,
          name: message.receiver!.name,
        );
        break;
      }
    }

    // Fallback if no messages exist yet (empty conversation)
    if (otherParticipant == null) {
      if (_fallbackRecipientEmail != null) {
        debugPrint(
          'ℹ️ [ChatConversationScreen] Using fallback recipient for sending: $_fallbackRecipientEmail',
        );
        otherParticipant = SenderReceiver(
          email: _fallbackRecipientEmail!,
          name: _fallbackRecipientName ?? 'User',
        );
      } else {
        SnackbarDemo(
          message: 'Cannot determine conversation participant',
        ).showCustomSnackbar(context);
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
      loggedUserId: loggedInUserId,
    );
  }

  bool _isMessageFromMe(Conversation message) {
    final senderEmail = message.sender?.email;
    if (senderEmail == null) return false;

    // Check if it's the current logged-in user
    if (senderEmail == _loggedUserEmail) return true;

    // Check if it's the company owner
    if (_ownerEmail != null && senderEmail == _ownerEmail) return true;

    // Check if it's any of the sub-users in the company
    return _subUsers.any((u) => u.email == senderEmail);
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
            if (message.seen == false &&
                message.receiver?.email == _loggedUserEmail) {
              context.read<MessageCubit>().markAsRead(message);
            }
          }
        }

        if (state is MessageReceived) {
          // New message received via socket
          if (state.message.conversationId == widget.conversationId) {
            debugPrint(
              '✅ [ChatConversationScreen] New message received via socket',
            );
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
          debugPrint(
            '✅ [ChatConversationScreen] Loaded ${state.subUsers.length} sub users for mentions',
          );
        }

        if (state is SubUsersError) {
          debugPrint(
            '❌ [ChatConversationScreen] Failed to load sub users: ${state.message}',
          );
        }
      },
      builder: (context, state) {
        // Use locally stored messages to avoid losing them on unrelated state emissions
        final messages = _messages;

        // Debug: log messages count to help diagnose empty UI
        debugPrint(
          '📊 [ChatConversationScreen] Resolved messages count: ${messages.length}',
        );
        if (messages.isNotEmpty) {
          debugPrint(
            '   First message id: ${messages.first.sId}, conversationId: ${messages.first.conversationId}',
          );
        }

        // Determine participant name for the app bar
        String participantName = _fallbackRecipientName ?? 'Conversation';
        for (var message in messages) {
          final isMessageFromMe = _isMessageFromMe(message);

          if (message.sender?.email != null && !isMessageFromMe) {
            participantName = message.sender!.name ?? participantName;
            break;
          }
          if (message.receiver?.email != null &&
              message.receiver?.email != _loggedUserEmail) {
            participantName = message.receiver!.name ?? participantName;
            break;
          }
        }

        return Scaffold(
          backgroundColor: AppColors.kBg,
          body: Stack(
            children: [
              state is MessageLoading
                  ? Center(
                      child: CupertinoActivityIndicator(
                        color: Colors.blue,
                        radius: 16.r,
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top + 60.h,
                        ),
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
                                    final reversedIndex =
                                        messages.length - 1 - index;
                                    final message = messages[reversedIndex];
                                    final isMe = _isMessageFromMe(message);

                                    return _buildMessageBubble(message, isMe);
                                  },
                                ),
                        ),
                        // Mention suggestions overlay
                        if (_showMentionSuggestions && _isInternalMode)
                          _buildMentionSuggestions(),
                        _buildMessageInput(messages),
                      ],
                    ),

              // Custom Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 16.w,
                    right: 16.w,
                    bottom: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.kBg.withValues(alpha: 0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomNavButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: CupertinoIcons.back,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 2.w,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F8),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(28.r),
                          border: Border.all(
                            color:
                                AppColors.whiteColor, // Figma: border #FFFFFF
                            width: 1, // Figma: border-width 1px
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                28,
                                116,
                                115,
                                115,
                              ), // Figma: #0000001C
                              blurRadius: 2, // Figma: blur 20px
                              offset: Offset(
                                0,
                                0,
                              ), // Figma: 0px 0px (no offset)
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          participantName,
                          style: AppTypography.sfProHeadLineTextStyle22
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.fontMainColor,
                                fontSize: 20.sp,
                              ),
                        ),
                      ),
                      SizedBox(width: 42.w), // Balance back button
                    ],
                  ),
                ),
              ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          final displayName = user.fullName ?? user.email ?? 'Unknown';
          final displayEmail = user.email ?? '';
          final avatarText = displayName.isNotEmpty
              ? displayName.substring(0, 1).toUpperCase()
              : '?';

          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF4A90E2),
              backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                  ? NetworkImage(user.avatar!)
                  : null,
              child: user.avatar == null || user.avatar!.isEmpty
                  ? Text(
                      avatarText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            title: Text(
              displayName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              displayEmail,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
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
          SizedBox(
            width: 100,
            height: 100,
            child: Image.asset(
              "assets/icon/Dialog 2.png",
              height: 50,
              width: 50,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Empty Inbox',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no messages\nin your inbox',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Conversation message, bool isMe) {
    final messageText = message.message?.message ?? '';
    final messageType = message.message?.messageType ?? 'standard';
    final attachments = message.message?.attachment;
    final hasAttachment = attachments != null && attachments.isNotEmpty;
    final fileUrl = message.message?.file;
    final hasFile = (fileUrl != null && fileUrl.isNotEmpty) || hasAttachment;
    final hasQuotation =
        messageType == 'quotation' && message.message?.quotation != null;
    final hasComment =
        message.comment != null ||
        (message.comments != null && message.comments!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4A90E2),
              child: Text(
                message.sender?.name?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      message.sender?.name ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.fontSecondaryColor,
                      ),
                    ),
                  ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, right: 4),
                    child: Text(
                      'Jake Jung', // Fallback for me as seen in image
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.fontSecondaryColor,
                      ),
                    ),
                  ),
                if (hasComment) ...[
                  if (message.comments != null && message.comments!.isNotEmpty)
                    for (var c in message.comments!) _buildCommentMessage(c)
                  else if (message.comment != null)
                    _buildCommentMessage(message.comment!),
                ] else if (hasQuotation)
                  _buildQuotationCard(message.message!.quotation!, isMe)
                else if (hasFile)
                  _buildFileMessage(
                    hasAttachment ? attachments.first.file ?? '' : fileUrl!,
                    hasAttachment
                        ? (attachments.first.fileName ?? messageText)
                        : messageText,
                    message,
                    isMe,
                  )
                else
                  _buildStandardMessage(
                    messageText,
                    messageType,
                    message,
                    isMe,
                  ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4A90E2),
              backgroundImage: storage.read('avatar') != null
                  ? NetworkImage(storage.read('avatar'))
                  : null,
              child: storage.read('avatar') == null
                  ? Text(
                      'M', // Fallback
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  /// Resolves the file path to a viewable URL and opens it.
  /// Images open in the FullscreenImageViewer (from files_screen.dart),
  /// other files open in an external browser/app.
  Future<void> _openFile(String filePath) async {
    try {
      final url = await FileService.getImageUrlAsync(filePath);
      if (url.isEmpty) {
        if (mounted) {
          SnackbarDemo(
            message: 'Could not load file',
          ).showCustomSnackbar(context);
        }
        return;
      }

      if (!mounted) return;

      final ext = filePath.split('.').last.toLowerCase();
      final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);

      if (isImage) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullscreenImageViewer(imageUrl: url),
          ),
        );
      } else {
        final uri = Uri.tryParse(url);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('❌ Error opening file: $e');
      if (mounted) {
        SnackbarDemo(
          message: 'Failed to open file',
        ).showCustomSnackbar(context);
      }
    }
  }

  Widget _buildFileMessage(
    String fileUrl,
    String messageText,
    Conversation message,
    bool isMe,
  ) {
    final timestamp = _formatTimeOnly(_parseDateTime(message.createdAt));
    final ext = fileUrl.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
    final displayName = messageText.isNotEmpty
        ? messageText
        : fileUrl.split('/').last;

    return GestureDetector(
      onTap: () => _openFile(fileUrl),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFFDFEEFF) : const Color(0xFFE7E8EC),
            borderRadius: BorderRadius.only(
              topLeft: isMe ? const Radius.circular(16) : Radius.zero,
              topRight: isMe ? Radius.zero : const Radius.circular(16),
              bottomLeft: const Radius.circular(16),
              bottomRight: const Radius.circular(16),
            ),
            border: Border.all(
              color: isMe ? const Color(0xFFBAE6FD) : const Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isImage)
                // Use FutureBuilder to resolve URL for image display
                FutureBuilder<String>(
                  future: _imageUrlCache.putIfAbsent(
                    fileUrl,
                    () => FileService.getImageUrlAsync(fileUrl),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final resolvedUrl = snapshot.data ?? '';
                    if (resolvedUrl.isEmpty) {
                      return Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        resolvedUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, _, _) => Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 150,
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        ext == 'pdf'
                            ? Icons.picture_as_pdf
                            : ext == 'doc' || ext == 'docx'
                            ? Icons.description
                            : Icons.insert_drive_file,
                        color: ext == 'pdf' ? Colors.red : Colors.grey[600],
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to open',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.download_rounded,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spacer(),
                    Text(
                      timestamp,
                      style: TextStyle(
                        color: AppColors.fontSecondaryColor.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 11.sp,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.seen == true ? Icons.done_all : Icons.done,
                        size: 14.sp,
                        color: message.seen == true
                            ? AppColors.primary
                            : AppColors.fontSecondaryColor.withValues(
                                alpha: 0.4,
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardMessage(
    String messageText,
    String messageType,
    Conversation message,
    bool isMe,
  ) {
    final timestamp = _formatTimeOnly(_parseDateTime(message.createdAt));

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDFEEFF) : const Color(0xFFE7E8EC),
          borderRadius: BorderRadius.only(
            topLeft: isMe ? const Radius.circular(16) : Radius.zero,
            topRight: isMe ? Radius.zero : const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isMe ? const Color(0xFFBAE6FD) : const Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (messageType == 'comment')
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Internal Comment',
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? const Color(0xFF4A90E2) : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (messageText.isNotEmpty)
              Text(
                messageText,
                style: TextStyle(
                  color: AppColors.fontMainColor,
                  fontSize: 15.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                Text(
                  'Today',
                  style: TextStyle(
                    color: AppColors.fontSecondaryColor.withValues(alpha: 0.6),
                    fontSize: 11.sp,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timestamp,
                  style: TextStyle(
                    color: AppColors.fontSecondaryColor.withValues(alpha: 0.6),
                    fontSize: 11.sp,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.seen == true ? Icons.done_all : Icons.done,
                    size: 14.sp,
                    color: message.seen == true
                        ? AppColors.primary
                        : AppColors.fontSecondaryColor.withValues(alpha: 0.4),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment header
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.comment, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Internal Comment',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
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
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.4,
                            ),
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
      width: MediaQuery.of(context).size.width * 0.75,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFE0F2FE) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isMe ? const Color(0xFFBAE6FD) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFFBAE6FD)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  SolarIconsOutline.documentText,
                  size: 16.sp,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Quotation',
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Text(
                _formatTimeOnly(_parseDateTime(quotation.createdAt)),
                style: GoogleFonts.roboto(
                  fontSize: 12.sp,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Service header row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'SERVICE',
                  style: GoogleFonts.roboto(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'UNIT',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'PRICE',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.roboto(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

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
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if (quotation.text != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          quotation.text!,
                          style: GoogleFonts.roboto(
                            fontSize: 13.sp,
                            color: const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${quotation.serviceItemList?.length ?? 0}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '€${((quotation.subTotal ?? 0) / 100).toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.roboto(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Divider
          Container(height: 1, color: const Color(0xFFE2E8F0)),
          SizedBox(height: 16.h),

          // Subtotal and VAT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal excl. VAT',
                style: GoogleFonts.roboto(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '€${((quotation.subTotal ?? 0) / 100).toStringAsFixed(2)}',
                style: GoogleFonts.roboto(
                  fontSize: 13.sp,
                  color: const Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VAT',
                style: GoogleFonts.roboto(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '€${((quotation.vat?.toInt() ?? 0) / 100).toStringAsFixed(2)}',
                style: GoogleFonts.roboto(
                  fontSize: 13.sp,
                  color: const Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Total amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                '€${((quotation.total?.toInt() ?? 0) / 100).toStringAsFixed(2)}',
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B82F6), // Accent color for total
                ),
              ),
            ],
          ),

          if (quotation.accepted == true ||
              quotation.paymentStatus != null) ...[
            SizedBox(height: 16.h),
            Container(height: 1, color: const Color(0xFFE2E8F0)),
            SizedBox(height: 16.h),

            // Status Tags
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (quotation.accepted == true)
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6.h,
                      horizontal: 12.w,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          SolarIconsBold.checkCircle,
                          color: const Color(0xFF16A34A),
                          size: 14.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Accepted',
                          style: GoogleFonts.roboto(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (quotation.paymentStatus != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6.h,
                      horizontal: 12.w,
                    ),
                    decoration: BoxDecoration(
                      color: quotation.paymentStatus == 'Paid'
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      border: Border.all(
                        color: quotation.paymentStatus == 'Paid'
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFFCA5A5),
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          quotation.paymentStatus == 'Paid'
                              ? Icons.credit_card
                              : Icons.credit_card_off,
                          color: quotation.paymentStatus == 'Paid'
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFEF4444),
                          size: 14.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Payment: ${quotation.paymentStatus}',
                          style: GoogleFonts.roboto(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: quotation.paymentStatus == 'Paid'
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(List<Conversation> currentMessages) {
    return Container(
      color: Colors.transparent, // Background handled by individual components
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 6,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          // Separate circular add button
          GestureDetector(
            onTap: _isUploading ? null : _showAttachmentOptions,
            child: Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _isUploading
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      Icons.add,
                      color: AppColors.fontMainColor.withValues(alpha: 0.7),
                      size: 24.sp,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Unified pill-shaped input bar
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 48.h, maxHeight: 150.h),
              decoration: BoxDecoration(
                color: _isInternalMode ? const Color(0xFF5B6B7D) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment:
                    _messageController.text.contains('\n') ||
                        _messageController.text.length > 30
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: TextField(
                        controller: _messageController,
                        focusNode: _messageFocusNode,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        style: TextStyle(
                          color: _isInternalMode
                              ? Colors.white
                              : AppColors.fontMainColor,
                          fontSize: 15.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: _isInternalMode
                              ? 'Internal message...'
                              : 'Write a message...',
                          hintStyle: TextStyle(
                            color: _isInternalMode
                                ? Colors.white70
                                : AppColors.fontSecondaryColor.withValues(
                                    alpha: 0.4,
                                  ),
                            fontSize: 15.sp,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isInternalMode
                          ? SolarIconsBold.lock
                          : SolarIconsBold.lockUnlocked,
                      color: _isInternalMode
                          ? Colors.yellow[700]
                          : AppColors.fontSecondaryColor.withValues(alpha: 0.6),
                      size: 22.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _isInternalMode = !_isInternalMode;
                        if (!_isInternalMode) {
                          _mentionIds.clear();
                          _showMentionSuggestions = false;
                        }
                      });
                    },
                  ),
                  // Vertical Divider
                  Container(width: 1, height: 24.h, color: Colors.grey[300]),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: _isInternalMode
                          ? Colors.white
                          : AppColors.fontSecondaryColor,
                      size: 22.sp,
                    ),
                    onPressed: () => _sendMessage(currentMessages),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadAndSendFile(String filePath, String fileName) async {
    if (!mounted) return;

    final userId = storage.read('userId') ?? '';
    final loggedInUserId = storage.read('loginUserId') ?? '';
    if (userId.isEmpty) {
      SnackbarDemo(message: 'User not found').showCustomSnackbar(context);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final file = io.File(filePath);
      Uint8List bytes = await file.readAsBytes();
      final lowerFileName = fileName.toLowerCase();
      final isImage =
          lowerFileName.endsWith('.jpg') ||
          lowerFileName.endsWith('.jpeg') ||
          lowerFileName.endsWith('.png') ||
          lowerFileName.endsWith('.gif');

      // Fix orientation for images
      if (isImage) {
        try {
          debugPrint(
            '📸 [_uploadAndSendFile] Fixing orientation for image: $fileName',
          );
          img.Image? decodedImage = img.decodeImage(bytes);
          if (decodedImage != null) {
            decodedImage = img.bakeOrientation(decodedImage);
            if (lowerFileName.endsWith('.png')) {
              bytes = Uint8List.fromList(img.encodePng(decodedImage));
            } else if (lowerFileName.endsWith('.gif')) {
              bytes = Uint8List.fromList(img.encodeGif(decodedImage));
            } else {
              bytes = Uint8List.fromList(
                img.encodeJpg(decodedImage, quality: 85),
              );
            }
            debugPrint('✅ [_uploadAndSendFile] Orientation fixed');
          }
        } catch (e) {
          debugPrint('⚠️ [_uploadAndSendFile] Orientation fix failed: $e');
        }
      }

      final fileSize = bytes.length;
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      final base64File = base64Encode(bytes);
      final fileId = const Uuid().v4();
      final base64String = 'data:$mimeType;base64,$base64File';

      final uploadUrl =
          '${ApiEndpoints.fileUplaodUrl}$userId/job-message/${widget.conversationId}';

      debugPrint(
        '📤 Uploading file: $fileName ($fileSize bytes) to $uploadUrl',
      );

      final uploadPayload = {
        'file': base64String,
        'fileName': fileName,
        'id': fileId,
        'size': fileSize,
      };

      final response = await BaseClient.post(
        url: uploadUrl,
        payload: uploadPayload,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Upload failed: ${response.statusCode}');
      }

      // The API returns the uploaded file path
      final uploadedFilePath = response.data is String
          ? response.data as String
          : null;

      debugPrint('✅ File uploaded: $uploadedFilePath');

      if (!mounted) return;

      // Send a message via socket with the file in attachment array
      // matching the web app pattern: messageType "attachment"
      final userEmail = storage.read('email') ?? '';
      final userName = storage.read('fullName') ?? '';

      // Find the other participant
      SenderReceiver? otherParticipant;
      for (var message in _messages) {
        if (message.sender?.email != null &&
            message.sender?.email != userEmail) {
          otherParticipant = SenderReceiver(
            email: message.sender!.email,
            name: message.sender!.name,
          );
          break;
        }
        if (message.receiver?.email != null &&
            message.receiver?.email != userEmail) {
          otherParticipant = SenderReceiver(
            email: message.receiver!.email,
            name: message.receiver!.name,
          );
          break;
        }
      }

      otherParticipant ??= _fallbackRecipientEmail != null
          ? SenderReceiver(
              email: _fallbackRecipientEmail!,
              name: _fallbackRecipientName ?? 'User',
            )
          : null;

      if (otherParticipant == null) {
        SnackbarDemo(
          message: 'Cannot determine recipient',
        ).showCustomSnackbar(context);
        return;
      }

      // Build the socket payload with attachment in the message object
      final attachmentData = {
        'file': uploadedFilePath,
        'id': fileId,
        'fileName': fileName,
        'size': fileSize,
      };

      final socketPayload = {
        'sender': {'email': userEmail, 'name': userName},
        'receiver': {
          'email': otherParticipant.email,
          'name': otherParticipant.name,
        },
        'message': {
          'message': '',
          'attachment': [attachmentData],
          'messageType': 'attachment',
          'jobId': widget.conversationId,
        },
        'seen': false,
        'conversationId': widget.conversationId,
        'userId': userId,
        'participants':
            '$userEmail-${widget.conversationId}-${otherParticipant.email}',
        'loginUserId': loggedInUserId,
      };
      debugPrint(
        '📤 [_uploadAndSendFile] Socket payload: ${json.encode(socketPayload)}',
      );

      // Ensure socket is connected before sending (same guard as MessageCubit.sendMessage)
      final socketSvc = context.read<MessageCubit>().socketService;
      if (!socketSvc.isConnected) {
        debugPrint(
          '⚠️ [_uploadAndSendFile] Socket disconnected. Attempting reconnect...',
        );
        socketSvc.reconnect();
        int attempts = 0;
        while (!socketSvc.isConnected && attempts < 20) {
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
        debugPrint(
          socketSvc.isConnected
              ? '✅ [_uploadAndSendFile] Socket reconnected.'
              : '❌ [_uploadAndSendFile] Socket still disconnected after reconnect attempt.',
        );
      } else {
        debugPrint('✅ [_uploadAndSendFile] Socket is connected, sending now.');
      }

      socketSvc.sendMessage(socketPayload);
      debugPrint('✅ [_uploadAndSendFile] sendMessage emitted to socket.');

      // Add to cubit state for proper display (same pattern as text messages)
      final localConversation = Conversation(
        sender: Sender(email: userEmail, name: userName),
        receiver: Sender(
          email: otherParticipant.email,
          name: otherParticipant.name,
        ),
        message: Message(
          message: '',
          messageType: 'attachment',
          jobId: widget.conversationId,
          attachment: [
            MessageAttachment(
              file: uploadedFilePath,
              id: fileId,
              fileName: fileName,
              size: fileSize,
            ),
          ],
        ),
        seen: false,
        conversationId: widget.conversationId,
        createdAt: DateTime.now().toIso8601String(),
      );

      context.read<MessageCubit>().addFileMessage(localConversation);

      SnackbarDemo(
        message: 'File sent successfully',
      ).showCustomSnackbar(context);
    } catch (e) {
      debugPrint('❌ File upload error: $e');
      if (mounted) {
        SnackbarDemo(
          message: 'Failed to upload file: $e',
        ).showCustomSnackbar(context);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        await _uploadAndSendFile(photo.path, photo.name);
      }
    } catch (e) {
      if (mounted) {
        SnackbarDemo(
          message: 'Failed to capture image: $e',
        ).showCustomSnackbar(context);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        await _uploadAndSendFile(image.path, image.name);
      }
    } catch (e) {
      if (mounted) {
        SnackbarDemo(
          message: 'Failed to pick image: $e',
        ).showCustomSnackbar(context);
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'doc',
          'docx',
          'xls',
          'xlsx',
          'jpg',
          'jpeg',
          'png',
          'mp4',
          'pdf',
        ],
      );
      if (result != null && result.files.single.path != null && mounted) {
        await _uploadAndSendFile(
          result.files.single.path!,
          result.files.single.name,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarDemo(
          message: 'Failed to pick document: $e',
        ).showCustomSnackbar(context);
      }
    }
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
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Attach Files',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
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
                    _pickFromGallery();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _pickDocument();
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
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
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
