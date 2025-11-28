# Socket.io Testing Guide

## Quick Test Methods

### Method 1: Using Socket Test Screen (Recommended)

I've created a dedicated Socket Test Screen at:
`lib/features/messeges/screens/socket_test_screen.dart`

**To use it:**

1. Add route to your router or navigate directly:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SocketTestScreen()),
);
```

2. **Features:**
   - ✅ Real-time connection status indicator
   - 📊 Live statistics (sent/received/logs count)
   - 🔌 Connect/Disconnect buttons
   - 📤 Send test messages
   - 💬 Join room testing
   - 📋 Live event logs with color coding
   - ⚙️ Custom event emitter

3. **Test Steps:**
   - Enter your server URL (default: https://api.repaircms.com)
   - Enter your user ID (auto-filled from storage)
   - Click "Connect"
   - Watch the logs for connection status
   - Click "Join Room" to join user room
   - Send test messages
   - Monitor incoming events in real-time

---

### Method 2: Command Line Testing

Check socket service status in your terminal logs:

```dart
// The SocketService already has debug prints
// Look for these in your debug console:
🚀 Socket connected: [socket_id]
🔌 Socket disconnected
❌ Socket connect error: [error]
➡️ Emitted joinRoom: [userId]
📩 Received Message: [data]
```

---

### Method 3: Manual Testing in Your App

Add this temporary code to test in your existing screens:

```dart
import 'package:repair_cms/set_up_di.dart';
import 'package:repair_cms/core/services/socket_service.dart';

// In your screen's initState or button press:
void _testSocket() {
  final socketService = SetUpDI.getIt<SocketService>();
  
  // 1. Check if connected
  final isConnected = socketService.socket?.connected ?? false;
  debugPrint('Socket connected: $isConnected');
  debugPrint('Socket ID: ${socketService.socket?.id}');
  
  // 2. Test emit
  socketService.emit('testEvent', {'test': 'data'});
  debugPrint('Test event emitted');
  
  // 3. Test listener
  socketService.on('testResponse', (data) {
    debugPrint('Test response received: $data');
  });
}
```

---

### Method 4: Browser Developer Tools (Backend Testing)

If your backend is running, test directly from browser console:

```javascript
// Open browser console (F12)
const socket = io('https://api.repaircms.com', {
  transports: ['websocket']
});

socket.on('connect', () => {
  console.log('Connected:', socket.id);
  socket.emit('joinRoom', 'test_user_123');
});

socket.on('onUpdateMessage', (data) => {
  console.log('Message received:', data);
});
```

---

## Testing Checklist

### ✅ Connection Tests

- [ ] **Connect to server**
  - Server URL is correct
  - Socket connects successfully
  - Console shows: `🚀 Socket connected: [id]`

- [ ] **Join room**
  - User ID is provided
  - `joinRoom` event emitted
  - Console shows: `➡️ Emitted joinRoom: [userId]`

- [ ] **Reconnection**
  - Disconnect and reconnect
  - Auto-reconnection works (5 attempts, 3s delay)
  - Console shows reconnection attempts

- [ ] **Disconnect**
  - Clean disconnect works
  - Console shows: `🔌 Socket disconnected`

### ✅ Message Tests

- [ ] **Send Message**
  - Message payload is correct
  - `sendMessage` event emitted
  - No errors in console

- [ ] **Receive Message**
  - `onUpdateMessage` listener registered
  - Messages received from server
  - Console shows: `📩 Received Message: [data]`

- [ ] **Mark as Read**
  - `markAsRead` event emitted
  - Correct message ID sent
  - Server confirms receipt

- [ ] **Internal Comments**
  - `internalCommentFromRCMS` event emitted
  - Comment data structure correct
  - `updateInternalComment` listener receives updates

### ✅ Error Handling

- [ ] **Connection Errors**
  - Test with wrong URL
  - Console shows: `❌ Socket connect error: [error]`
  - App handles gracefully

- [ ] **Network Issues**
  - Turn off WiFi/data
  - Socket attempts reconnection
  - UI shows disconnected state

- [ ] **Invalid Data**
  - Send malformed message
  - Check error handling
  - App doesn't crash

---

## Common Issues & Solutions

### ❌ "Socket not connecting"

**Possible Causes:**
1. Wrong server URL
2. Server not running
3. Network/firewall blocking WebSocket
4. CORS issues (backend config)

**Solutions:**
```dart
// 1. Verify URL
debugPrint('Connecting to: ${_serverUrlController.text}');

// 2. Check socket options
socket = io.io(
  baseUrl,
  io.OptionBuilder()
    .setTransports(['websocket'])  // Force WebSocket
    .disableAutoConnect()
    .enableReconnection()
    .build(),
);

// 3. Test with curl
// Terminal: curl https://api.repaircms.com/socket.io/?EIO=4&transport=polling
```

### ❌ "Events not received"

**Possible Causes:**
1. Listener not registered before event fires
2. Wrong event name
3. Not joined to room

**Solutions:**
```dart
// 1. Register listeners BEFORE connecting
_setupSocketListeners();
_socketService.connect(...);

// 2. Verify event names match backend
socketService.on('onUpdateMessage', (data) { ... });  // Exact match!

// 3. Always join room after connection
socket.once('connect', (_) {
  joinRoom(userId);
});
```

### ❌ "Messages not sending"

**Possible Causes:**
1. Socket not connected
2. Invalid payload structure
3. Missing required fields

**Solutions:**
```dart
// 1. Check connection first
if (socketService.socket?.connected != true) {
  debugPrint('Socket not connected!');
  return;
}

// 2. Validate payload
final messageData = {
  'sender': {'email': '...', 'name': '...'},      // Required
  'receiver': {'email': '...', 'name': '...'},    // Required
  'message': {
    'message': 'text',
    'messageType': 'standard',
  },
  'conversationId': 'conv_123',                    // Required
  'userId': 'user_123',                            // Required
  'participants': 'sender-job-receiver',           // Required
  'loggedUserId': 'user_123',                      // Required
};

// 3. Log the payload
debugPrint('Sending: ${jsonEncode(messageData)}');
socketService.sendMessage(messageData);
```

### ❌ "Auto-reconnection not working"

**Solutions:**
```dart
// Ensure reconnection is enabled
io.OptionBuilder()
  .enableReconnection()
  .setReconnectionAttempts(5)
  .setReconnectionDelay(3000)
  .build()

// Add reconnection listeners
socket.on('reconnect', (attempt) {
  debugPrint('✅ Reconnected after $attempt attempts');
});

socket.on('reconnect_attempt', (attempt) {
  debugPrint('🔄 Reconnection attempt $attempt');
});

socket.on('reconnect_failed', (_) {
  debugPrint('❌ Reconnection failed after all attempts');
});
```

---

## Backend Requirements

Your backend must support:

### 1. Socket.io Server Setup
```javascript
const io = require('socket.io')(server, {
  cors: {
    origin: "*",  // Configure properly for production
    methods: ["GET", "POST"]
  }
});
```

### 2. Required Events (Backend must handle)
- `joinRoom` - Join user-specific room
- `sendMessage` - Broadcast message to conversation
- `markAsRead` - Update read status
- `internalCommentFromRCMS` - Handle internal comments

### 3. Required Events (Backend must emit)
- `onUpdateMessage` - Send new messages to clients
- `messageSeen` - Notify message read status
- `updateInternalComment` - Send comment updates

---

## Testing with Postman/Insomnia

1. Install Socket.io client extension
2. Connect to: `wss://api.repaircms.com`
3. Test events:

**Join Room:**
```json
Event: joinRoom
Data: "user_123"
```

**Send Message:**
```json
Event: sendMessage
Data: {
  "sender": {"email": "test@example.com", "name": "Test"},
  "receiver": {"email": "receiver@example.com", "name": "Receiver"},
  "message": {"message": "Hello", "messageType": "standard"},
  "conversationId": "conv_123",
  "userId": "user_123",
  "participants": "test@example.com-general-receiver@example.com",
  "loggedUserId": "user_123"
}
```

---

## Production Checklist

Before deploying:

- [ ] Remove or disable SocketTestScreen
- [ ] Configure production server URL
- [ ] Enable SSL/TLS (wss://)
- [ ] Set proper CORS origins
- [ ] Add authentication to socket connection
- [ ] Implement proper error boundaries
- [ ] Add analytics/monitoring
- [ ] Test on real devices (iOS/Android)
- [ ] Test with poor network conditions
- [ ] Verify message delivery guarantees
- [ ] Test with multiple concurrent users

---

## Debug Logs Reference

| Emoji | Type | Description |
|-------|------|-------------|
| 🚀 | Success | Socket connected |
| 🔌 | Info | Socket disconnected |
| ❌ | Error | Connection/socket error |
| ➡️ | Action | Event emitted to server |
| 📩 | Receive | Message/event received |
| 📤 | Send | Message sent |
| 👁️ | Info | Message seen update |
| 💬 | Info | Internal comment |
| ⚠️ | Warning | Invalid input/state |
| 🔄 | Info | Reconnection attempt |
| ✅ | Success | Operation successful |

---

## Quick Start Test Commands

```bash
# 1. Run your app
flutter run

# 2. Navigate to Socket Test Screen
# (Add to your menu or use direct navigation)

# 3. In debug console, filter logs:
# macOS/Linux: grep "Socket"
# Windows: findstr "Socket"

# 4. Test connection
# Enter URL, User ID, click Connect

# 5. Monitor logs
# Watch for: 🚀 Socket connected

# 6. Send test message
# Fill fields, click Send

# 7. Check backend logs
# Verify message received on server
```

---

## Next Steps

1. ✅ Use **SocketTestScreen** for comprehensive testing
2. ✅ Verify all events are working (connect, join, send, receive)
3. ✅ Test on real device (not just simulator)
4. ✅ Coordinate with backend team to verify data flow
5. ✅ Add monitoring/analytics for production
6. ✅ Document any backend-specific event formats

Need help? Check console logs and refer to the emoji guide above! 🚀
