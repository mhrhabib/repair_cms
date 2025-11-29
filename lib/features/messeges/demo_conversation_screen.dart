// ignore_for_file: use_build_context_synchronously

import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/messeges/models/message_model.dart';

class DemoConversationScreen extends StatefulWidget {
  const DemoConversationScreen({super.key});

  @override
  State<DemoConversationScreen> createState() => _DemoConversationScreenState();
}

class _DemoConversationScreenState extends State<DemoConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<MessageModel> _messages = [
    MessageModel(
      id: '1',
      sender: SenderReceiver(name: 'Customer', email: 'customer@example.com'),
      receiver: SenderReceiver(name: 'Technician', email: 'tech@example.com'),
      message: MessageContent(message: 'Hi, I need help with my iPhone screen repair.'),
      seen: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    MessageModel(
      id: '2',
      sender: SenderReceiver(name: 'Technician', email: 'tech@example.com'),
      receiver: SenderReceiver(name: 'Customer', email: 'customer@example.com'),
      message: MessageContent(
        message: 'Hello! I can help you with that. What seems to be the issue with your iPhone screen?',
      ),
      seen: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
    ),
    MessageModel(
      id: '3',
      sender: SenderReceiver(name: 'Customer', email: 'customer@example.com'),
      receiver: SenderReceiver(name: 'Technician', email: 'tech@example.com'),
      message: MessageContent(message: 'The screen is cracked and not responding to touch in some areas.'),
      seen: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    MessageModel(
      id: '4',
      sender: SenderReceiver(name: 'Technician', email: 'tech@example.com'),
      receiver: SenderReceiver(name: 'Customer', email: 'customer@example.com'),
      message: MessageContent(
        message:
            'I understand. For iPhone screen repairs, we typically need to replace the entire display assembly. The cost would be around \$150-200 depending on the model. Would you like me to schedule a repair appointment?',
      ),
      seen: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    MessageModel(
      id: '5',
      sender: SenderReceiver(name: 'Customer', email: 'customer@example.com'),
      receiver: SenderReceiver(name: 'Technician', email: 'tech@example.com'),
      message: MessageContent(message: 'Yes, that sounds good. When can you fit me in?'),
      seen: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    MessageModel(
      id: '6',
      sender: SenderReceiver(name: 'Technician', email: 'tech@example.com'),
      receiver: SenderReceiver(name: 'Customer', email: 'customer@example.com'),
      message: MessageContent(
        message: 'I have availability tomorrow at 2 PM or Friday at 10 AM. Which time works better for you?',
      ),
      seen: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: SenderReceiver(name: 'You', email: 'you@example.com'),
      receiver: SenderReceiver(name: 'Technician', email: 'tech@example.com'),
      message: MessageContent(message: message),
      seen: false,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text('C', style: AppTypography.fontSize16Bold.copyWith(color: AppColors.primary)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Support', style: AppTypography.fontSize16Bold),
                  Text('Online', style: AppTypography.fontSize12.copyWith(color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.sender?.name == 'You';

                return _buildMessageBubble(message, isMe);
              },
            ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTypography.fontSize14.copyWith(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 20.sp),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                message.sender?.name?.substring(0, 1) ?? 'U',
                style: AppTypography.fontSize12.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 16.r : 4.r),
                  topRight: Radius.circular(isMe ? 4.r : 16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Text(
                      message.sender?.name ?? 'Unknown',
                      style: AppTypography.fontSize12.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isMe ? Colors.white : AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                  Text(
                    message.message?.message ?? '',
                    style: AppTypography.fontSize14.copyWith(color: isMe ? Colors.white : Colors.black87),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatTime(message.createdAt),
                    style: AppTypography.fontSize10.copyWith(
                      color: isMe ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                'Y',
                style: AppTypography.fontSize12.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}
