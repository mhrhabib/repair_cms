# Messaging System Implementation Guide

## Overview
Complete socket.io-based real-time messaging system matching the React implementation. Includes inbox screen showing all conversations and individual chat screens for messaging.

## Architecture

### Components Created

1. **SocketService** (`lib/core/services/socket_service.dart`)
   - Singleton service for socket.io connection
   - Handles connection, disconnection, room joining
   - Provides methods to emit and listen to socket events

2. **Message Models** (`lib/features/messeges/models/message_model.dart`)
   - `MessageModel`: Complete message structure
   - `ConversationModel`: Conversation metadata for inbox
   - `SenderReceiver`: Participant information
   - `MessageContent`: Message payload with type
   - `AttachmentModel`: File attachment data

3. **Message States** (`lib/features/messeges/cubits/message_state.dart`)
   - `MessageInitial`: Initial state
   - `MessageLoading`: Loading state
   - `ConversationsLoaded`: Inbox data
   - `MessagesLoaded`: Chat messages
   - `MessageSent`: Send confirmation
   - `MessageReceived`: Real-time message update
   - `MessageError`: Error handling

4. **MessageCubit** (`lib/features/messeges/cubits/message_cubit.dart`)
   - Business logic for messaging
   - Socket event listeners setup
   - Manages conversations and messages state
   - Handles send, receive, mark-as-read operations

5. **MessagesScreen** (`lib/features/messeges/messges_screen.dart`)
   - Inbox screen showing all conversations
   - Real-time updates via BlocConsumer
   - Selection mode for deleting conversations
   - Navigates to ChatConversationScreen

6. **ChatConversationScreen** (`lib/features/messeges/chat_conversation_screen.dart`)
   - Individual chat interface
   - Message bubbles (sent/received)
   - Real-time message updates
   - Mark messages as read automatically
   - Support for attachments and internal comments

## Socket Events

### Events Emitted (to server)
- `joinRoom`: Join user-specific room on connection
- `sendMessage`: Send new message
- `markAsRead`: Mark message as read
- `internalCommentFromRCMS`: Send internal comment

### Events Listened (from server)
- `onUpdateMessage`: New message received
- `messageSeen`: Message read status update
- `updateInternalComment`: Internal comment update

## Setup & Configuration

### 1. Dependencies Registered
✅ SocketService registered in `lib/set_up_di.dart`
✅ MessageCubit registered in `lib/set_up_di.dart`
✅ MessageCubit added to providers in `lib/main.dart`

### 2. Socket Connection
Add this code in your app's initialization (after user login):

```dart
// In your login success handler or app startup
final storage = GetStorage();
final userId = storage.read('userId');

if (userId != null) {
  SetUpDI.getIt<SocketService>().connect(
    baseUrl: 'YOUR_BACKEND_URL', // e.g., 'https://api.repaircms.com'
    userId: userId,
  );
}
```

### 3. Socket Disconnection
When user logs out:

```dart
SetUpDI.getIt<SocketService>().disconnect();
```

## Usage Examples

### Sending a Message
```dart
context.read<MessageCubit>().sendMessage(
  conversationId: 'conversation_123',
  receiverEmail: 'user@example.com',
  messageText: 'Hello!',
  messageType: 'standard', // or 'attachment', 'comment', 'quotation'
  jobId: 'job_456', // optional
);
```

### Sending Internal Comment
```dart
context.read<MessageCubit>().sendInternalComment(
  message: originalMessage,
  comment: 'This is an internal note',
);
```

### Marking Message as Read
```dart
context.read<MessageCubit>().markAsRead(message);
```

### Loading Conversations (Inbox)
```dart
context.read<MessageCubit>().loadConversations();
```

### Loading Messages for Conversation
```dart
context.read<MessageCubit>().loadMessages('conversation_123');
```

## Message Payload Structure

### sendMessage Payload
```json
{
  "conversationId": "conversation_123",
  "sender": {
    "email": "sender@example.com",
    "name": "Sender Name"
  },
  "receiver": {
    "email": "receiver@example.com",
    "name": "Receiver Name"
  },
  "message": {
    "message": "Message text",
    "messageType": "standard",
    "jobId": "job_456"
  },
  "seen": false,
  "userId": "user_123",
  "participants": ["sender@example.com", "receiver@example.com"],
  "loggedUserId": "user_123"
}
```

### markAsRead Payload
```json
{
  "_id": "message_id",
  "conversationId": "conversation_123",
  "seen": true
}
```

### internalCommentFromRCMS Payload
```json
{
  "_id": "message_id",
  "conversationId": "conversation_123",
  "internalComment": "Internal comment text"
}
```

## Real-Time Features

### Automatic Updates
- New messages appear instantly via socket listeners
- Read receipts update in real-time
- Conversation list updates when new messages arrive
- Unread count updates automatically

### Message States
- **MessageReceived**: New message from socket → Updates UI automatically
- **MessageSent**: Message sent successfully → Added to local list
- **MessagesLoaded**: Messages loaded for conversation
- **ConversationsLoaded**: Inbox conversations loaded

## UI Features

### Inbox Screen (MessagesScreen)
- List of all conversations
- Last message preview
- Unread message count badge
- Selection mode for bulk delete
- Empty state when no messages
- Pull to refresh (can be added)

### Chat Screen (ChatConversationScreen)
- Message bubbles (blue for sent, white for received)
- Sender avatars
- Timestamp display
- Read receipts (single/double check marks)
- Attachment support (displays file info)
- Internal comment badges
- Auto-scroll to bottom on new messages
- Auto-mark messages as read when viewing
- Empty state for new conversations

## Message Types

### Standard Message
```dart
messageType: 'standard'
```
Regular text message between users.

### Attachment Message
```dart
messageType: 'attachment'
attachments: [
  AttachmentModel(
    url: 'https://...',
    name: 'file.pdf',
    type: 'application/pdf',
    size: 1024000,
  )
]
```

### Internal Comment
```dart
messageType: 'comment'
```
Only visible to internal team members.

### Quotation Message
```dart
messageType: 'quotation'
jobId: 'job_123'
```
Related to job quotations.

## Troubleshooting

### Socket Not Connecting
1. Verify backend URL is correct
2. Check network permissions in AndroidManifest.xml / Info.plist
3. Ensure userId is available in GetStorage
4. Check server is running and accessible

### Messages Not Updating
1. Verify socket listeners are registered in MessageCubit
2. Check event names match server implementation
3. Ensure MessageCubit is added to providers in main.dart
4. Check BlocConsumer is used in UI screens

### DI Errors
1. Ensure SocketService registered before MessageCubit
2. Verify SetUpDI.init() is called in main()
3. Check all dependencies are properly imported

### State Not Updating
1. Use BlocConsumer (not BlocBuilder) for both listening and building
2. Verify emit() calls in cubit methods
3. Check state types match in BlocConsumer listener

## Next Steps / Enhancements

### File Attachments
1. Add file picker (use `file_picker` package)
2. Upload file to server first
3. Get file URL from server response
4. Include attachment data in sendMessage call

```dart
// Example attachment upload flow
final FilePickerResult? result = await FilePicker.platform.pickFiles();
if (result != null) {
  final file = result.files.first;
  
  // Upload to server (implement upload API call)
  final uploadedUrl = await uploadFile(file);
  
  // Send message with attachment
  context.read<MessageCubit>().sendMessage(
    conversationId: conversationId,
    receiverEmail: receiverEmail,
    messageText: 'Attachment sent',
    messageType: 'attachment',
    attachments: [
      AttachmentModel(
        url: uploadedUrl,
        name: file.name,
        type: file.extension,
        size: file.size,
      ),
    ],
  );
}
```

### Push Notifications
1. Integrate Firebase Cloud Messaging (FCM)
2. Listen to socket events when app in background
3. Show notification for new messages
4. Navigate to chat on notification tap

### Typing Indicators
1. Emit `typing` event when user types
2. Listen to `userTyping` event from server
3. Show "User is typing..." indicator in chat

### Message Search
1. Add search bar in MessagesScreen
2. Filter conversations by participant name or message content
3. Highlight search results

### Message Reactions
1. Long-press message to show reaction options
2. Emit `addReaction` event with emoji
3. Display reactions below message bubble

### Voice Messages
1. Record audio using `record` package
2. Upload audio file to server
3. Send as attachment with type 'audio'
4. Play audio in chat bubble

## API Integration Requirements

### Backend Endpoints Needed
Your backend should support:

1. **GET /conversations/:userId**
   - Returns list of conversations for user
   - Response: `{ conversations: [...] }`

2. **GET /messages/:conversationId**
   - Returns messages for conversation
   - Response: `{ messages: [...] }`

3. **POST /upload/attachment**
   - Upload file for message attachment
   - Response: `{ url: 'https://...' }`

### Socket Events Documentation
Ensure your backend implements:
- Connection event handling
- Room joining logic
- Message broadcasting to conversation participants
- Read receipt updates
- Internal comment handling

## Testing Checklist

- [ ] Socket connects on app startup with userId
- [ ] Inbox loads conversations correctly
- [ ] New messages appear in real-time
- [ ] Sending messages works (standard, comment)
- [ ] Messages marked as read automatically when viewing chat
- [ ] Read receipts update in real-time
- [ ] Unread count badge displays correctly
- [ ] Conversation list updates when new message arrives
- [ ] Attachments display correctly (file icon, name, size)
- [ ] Internal comments show badge
- [ ] Empty states display when no data
- [ ] Selection mode works for deleting conversations
- [ ] Socket disconnects on logout
- [ ] Error messages display for failures

## Performance Considerations

1. **Message Pagination**: Currently loads all messages. Consider implementing:
   ```dart
   loadMessages(conversationId, {int page = 1, int limit = 50})
   ```

2. **Conversation List Pagination**: For users with many conversations

3. **Message Caching**: Store recent messages locally using Hive or SQLite

4. **Image Optimization**: Compress images before uploading

5. **Socket Reconnection**: SocketService already handles auto-reconnection (5 attempts, 3s delay)

## Security Considerations

1. **Authentication**: Ensure socket connection includes auth token
2. **Message Validation**: Validate sender/receiver on backend
3. **Rate Limiting**: Implement message rate limits on backend
4. **File Upload**: Validate file types and sizes on backend
5. **XSS Prevention**: Sanitize message content if rendering HTML

## Support & Maintenance

### Debug Logging
The implementation includes extensive debug logging with emojis:
- 🚀 Method start
- ✅ Success operations
- ❌ Errors
- 📊 Data/responses
- 👤 User context
- 🌐 Network calls
- 💥 Unexpected errors

Monitor these logs during development and testing.

### Common Issues

**"Socket not connected" error**:
- Check socket.isConnected before emitting events
- Ensure connect() was called successfully
- Verify backend is reachable

**Messages duplicating**:
- Check if socket listeners are registered multiple times
- Ensure cubit is not recreated unnecessarily

**UI not updating**:
- Verify BlocConsumer is used (not just BlocBuilder)
- Check emit() is called in cubit methods
- Ensure state classes extend correctly

## Conclusion

The messaging system is fully implemented and ready to use. Make sure to:
1. Configure your backend URL in socket connect call
2. Test all socket events with your backend
3. Add file upload functionality when needed
4. Implement push notifications for production
5. Add analytics for message tracking

For questions or issues, refer to:
- `docs/socket_integration.md` for socket details
- Source code documentation in each file
- Debug logs in console during runtime
