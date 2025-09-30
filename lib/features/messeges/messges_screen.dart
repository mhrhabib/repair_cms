import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool isSelectionMode = false;
  Set<String> selectedMessages = {};

  // Sample messages data - set to empty list to show empty state
  List<MessageItem> messages = [
    MessageItem(
      id: '1',
      senderName: 'Joe Doe',
      message: 'Hi Tom, What is about my device?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      avatar: 'JD',
    ),
    MessageItem(
      id: '2',
      senderName: 'Mark Wilson',
      message: 'Hello Tom, How are you?',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      avatar: 'MW',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isSelectionMode ? 'Messages - remove selected' : 'Messages',
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (!isSelectionMode && messages.isNotEmpty)
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
              onPressed: selectedMessages.isEmpty ? null : _removeSelectedMessages,
              child: Text(
                'Remove',
                style: TextStyle(
                  color: selectedMessages.isEmpty ? Colors.grey : const Color(0xFF4A90E2),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      body: messages.isEmpty ? _buildEmptyState() : _buildMessagesList(),
    );
  }

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
                colors: [const Color(0xFF4A90E2).withOpacity(0.3), const Color(0xFF4A90E2)],
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
                      selectedMessages.clear();
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
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _buildMessageItem(messages[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(MessageItem message) {
    final isSelected = selectedMessages.contains(message.id);

    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          setState(() {
            if (isSelected) {
              selectedMessages.remove(message.id);
            } else {
              selectedMessages.add(message.id);
            }
          });
        } else {
          _openChatDetail(message);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFF4A90E2), width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
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
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF4A90E2),
              child: Text(
                message.avatar,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
              ),
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
                        message.senderName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      Text(_formatTime(message.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.message,
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

  void _openChatDetail(MessageItem message) {
    // Navigate to chat detail screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chat with ${message.senderName}'),
        content: Text('Opening chat detail for: ${message.message}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
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
          'Are you sure you want to remove ${selectedMessages.length} selected message${selectedMessages.length > 1 ? 's' : ''}?',
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
                messages.removeWhere((message) => selectedMessages.contains(message.id));
                selectedMessages.clear();
                isSelectionMode = false;
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Selected messages removed'), backgroundColor: Colors.red));
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

  String _formatTime(DateTime timestamp) {
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
}

class MessageItem {
  final String id;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final String avatar;

  MessageItem({
    required this.id,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.avatar,
  });
}
