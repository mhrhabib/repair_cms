# RepairCMS — Mobile Socket Integration Guide (Flutter)

This guide explains how to integrate socket.io in the RepairCMS Flutter app to match the existing React behavior.

Overview
- Socket package: `socket_io_client: ^2.0.0`
- Global service file: `lib/core/services/socket_service.dart`
- Register the service in DI: `lib/set_up_di.dart`
- Connect on app start (or after sign-in) and join per-user room

Quick checklist
1. Add dependency to `pubspec.yaml`:

```yaml
dependencies:
  socket_io_client: ^2.0.0
```

2. SocketService (provided)
- File: `lib/core/services/socket_service.dart`
- Exposes: `connect`, `disconnect`, `joinRoom`, `sendMessage`, `sendInternalComment`, `markAsRead`, `on`, `off`, `emit`
- Singleton exported as `socketService`.

3. Register in DI
- In `lib/set_up_di.dart` register `SocketService` as a lazy singleton:

```dart
_getIt.registerLazySingleton<SocketService>(() => socketService);
```

4. Connect & join (where to call)
- Best places:
  - After user signs in (when you know `userId`)
  - Or in `main()` after `GetStorage.init()` and DI init if you can read stored `userId`.

Example (connect after sign-in):

```dart
final socket = SetUpDI.getIt<SocketService>();
final baseUrl = '<YOUR_BACKEND_URL>'; // same BASE_URL used by React
final userId = storage.read('userId') ?? '';
socket.connect(baseUrl: baseUrl, userId: userId);
```

Disconnect when user logs out:

```dart
socket.disconnect();
```

5. Join room (per user)
React: `socket.emit('joinRoom', userId)`

Flutter:

```dart
SetUpDI.getIt<SocketService>().joinRoom(userId);
```

6. Sending messages / attachments
React: `socket.emit('sendMessage', messageData)`

Flutter example:

```dart
void sendMessage(Map<String, dynamic> messageData) {
  SetUpDI.getIt<SocketService>().sendMessage(messageData);
}
```

- Attachments: include an `"attachment": [...uploadedFiles]` field in `messageData`.

Message payload contract (must match server):

```json
{
  "sender": { "email": "", "name": "" },
  "receiver": { "email": "", "name": "" },
  "message": { "message": "", "messageType": "standard | attachment | comment", "jobId": "" },
  "seen": false,
  "conversationId": "",
  "userId": "",
  "participants": "SENDEREMAIL-JOBID-RECEIVEREMAIL",
  "loggedUserId": ""
}
```

7. Sending internal comments
React events:
- Emit: `internalCommentFromRCMS`
- Listen: `updateInternalComment`

Flutter emit:

```dart
SetUpDI.getIt<SocketService>().sendInternalComment({ /* message + comment */ });
```

8. Listening for events
React listens to: `messageSeen`, `updateInternalComment`, `onUpdateMessage`, `markAsRead`.

Flutter listeners (example):

```dart
final socket = SetUpDI.getIt<SocketService>();

socket.on('messageSeen', (data) {
  // update Bloc / state
});

socket.on('updateInternalComment', (data) {
  // update internal comments UI
});

socket.on('onUpdateMessage', (data) {
  // handle push / show local notification
  handleNotification(data);
});
```

Remove listeners when widget disposes:

```dart
socket.off('onUpdateMessage');
```

9. Mark messages as read
React: `socket.emit('markAsRead', message)`

Flutter:

```dart
SetUpDI.getIt<SocketService>().markAsRead(messagePayload);
```

Call this when user opens a conversation.

10. Push / Local notifications handling
Implement a `handleNotification(dynamic data)` function that:
- Updates your Bloc/Provider state with new message/notification
- Optionally triggers a local notification (via `flutter_local_notifications`) if app is in background

11. Summary of events
Client Emits:
- `joinRoom` — join user room
- `sendMessage` — send chat or attachment
- `markAsRead` — mark messages as seen
- `internalCommentFromRCMS` — add/edit comments

Client Listens:
- `messageSeen` — server confirms message seen
- `updateInternalComment` — updated comment payload
- `onUpdateMessage` — server push for new messages/notifications

12. Message types to support
- `standard`
- `attachment`
- `comment`
- `quotation` (future-proof)


Notes / Tips
- Make sure `GetStorage.init()` runs before attempting to read `userId`.
- Prefer connecting after signin so you have a fresh userId.
- Keep socket listeners in the Bloc or a central manager where you can update state consistently.
- For file uploads, upload via API first to get file metadata/URL, then include file info in the `attachment` array when emitting `sendMessage`.


If you want, I can:
- Patch `main.dart` to automatically connect (if `userId` exists) and register listeners.
- Wire socket listeners into a `ChatCubit` or other cubits to automatically update app state on incoming events.
- Add integration tests or a small demo page showing join/send/listen flows.

Tell me which of these you want me to implement next (connect in `main.dart`, wire into a cubit, add demo page, or add upload+emit helpers).