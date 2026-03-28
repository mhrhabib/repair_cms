import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/core/helpers/notification_navigation_helper.dart';
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
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();

    // Set up notification navigation callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationNavigationHelper.setupNavigationCallback(context);
    });

    // Load conversations when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageCubit>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: Stack(
        children: [
          BlocConsumer<MessageCubit, MessageState>(
            listener: (context, state) {
              if (state is ConversationsLoaded) {
                setState(() {
                  _conversations = state.conversations;
                });
              }
              if (state is MessageError) {
                SnackbarDemo(message: state.message)
                    .showCustomSnackbar(context);
              }
            },
            builder: (context, state) {
              if (state is MessageLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 60.h,
                ),
                child: _conversations.isEmpty
                    ? _buildEmptyState()
                    : _buildMessagesList(),
              );
            },
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Messages',
                    style: AppTypography.sfProHeadLineTextStyle22,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Send a test notification to verify the notification system works

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 128.5.h,
            width: 128.5.w,
            child: Image.asset('assets/icon/Dialog 2.png'),
          ),
          const SizedBox(height: 32),
          Text(
            'No Messages yet',
            style: AppTypography.sfProHeadLineTextStyle28.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.fontMainColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get new Messages,\nthey\'ll show up here',
            textAlign: TextAlign.center,
            style: AppTypography.sfProHeadLineTextStyle22.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 20.sp,
              color: AppColors.lightFontColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return Dismissible(
          key: Key(conversation.conversationId ?? index.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF007F), // Figma vibrant pink
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const Text(
              'remove',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onDismissed: (direction) {
            final deletedId = conversation.conversationId;
            setState(() {
              _conversations.removeAt(index);
            });
            if (deletedId != null && deletedId.isNotEmpty) {
              context.read<MessageCubit>().deleteConversationLocally(deletedId);
            }
            SnackbarDemo(
              message: 'Conversation removed',
            ).showCustomSnackbar(context);
            debugPrint(
              '🗑️ [MessagesScreen] Message $deletedId removed via swipe',
            );
          },
          child: _buildMessageItem(conversation),
        );
      },
    );
  }

  Widget _buildMessageItem(Conversation conversation) {
    return GestureDetector(
      onTap: () => _openChatDetail(conversation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF4A90E2),
                  child: Text(
                    (conversation.sender?.name ??
                            conversation.receiver?.name ??
                            'U')
                        .substring(0, 1) // Using 1 char for better fit usually
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (conversation.seen == false)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
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
                        conversation.sender?.name ??
                            conversation.receiver?.name ??
                            'Unknown User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _openChatDetail(Conversation conversation) {
    if (!mounted) {
      debugPrint('⚠️ [MessagesScreen] Widget not mounted, skipping navigation');
      return;
    }

    try {
      final storage = GetStorage();
      final userEmail = storage.read('email');

      // Determine the other participant
      String? recipientEmail;
      String? recipientName;

      if (conversation.sender?.email != null &&
          conversation.sender?.email != userEmail) {
        recipientEmail = conversation.sender!.email;
        recipientName = conversation.sender!.name;
      } else if (conversation.receiver?.email != null &&
          conversation.receiver?.email != userEmail) {
        recipientEmail = conversation.receiver!.email;
        recipientName = conversation.receiver!.name;
      }

      debugPrint(
        '🔄 [MessagesScreen] Opening chat: ${conversation.conversationId}',
      );

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
    } catch (e, stackTrace) {
      debugPrint('❌ [MessagesScreen] Error opening chat: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      if (mounted) {
        SnackbarDemo(
          message: 'Failed to open conversation',
        ).showCustomSnackbar(context);
      }
    }
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
