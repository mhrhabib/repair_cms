import 'package:repair_cms/core/app_exports.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Global socket service used across the app.
/// Uses `socket_io_client` and mirrors the React behavior described in the guide.
class SocketService {
  io.Socket? socket;

  /// Connect and optionally join the user room. Call once (for example from main())
  void connect({required String baseUrl, required String userId, String? authToken, Map<String, dynamic>? options}) {
    // Build socket options with authentication
    final optionsBuilder = io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(3000);

    // Add auth token if provided
    if (authToken != null && authToken.isNotEmpty) {
      optionsBuilder.setAuth({'token': authToken});
      debugPrint('🔐 Socket auth token configured');
    }

    socket = io.io(baseUrl, optionsBuilder.build());

    // Basic event handlers
    socket!.on('connect', (_) => debugPrint('🚀 Socket connected: \\${socket!.id}'));
    socket!.on('disconnect', (_) => debugPrint('🔌 Socket disconnected'));
    socket!.on('connect_error', (err) => debugPrint('❌ Socket connect error: $err'));

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
      debugPrint('Error while disconnecting socket: $e');
    }
  }

  /// Join a room for the user (server expects emit 'joinRoom' with userId)
  void joinRoom(String userId) {
    socket?.emit('joinRoom', userId);
    debugPrint('➡️ Emitted joinRoom: $userId');
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

  /// Check if socket is currently connected
  bool get isConnected => socket?.connected ?? false;
}

final socketService = SocketService();
