import 'package:socket_io_client/socket_io_client.dart' as io;

/// Global socket service used across the app.
/// Uses `socket_io_client` and mirrors the React behavior described in the guide.
class SocketService {
  io.Socket? socket;

  /// Connect and optionally join the user room. Call once (for example from main())
  void connect({required String baseUrl, required String userId, Map<String, dynamic>? options}) {
    socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(3000)
          .build(),
    );

    // Basic event handlers
    socket!.on('connect', (_) => print('🚀 Socket connected: \\${socket!.id}'));
    socket!.on('disconnect', (_) => print('🔌 Socket disconnected'));
    socket!.on('connect_error', (err) => print('❌ Socket connect error: $err'));

    socket!.connect();

    // Wait for connection and then join user room
    socket!.once('connect', (_) {
      if (userId.isNotEmpty) {
        joinRoom(userId);
      }
    });
  }

  void disconnect() {
    try {
      socket?.disconnect();
      socket = null;
    } catch (e) {
      print('Error while disconnecting socket: $e');
    }
  }

  /// Join a room for the user (server expects emit 'joinRoom' with userId)
  void joinRoom(String userId) {
    socket?.emit('joinRoom', userId);
    print('➡️ Emitted joinRoom: $userId');
  }

  /// Generic emit helper
  void emit(String event, dynamic payload) {
    socket?.emit(event, payload);
  }

  /// Send chat message or attachment. Message payload must follow server contract.
  void sendMessage(Map<String, dynamic> messageData) {
    emit('sendMessage', messageData);
  }

  /// Send internal comment
  void sendInternalComment(Map<String, dynamic> data) {
    emit('internalCommentFromRCMS', data);
  }

  /// Mark messages as read (emit markAsRead)
  void markAsRead(Map<String, dynamic> message) {
    emit('markAsRead', message);
  }

  /// Register a listener for an event. Returns a function to remove the listener.
  void on(String event, Function(dynamic) handler) {
    socket?.on(event, handler);
  }

  /// Remove listener
  void off(String event) {
    socket?.off(event);
  }
}

final socketService = SocketService();
