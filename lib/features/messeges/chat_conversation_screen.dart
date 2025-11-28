import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/features/messeges/cubits/message_cubit.dart';
import 'package:repair_cms/features/messeges/models/message_model.dart';

class ChatConversationScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatConversationScreen({super.key, required this.conversation});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final storage = GetStorage();
  List<MessageModel> _messages = [];
  String? _loggedUserId;

  @override
  void initState() {
    super.initState();
    _loggedUserId = storage.read('userId');
    debugPrint('🚀 [ChatConversationScreen] Loading messages for conversation: ${widget.conversation.conversationId}');

    // Load messages for this conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageCubit>().loadMessages(widget.conversation.conversationId ?? '');
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
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    debugPrint('📤 [ChatConversationScreen] Sending message: $messageText');

    final userEmail = storage.read('email') ?? '';
    final userName = storage.read('fullName') ?? '';
    final userId = storage.read('userId') ?? '';

    context.read<MessageCubit>().sendMessage(
      conversationId: widget.conversation.conversationId ?? '',
      sender: SenderReceiver(email: userEmail, name: userName),
      receiver: widget.conversation.otherParticipant ?? SenderReceiver(email: '', name: ''),
      messageText: messageText,
      messageType: 'standard',
      userId: userId,
      loggedUserId: userId,
    );

    _messageController.clear();

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
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
              widget.conversation.otherParticipant?.name ?? 'Unknown User',
              style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Online',
              style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w400),
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
              onPressed: () {
                // TODO: Show info/details
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<MessageCubit, MessageState>(
        listener: (context, state) {
          if (state is MessagesLoaded) {
            setState(() {
              _messages = state.messages;
            });
            // Scroll to bottom when messages loaded
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

            // Mark unread messages as read
            for (var message in state.messages) {
              if (message.seen == false && message.receiver?.email == _loggedUserId) {
                context.read<MessageCubit>().markAsRead(message);
              }
            }
          }

          if (state is MessageReceived) {
            // New message received via socket
            if (state.message.conversationId == (widget.conversation.conversationId ?? '')) {
              debugPrint('✅ [ChatConversationScreen] New message received via socket');
              // The cubit already handles updating the messages list
              Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
            }
          }

          if (state is MessageSent) {
            debugPrint('✅ [ChatConversationScreen] Message sent successfully');
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }

          if (state is MessageError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is MessageLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.sender?.email == _loggedUserId;

                          return _buildMessageBubble(message, isMe);
                        },
                      ),
              ),
              _buildMessageInput(),
            ],
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

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final messageText = message.message?.message ?? '';
    final messageType = message.message?.messageType ?? 'standard';
    final hasAttachments = message.attachments?.isNotEmpty ?? false;
    final hasQuotation = messageType == 'quotation' && message.message?.quotation != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
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
                  if (hasQuotation)
                    _buildQuotationCard(message.message!.quotation!, isMe)
                  else
                    _buildStandardMessage(messageText, messageType, hasAttachments, message, isMe),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        messageText.isNotEmpty || hasQuotation ? (messageText.isNotEmpty ? 'Today' : 'Today') : '',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                      const SizedBox(width: 4),
                      Text(_formatTimeOnly(message.createdAt), style: TextStyle(color: Colors.grey[500], fontSize: 11)),
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
        ],
      ),
    );
  }

  Widget _buildStandardMessage(
    String messageText,
    String messageType,
    bool hasAttachments,
    MessageModel message,
    bool isMe,
  ) {
    return ConstrainedBox(
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
            if (hasAttachments) ...message.attachments!.map((attachment) => _buildAttachment(attachment, isMe)),
            if (messageText.isNotEmpty)
              Text(
                messageText,
                style: TextStyle(color: isMe ? const Color(0xFF1E3A5F) : Colors.black87, fontSize: 14, height: 1.4),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotationCard(QuotationModel quotation, bool isMe) {
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
              Text(_formatTimeOnly(quotation.timestamp), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
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
                      quotation.service ?? 'Service',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    if (quotation.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(quotation.description!, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${quotation.unit ?? 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${quotation.price?.toStringAsFixed(2) ?? '0.00'} EUR',
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
                '${quotation.subtotal?.toStringAsFixed(2) ?? '0.00'} EUR',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${quotation.vatPercent?.toStringAsFixed(0) ?? '20'}% VAT',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                '${quotation.vatAmount?.toStringAsFixed(2) ?? '0.00'} EUR',
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
                '${quotation.totalAmount?.toStringAsFixed(2) ?? '0.00'} EUR',
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
                  if (quotation.acceptedAt != null) ...[
                    const SizedBox(width: 4),
                    Text(quotation.acceptedAt!, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
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

  Widget _buildAttachment(AttachmentModel attachment, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withValues(alpha: 0.2) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getFileIcon(attachment.type), size: 24, color: isMe ? Colors.white : const Color(0xFF4A90E2)),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name ?? 'Attachment',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (attachment.size != null)
                  Text(
                    _formatFileSize(attachment.size!),
                    style: TextStyle(
                      color: isMe ? Colors.white.withValues(alpha: 0.7) : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String? type) {
    if (type == null) return Icons.attach_file;

    if (type.contains('image')) return Icons.image;
    if (type.contains('pdf')) return Icons.picture_as_pdf;
    if (type.contains('video')) return Icons.video_file;
    if (type.contains('audio')) return Icons.audio_file;
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12 + MediaQuery.of(context).padding.bottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.grey[700], size: 24),
              padding: EdgeInsets.zero,
              onPressed: () {
                _showAttachmentOptions();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Write a message...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.attach_file, color: Colors.grey[600], size: 20),
                        onPressed: () {
                          _showAttachmentOptions();
                        },
                      ),
                    ],
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              onPressed: _sendMessage,
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
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Gallery picker coming soon')));
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera coming soon')));
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Document picker coming soon')));
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
}
