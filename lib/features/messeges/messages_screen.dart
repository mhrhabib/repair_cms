import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/messeges/cubits/message_cubit.dart';
import 'package:repair_cms/features/messeges/models/conversation_model.dart';
import 'package:repair_cms/features/messeges/chat_conversation_screen.dart';
import 'package:repair_cms/set_up_di.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool isSelectionMode = false;
  Set<String> selectedConversations = {};
  List<Conversation> _conversations = [];
  Conversation? _selectedConversation;

  @override
  void initState() {
    super.initState();
    // Load conversations when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageCubit>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: isTablet
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          isSelectionMode ? 'Messages - remove selected' : 'Messages',
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (!isSelectionMode && _conversations.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                if (value == 'select') {
                  setState(() {
                    isSelectionMode = true;
                  });
                }
              },
              itemBuilder: (context) => [const PopupMenuItem<String>(value: 'select', child: Text('Select Messages'))],
            ),
          if (isSelectionMode) ...[
            TextButton(
              onPressed: selectedConversations.isEmpty ? null : _removeSelectedMessages,
              child: Text(
                'Remove',
                style: TextStyle(
                  color: selectedConversations.isEmpty ? Colors.grey : const Color(0xFF4A90E2),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      body: BlocConsumer<MessageCubit, MessageState>(
        listener: (context, state) {
          if (state is ConversationsLoaded) {
            setState(() {
              _conversations = state.conversations;
            });
          }
          if (state is MessageError) {
            SnackbarDemo(message: state.message).showCustomSnackbar(context);
          }
        },
        builder: (context, state) {
          if (state is MessageLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (isTablet) {
            return Row(
              children: [
                SizedBox(width: 350, child: _conversations.isEmpty ? _buildEmptyState() : _buildMessagesList()),
                Container(width: 1, color: Colors.grey[200]),
                Expanded(
                  child: _selectedConversation == null
                      ? _buildChatPlaceholder()
                      : KeyedSubtree(
                          key: ValueKey(_selectedConversation!.conversationId),
                          child: _buildEmbeddedChat(_selectedConversation!),
                        ),
                ),
              ],
            );
          }

          return _conversations.isEmpty ? _buildEmptyState() : _buildMessagesList();
        },
      ),
    );
  }

  Widget _buildChatPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'Select a conversation to start chatting',
            style: AppTypography.fontSize16.copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedChat(Conversation conversation) {
    final storage = GetStorage();
    final userEmail = storage.read('email');

    // Determine the other participant
    String? recipientEmail;
    String? recipientName;

    if (conversation.sender?.email != null && conversation.sender?.email != userEmail) {
      recipientEmail = conversation.sender!.email;
      recipientName = conversation.sender!.name;
    } else if (conversation.receiver?.email != null && conversation.receiver?.email != userEmail) {
      recipientEmail = conversation.receiver!.email;
      recipientName = conversation.receiver!.name;
    }

    return ChatConversationScreen(
      conversationId: conversation.conversationId ?? '',
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      isEmbedded: true,
    );
  }

  /// Send a test notification to verify the notification system works

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF4A90E2).withValues(alpha: 0.3), const Color(0xFF4A90E2)],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 32),
          const Text(
            'No Messages yet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get new Messages,\nthey\'ll show up here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Column(
      children: [
        if (isSelectionMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Select messages to remove',
                  style: TextStyle(color: Colors.blue[700], fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSelectionMode = false;
                      selectedConversations.clear();
                    });
                  },
                  child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _conversations.length,
            itemBuilder: (context, index) {
              return _buildMessageItem(_conversations[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(Conversation conversation) {
    final isSelected = selectedConversations.contains(conversation.conversationId);

    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          setState(() {
            final convId = conversation.conversationId ?? '';
            if (isSelected) {
              selectedConversations.remove(convId);
            } else {
              selectedConversations.add(convId);
            }
          });
        } else {
          _openChatDetail(conversation);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFF4A90E2), width: 2) : null,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            if (isSelectionMode)
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[400],
                  size: 24,
                ),
              ),
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF4A90E2),
                  child: Text(
                    (conversation.sender?.name ?? conversation.receiver?.name ?? 'U').substring(0, 2).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                if (conversation.seen == false)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation.sender?.name ?? conversation.receiver?.name ?? 'Unknown User',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      Text(
                        _formatTime(_parseDateTime(conversation.createdAt)),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.message?.message ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChatDetail(Conversation conversation) {
    if (MediaQuery.of(context).size.width >= 600) {
      setState(() {
        _selectedConversation = conversation;
      });
      return;
    }

    final storage = GetStorage();
    final userEmail = storage.read('email');

    // Determine the other participant
    String? recipientEmail;
    String? recipientName;

    if (conversation.sender?.email != null && conversation.sender?.email != userEmail) {
      recipientEmail = conversation.sender!.email;
      recipientName = conversation.sender!.name;
    } else if (conversation.receiver?.email != null && conversation.receiver?.email != userEmail) {
      recipientEmail = conversation.receiver!.email;
      recipientName = conversation.receiver!.name;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: SetUpDI.getIt<MessageCubit>(),
          child: ChatConversationScreen(
            conversationId: conversation.conversationId ?? '',
            recipientEmail: recipientEmail,
            recipientName: recipientName,
          ),
        ),
      ),
    );
  }

  void _removeSelectedMessages() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Remove Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to remove ${selectedConversations.length} selected message${selectedConversations.length > 1 ? 's' : ''}?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _conversations.removeWhere((conv) => selectedConversations.contains(conv.conversationId));
                selectedConversations.clear();
                isSelectionMode = false;
              });
              SnackbarDemo(message: 'Selected messages removed').showCustomSnackbar(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Remove', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
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
