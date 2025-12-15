import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repair_cms/core/services/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

// Mock for socket.io Socket
class MockSocket extends Mock implements io.Socket {}

void main() {
  late SocketService socketService;
  late MockSocket mockSocket;

  setUp(() {
    socketService = SocketService();
    mockSocket = MockSocket();
  });

  group('SocketService - Connection', () {
    test('creates socket instance with correct configuration', () {
      // Note: In real testing, you'd need to mock the io.io constructor
      // This is a structural test to verify the service exists
      expect(socketService, isNotNull);
      expect(socketService.socket, isNull); // Before connection
    });

    test('isConnected returns false when socket is null', () {
      socketService.socket = null;
      expect(socketService.isConnected, isFalse);
    });

    test('isConnected returns socket connected status when socket exists', () {
      when(() => mockSocket.connected).thenReturn(true);
      socketService.socket = mockSocket;

      expect(socketService.isConnected, isTrue);
    });

    test('isConnected returns false when socket is disconnected', () {
      when(() => mockSocket.connected).thenReturn(false);
      socketService.socket = mockSocket;

      expect(socketService.isConnected, isFalse);
    });
  });

  group('SocketService - Disconnect', () {
    test('disconnects socket and sets to null', () {
      when(() => mockSocket.disconnect()).thenReturn(mockSocket);
      socketService.socket = mockSocket;

      socketService.disconnect();

      verify(() => mockSocket.disconnect()).called(1);
      expect(socketService.socket, isNull);
    });

    test('handles disconnect when socket is already null', () {
      socketService.socket = null;

      // Should not throw
      socketService.disconnect();

      expect(socketService.socket, isNull);
    });

    test('handles disconnect errors gracefully', () {
      when(() => mockSocket.disconnect()).thenThrow(Exception('Disconnect error'));
      socketService.socket = mockSocket;

      // Should not throw, error is caught and logged
      socketService.disconnect();
    });
  });

  group('SocketService - Join Room', () {
    test('emits joinRoom event with userId', () {
      when(() => mockSocket.emit(any(), any())).thenReturn(mockSocket);
      socketService.socket = mockSocket;

      socketService.joinRoom('user123');

      verify(() => mockSocket.emit('joinRoom', 'user123')).called(1);
    });

    test('does not emit if socket is null', () {
      socketService.socket = null;

      // Should not throw
      socketService.joinRoom('user123');
    });
  });

  group('SocketService - Send Message', () {
    test('sends message via socket', () {
      when(() => mockSocket.emit(any(), any())).thenReturn(mockSocket);
      socketService.socket = mockSocket;

      final messageData = {'text': 'Hello', 'sender': 'user123'};
      socketService.sendMessage(messageData);

      verify(() => mockSocket.emit('sendMessage', messageData)).called(1);
    });

    test('handles null socket gracefully', () {
      socketService.socket = null;

      final messageData = {'text': 'Hello'};
      socketService.sendMessage(messageData);

      // Should not throw
    });
  });

  group('SocketService - Mark As Read', () {
    test('emits markAsRead event', () {
      when(() => mockSocket.emit(any(), any())).thenReturn(mockSocket);
      socketService.socket = mockSocket;

      final messageData = {'messageId': '123'};
      socketService.markAsRead(messageData);

      verify(() => mockSocket.emit('markAsRead', messageData)).called(1);
    });
  });

  group('SocketService - Internal Comment', () {
    test('emits internalCommentFromRCMS event', () {
      when(() => mockSocket.emit(any(), any())).thenReturn(mockSocket);
      socketService.socket = mockSocket;

      final commentData = {
        'message': {'id': '1'},
        'comment': {'text': 'Test'},
      };
      socketService.sendInternalComment(commentData);

      verify(() => mockSocket.emit('internalCommentFromRCMS', commentData)).called(1);
    });
  });

  group('SocketService - Generic Emit', () {
    test('emits custom event with payload', () {
      when(() => mockSocket.emit(any(), any())).thenReturn(mockSocket);
      socketService.socket = mockSocket;

      socketService.emit('customEvent', {'data': 'test'});

      verify(() => mockSocket.emit('customEvent', {'data': 'test'})).called(1);
    });

    test('handles null socket', () {
      socketService.socket = null;

      // Should not throw
      socketService.emit('customEvent', {'data': 'test'});
    });
  });

  group('SocketService - Event Listeners', () {
    test('registers event listener', () {
      when(() => mockSocket.on(any(), any())).thenReturn(() {});
      socketService.socket = mockSocket;

      void handler(dynamic data) {
        // Handler logic
      }

      socketService.on('testEvent', handler);

      verify(() => mockSocket.on('testEvent', handler)).called(1);
    });

    test('removes event listener', () {
      when(() => mockSocket.off(any())).thenReturn(mockSocket);
      socketService.socket = mockSocket;

      socketService.off('testEvent');

      verify(() => mockSocket.off('testEvent')).called(1);
    });

    test('handles null socket when adding listener', () {
      socketService.socket = null;

      void handler(dynamic data) {}

      // Should not throw
      socketService.on('testEvent', handler);
    });

    test('handles null socket when removing listener', () {
      socketService.socket = null;

      // Should not throw
      socketService.off('testEvent');
    });
  });

  group('SocketService - Connection State', () {
    test('tracks connection state correctly', () {
      // Initially disconnected
      socketService.socket = null;
      expect(socketService.isConnected, isFalse);

      // After connection
      when(() => mockSocket.connected).thenReturn(true);
      socketService.socket = mockSocket;
      expect(socketService.isConnected, isTrue);

      // After disconnection
      when(() => mockSocket.connected).thenReturn(false);
      expect(socketService.isConnected, isFalse);
    });
  });
}
