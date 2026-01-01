import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repair_cms/core/services/local_notification_service.dart';
import 'package:repair_cms/core/services/socket_service.dart';
import 'package:repair_cms/features/messeges/cubits/message_cubit.dart';
import 'package:repair_cms/features/messeges/models/conversation_model.dart';
import 'package:repair_cms/features/messeges/models/message_model.dart';
import 'package:repair_cms/features/messeges/repository/message_repository.dart';

// Mock classes
class MockSocketService extends Mock implements SocketService {}

class MockMessageRepository extends Mock implements MessageRepository {}

class MockLocalNotificationService extends Mock implements LocalNotificationService {}

class MockGetStorage extends Mock implements GetStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSocketService mockSocketService;
  late MockMessageRepository mockMessageRepository;
  late MockLocalNotificationService mockNotificationService;
  late MessageCubit messageCubit;

  setUp(() {
    mockSocketService = MockSocketService();
    mockMessageRepository = MockMessageRepository();
    mockNotificationService = MockLocalNotificationService();

    // Setup mock socket service
    when(() => mockSocketService.on(any(), any())).thenReturn(null);
    when(() => mockSocketService.off(any())).thenReturn(null);
    when(() => mockSocketService.isConnected).thenReturn(true);
    when(() => mockSocketService.sendMessage(any())).thenReturn(null);
    when(() => mockSocketService.markAsRead(any())).thenReturn(null);

    // Setup mock notification service
    when(
      () => mockNotificationService.showMessageNotification(
        senderName: any(named: 'senderName'),
        messageText: any(named: 'messageText'),
        conversationId: any(named: 'conversationId'),
        jobId: any(named: 'jobId'),
      ),
    ).thenAnswer((_) async => Future.value());

    messageCubit = MessageCubit(
      socketService: mockSocketService,
      messageRepository: mockMessageRepository,
      notificationService: mockNotificationService,
    );
  });

  tearDown(() {
    messageCubit.close();
  });

  group('MessageCubit Initialization', () {
    test('initial state is MessageInitial', () {
      expect(messageCubit.state, isA<MessageInitial>());
    });

    test('registers socket listeners on initialization', () {
      verify(() => mockSocketService.on('onUpdateMessage', any())).called(1);
      verify(() => mockSocketService.on('messageSeen', any())).called(1);
      verify(() => mockSocketService.on('receiveMessage', any())).called(1);
      verify(() => mockSocketService.on('updateInternalComment', any())).called(1);
    });
  });

  group('MessageCubit - Load Conversation', () {
    final mockConversationModel = ConversationModel(
      success: true,
      message: 'Success',
      data: [
        Conversation(
          id: '1',
          conversationId: 'conv123',
          sender: Sender(email: 'sender@test.com', name: 'Test Sender'),
          receiver: Sender(email: 'receiver@test.com', name: 'Test Receiver'),
          message: Message(message: 'Hello', messageType: 'standard'),
          seen: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      ],
      pages: 1,
      total: 1,
    );

    blocTest<MessageCubit, MessageState>(
      'emits [MessageLoading, MessagesLoaded] when loadConversation succeeds',
      build: () {
        when(
          () => mockMessageRepository.getConversation(conversationId: any(named: 'conversationId')),
        ).thenAnswer((_) async => mockConversationModel);
        return messageCubit;
      },
      act: (cubit) => cubit.loadConversation(conversationId: 'conv123'),
      expect: () => [
        isA<MessageLoading>(),
        isA<MessagesLoaded>()
            .having((state) => state.messages.length, 'messages length', 1)
            .having((state) => state.conversationId, 'conversationId', 'conv123'),
      ],
      verify: (_) {
        verify(() => mockMessageRepository.getConversation(conversationId: 'conv123')).called(1);
      },
    );

    blocTest<MessageCubit, MessageState>(
      'emits [MessageLoading, MessageError] when loadConversation fails',
      build: () {
        when(
          () => mockMessageRepository.getConversation(conversationId: any(named: 'conversationId')),
        ).thenThrow(MessageException(message: 'Failed to load'));
        return messageCubit;
      },
      act: (cubit) => cubit.loadConversation(conversationId: 'conv123'),
      expect: () => [
        isA<MessageLoading>(),
        isA<MessageError>().having((state) => state.message, 'error message', 'Failed to load'),
      ],
    );

    blocTest<MessageCubit, MessageState>(
      'emits MessagesLoaded with empty list when no messages found',
      build: () {
        when(
          () => mockMessageRepository.getConversation(conversationId: any(named: 'conversationId')),
        ).thenAnswer((_) async => ConversationModel(success: true, message: 'Success', data: [], pages: 0, total: 0));
        return messageCubit;
      },
      act: (cubit) => cubit.loadConversation(conversationId: 'conv123'),
      expect: () => [
        isA<MessageLoading>(),
        isA<MessagesLoaded>()
            .having((state) => state.messages.length, 'messages length', 0)
            .having((state) => state.conversationId, 'conversationId', 'conv123'),
      ],
    );
  });

  group('MessageCubit - Send Message', () {
    final sender = SenderReceiver(email: 'sender@test.com', name: 'Sender');
    final receiver = SenderReceiver(email: 'receiver@test.com', name: 'Receiver');

    blocTest<MessageCubit, MessageState>(
      'sends message successfully when socket is connected',
      build: () => messageCubit,
      act: (cubit) => cubit.sendMessage(
        conversationId: 'conv123',
        sender: sender,
        receiver: receiver,
        messageText: 'Test message',
        userId: 'user1',
        loggedUserId: 'user1',
      ),
      expect: () => [
        isA<MessagesLoaded>(),
        isA<MessageSent>().having((state) => state.message.message?.message, 'message text', 'Test message'),
      ],
      verify: (_) {
        verify(() => mockSocketService.sendMessage(any())).called(1);
      },
    );

    blocTest<MessageCubit, MessageState>(
      'emits MessageError when socket is not connected',
      setUp: () {
        when(() => mockSocketService.isConnected).thenReturn(false);
      },
      build: () => messageCubit,
      act: (cubit) => cubit.sendMessage(
        conversationId: 'conv123',
        sender: sender,
        receiver: receiver,
        messageText: 'Test message',
        userId: 'user1',
        loggedUserId: 'user1',
      ),
      expect: () => [
        isA<MessageError>().having(
          (state) => state.message,
          'error message',
          'Not connected to server. Please check your connection.',
        ),
      ],
      verify: (_) {
        verifyNever(() => mockSocketService.sendMessage(any()));
      },
    );
  });

  group('MessageCubit - Mark As Read', () {
    test('calls socket service when connected', () {
      final conversation = Conversation(
        id: '1',
        conversationId: 'conv123',
        message: Message(message: 'Test'),
      );

      messageCubit.markAsRead(conversation);

      verify(() => mockSocketService.isConnected).called(1);
      verify(() => mockSocketService.markAsRead(any())).called(1);
    });

    test('does not call socket service when disconnected', () {
      when(() => mockSocketService.isConnected).thenReturn(false);

      final conversation = Conversation(
        id: '1',
        conversationId: 'conv123',
        message: Message(message: 'Test'),
      );

      messageCubit.markAsRead(conversation);

      verify(() => mockSocketService.isConnected).called(1);
      verifyNever(() => mockSocketService.markAsRead(any()));
    });
  });

  group('MessageCubit - Internal Comment', () {
    blocTest<MessageCubit, MessageState>(
      'sends internal comment when socket is connected',
      build: () => messageCubit,
      act: (cubit) => cubit.sendInternalComment(message: {'id': '1'}, comment: {'text': 'Test comment'}),
      verify: (_) {
        verify(() => mockSocketService.isConnected).called(1);
        verify(() => mockSocketService.sendInternalComment(any())).called(1);
      },
    );

    blocTest<MessageCubit, MessageState>(
      'emits error when socket is disconnected',
      build: () {
        when(() => mockSocketService.isConnected).thenReturn(false);
        return messageCubit;
      },
      act: (cubit) => cubit.sendInternalComment(message: {'id': '1'}, comment: {'text': 'Test comment'}),
      expect: () => [
        isA<MessageError>().having(
          (state) => state.message,
          'error message',
          'Not connected to server. Please check your connection.',
        ),
      ],
    );
  });

  group('MessageCubit - Notifications', () {
    test('notification service is injected', () {
      // Verify notification service is available
      expect(messageCubit.notificationService, isNotNull);
    });
  });

  group('MessageCubit - Cleanup', () {
    test('removes socket listeners on close', () async {
      await messageCubit.close();

      verify(() => mockSocketService.off('onUpdateMessage')).called(1);
      verify(() => mockSocketService.off('messageSeen')).called(1);
      verify(() => mockSocketService.off('receiveMessage')).called(1);
      verify(() => mockSocketService.off('updateInternalComment')).called(1);
    });
  });

  group('MessageCubit - Load Conversations', () {
    blocTest<MessageCubit, MessageState>(
      'emits [MessageLoading, ConversationsLoaded]',
      build: () => messageCubit,
      act: (cubit) => cubit.loadConversations(),
      expect: () => [isA<MessageLoading>(), isA<ConversationsLoaded>()],
    );
  });
}
