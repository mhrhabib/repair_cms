import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/services/socket_service.dart';
import 'package:repair_cms/set_up_di.dart';

/// Socket Testing Screen
/// Use this screen to verify socket connection and test all socket events
class SocketTestScreen extends StatefulWidget {
  const SocketTestScreen({super.key});

  @override
  State<SocketTestScreen> createState() => _SocketTestScreenState();
}

class _SocketTestScreenState extends State<SocketTestScreen> {
  final SocketService _socketService = SetUpDI.getIt<SocketService>();
  final storage = GetStorage();
  final List<String> _logs = [];
  final TextEditingController _serverUrlController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _receiverEmailController = TextEditingController();

  // Demo server options
  final List<Map<String, String>> _demoServers = [
    {
      'name': 'Socket.io Demo Chat',
      'url': 'https://socketio-chat-h9jt.herokuapp.com',
      'description': 'Official Socket.io demo server',
    },
    {'name': 'Echo Server', 'url': 'https://echo.websocket.org', 'description': 'WebSocket echo test server'},
    {'name': 'Your Production Server', 'url': 'https://api.repaircms.com', 'description': 'Your actual backend'},
  ];

  bool _isConnected = false;
  String? _socketId;

  @override
  void initState() {
    super.initState();
    // Demo server that's publicly available for testing
    _serverUrlController.text = 'https://socketio-chat-h9jt.herokuapp.com';
    _userIdController.text = storage.read('userId') ?? 'test_user_${DateTime.now().millisecondsSinceEpoch}';
    _receiverEmailController.text = 'demo@example.com';

    _setupSocketListeners();
    _checkConnectionStatus();
  }

  void _setupSocketListeners() {
    // Listen to connection events
    _socketService.socket?.on('connect', (_) {
      setState(() {
        _isConnected = true;
        _socketId = _socketService.socket?.id;
      });
      _addLog('✅ Connected to socket server');
      _addLog('🆔 Socket ID: $_socketId');
    });

    _socketService.socket?.on('disconnect', (_) {
      setState(() {
        _isConnected = false;
        _socketId = null;
      });
      _addLog('🔌 Disconnected from socket server');
    });

    _socketService.socket?.on('connect_error', (error) {
      _addLog('❌ Connection Error: $error');
    });

    _socketService.socket?.on('error', (error) {
      _addLog('❌ Socket Error: $error');
    });

    // Listen to message events (custom events for your app)
    _socketService.on('onUpdateMessage', (data) {
      _addLog(
        '📩 Received Message: ${data.toString().substring(0, data.toString().length > 100 ? 100 : data.toString().length)}...',
      );
    });

    _socketService.on('messageSeen', (data) {
      _addLog('👁️ Message Seen: $data');
    });

    _socketService.on('updateInternalComment', (data) {
      _addLog('💬 Internal Comment Update: $data');
    });

    // Listen to common demo server events
    _socketService.on('new message', (data) {
      _addLog('📩 New Message (demo): $data');
    });

    _socketService.on('user joined', (data) {
      _addLog('👋 User Joined: $data');
    });

    _socketService.on('user left', (data) {
      _addLog('👋 User Left: $data');
    });

    _socketService.on('typing', (data) {
      _addLog('⌨️ User Typing: $data');
    });

    _socketService.on('stop typing', (data) {
      _addLog('⌨️ User Stopped Typing: $data');
    });

    // Generic message listener for any event
    _socketService.on('message', (data) {
      _addLog('📩 Generic Message: $data');
    });
  }

  void _checkConnectionStatus() {
    setState(() {
      _isConnected = _socketService.socket?.connected ?? false;
      _socketId = _socketService.socket?.id;
    });
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '[${DateTime.now().toString().substring(11, 19)}] $message');
      if (_logs.length > 50) _logs.removeLast();
    });
  }

  void _sendTestMessage() {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      _addLog('⚠️ Please enter a message');
      return;
    }

    final serverUrl = _serverUrlController.text.trim();

    // Check if using demo server or production server
    if (serverUrl.contains('socketio-chat-h9jt.herokuapp.com')) {
      // Demo server format - simple message
      _socketService.emit('new message', message);
      _addLog('📤 Sent demo message: $message');
    } else if (serverUrl.contains('echo.websocket')) {
      // Echo server - just emit message
      _socketService.emit('message', {'text': message, 'timestamp': DateTime.now().toIso8601String()});
      _addLog('📤 Sent echo message: $message');
    } else {
      // Production server format - full message object
      final receiverEmail = _receiverEmailController.text.trim();
      final userEmail = storage.read('email') ?? 'test@example.com';
      final userName = storage.read('fullName') ?? 'Test User';

      final messageData = {
        'sender': {'email': userEmail, 'name': userName},
        'receiver': {'email': receiverEmail, 'name': 'Receiver'},
        'message': {'message': message, 'messageType': 'standard'},
        'seen': false,
        'conversationId': 'test_conversation_${DateTime.now().millisecondsSinceEpoch}',
        'userId': _userIdController.text.trim(),
        'participants': '$userEmail-general-$receiverEmail',
        'loggedUserId': _userIdController.text.trim(),
      };

      _socketService.sendMessage(messageData);
      _addLog('📤 Sent production message: $message');
    }

    _messageController.clear();
  }

  void _emitCustomEvent() {
    showDialog(
      context: context,
      builder: (context) {
        final eventController = TextEditingController();
        final dataController = TextEditingController();
        return AlertDialog(
          title: const Text('Emit Custom Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventController,
                decoration: const InputDecoration(labelText: 'Event Name', hintText: 'e.g., testEvent'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dataController,
                decoration: const InputDecoration(labelText: 'Data (JSON string)', hintText: 'e.g., {"test": "data"}'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final event = eventController.text.trim();
                final data = dataController.text.trim();
                if (event.isNotEmpty) {
                  _socketService.emit(event, data.isNotEmpty ? data : null);
                  _addLog('➡️ Emitted custom event: $event');
                  Navigator.pop(context);
                }
              },
              child: const Text('Emit'),
            ),
          ],
        );
      },
    );
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  void _connectToServer() {
    final serverUrl = _serverUrlController.text.trim();
    final userId = _userIdController.text.trim();

    if (serverUrl.isEmpty || userId.isEmpty) {
      _addLog('⚠️ Please enter server URL and user ID');
      return;
    }

    _addLog('🔌 Connecting to $serverUrl...');
    _socketService.connect(baseUrl: serverUrl, userId: userId);
  }

  void _disconnectFromServer() {
    _addLog('🔌 Disconnecting...');
    _socketService.disconnect();
  }

  void _joinTestRoom() {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      _addLog('⚠️ Please enter user ID');
      return;
    }

    _addLog('🚪 Joining room for user: $userId');
    _socketService.joinRoom(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Socket Test Screen'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _clearLogs, tooltip: 'Clear Logs'),
          IconButton(
            icon: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
            color: _isConnected ? Colors.green : Colors.red,
            onPressed: _checkConnectionStatus,
            tooltip: 'Check Status',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Status Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isConnected ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isConnected ? Icons.check_circle : Icons.cancel,
                              color: _isConnected ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isConnected ? 'Connected' : 'Disconnected',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _isConnected ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                    ),
                                  ),
                                  if (_socketId != null)
                                    Text(
                                      'Socket ID: $_socketId',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Connection Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _serverUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'Server URL',
                                  hintText: 'https://api.repaircms.com',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.cloud),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              tooltip: 'Select Demo Server',
                              onSelected: (url) {
                                setState(() {
                                  _serverUrlController.text = url;
                                });
                                _addLog('📌 Selected server: $url');
                              },
                              itemBuilder: (context) => _demoServers
                                  .map(
                                    (server) => PopupMenuItem<String>(
                                      value: server['url']!,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(server['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(
                                            server['description']!,
                                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(server['url']!, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isConnected ? null : _connectToServer,
                                icon: const Icon(Icons.power),
                                label: const Text('Connect'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isConnected ? _disconnectFromServer : null,
                                icon: const Icon(Icons.power_off),
                                label: const Text('Disconnect'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isConnected ? _joinTestRoom : null,
                            icon: const Icon(Icons.meeting_room),
                            label: const Text('Join Room'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),

                  // Message Test Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Test Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _receiverEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Receiver Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  labelText: 'Message',
                                  hintText: 'Type a test message...',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _isConnected ? _sendTestMessage : null,
                              icon: const Icon(Icons.send),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isConnected ? _emitCustomEvent : null,
                            icon: const Icon(Icons.code),
                            label: const Text('Emit Custom Event'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // Logs Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text('Event Logs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('${_logs.length} entries', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Fixed height container instead of Expanded
                  Container(
                    height: 300,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    child: _logs.isEmpty
                        ? Center(
                            child: Text(
                              'No logs yet. Perform actions to see logs here.',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[index];
                              Color logColor = Colors.white;
                              if (log.contains('❌')) logColor = Colors.red[300]!;
                              if (log.contains('✅')) logColor = Colors.green[300]!;
                              if (log.contains('⚠️')) logColor = Colors.orange[300]!;
                              if (log.contains('📩') || log.contains('📤')) {
                                logColor = Colors.blue[300]!;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  log,
                                  style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: logColor),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _userIdController.dispose();
    _messageController.dispose();
    _receiverEmailController.dispose();
    super.dispose();
  }
}
