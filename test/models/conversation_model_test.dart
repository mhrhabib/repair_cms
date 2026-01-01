import 'package:flutter_test/flutter_test.dart';
import 'package:repair_cms/features/messeges/models/conversation_model.dart';

void main() {
  group('Conversation Model', () {
    test('creates Conversation from JSON correctly', () {
      final json = {
        '_id': '123',
        'conversationId': 'conv123',
        'sender': {'email': 'sender@test.com', 'name': 'Sender'},
        'receiver': {'email': 'receiver@test.com', 'name': 'Receiver'},
        'message': {'message': 'Hello', 'messageType': 'standard'},
        'seen': false,
        'createdAt': '2025-12-16T10:00:00.000Z',
      };

      final conversation = Conversation.fromJson(json);

      expect(conversation.sId, '123');
      expect(conversation.conversationId, 'conv123');
      expect(conversation.sender?.email, 'sender@test.com');
      expect(conversation.sender?.name, 'Sender');
      expect(conversation.receiver?.email, 'receiver@test.com');
      expect(conversation.message?.message, 'Hello');
      expect(conversation.seen, false);
      expect(conversation.createdAt, '2025-12-16T10:00:00.000Z');
    });

    test('converts Conversation to JSON correctly', () {
      final conversation = Conversation(
        sId: '123',
        conversationId: 'conv123',
        sender: Sender(email: 'sender@test.com', name: 'Sender'),
        receiver: Sender(email: 'receiver@test.com', name: 'Receiver'),
        message: Message(message: 'Hello', messageType: 'standard'),
        seen: false,
        createdAt: '2025-12-16T10:00:00.000Z',
      );

      final json = conversation.toJson();

      expect(json['_id'], '123');
      expect(json['conversationId'], 'conv123');
      expect(json['sender']['email'], 'sender@test.com');
      expect(json['message']['message'], 'Hello');
      expect(json['seen'], false);
    });

    test('handles null values in JSON', () {
      final json = {'_id': '123', 'conversationId': 'conv123'};

      final conversation = Conversation.fromJson(json);

      expect(conversation.sId, '123');
      expect(conversation.conversationId, 'conv123');
      expect(conversation.sender, isNull);
      expect(conversation.receiver, isNull);
      expect(conversation.message, isNull);
    });

    test('handles message with quotation', () {
      final json = {
        '_id': '123',
        'message': {
          'message': 'Quotation sent',
          'messageType': 'quotation',
          'quotation': {
            'quotationName': 'Repair Quote',
            'subTotal': 10000,
            'vat': 2000,
            'total': 12000,
            'accepted': true,
          },
        },
      };

      final conversation = Conversation.fromJson(json);

      expect(conversation.message?.messageType, 'quotation');
      expect(conversation.message?.quotation?.quotationName, 'Repair Quote');
      expect(conversation.message?.quotation?.total, 12000);
      expect(conversation.message?.quotation?.accepted, true);
    });
  });

  group('Message Model', () {
    test('creates Message from JSON correctly', () {
      final json = {'message': 'Test message', 'messageType': 'standard', 'jobId': 'job123'};

      final message = Message.fromJson(json);

      expect(message.message, 'Test message');
      expect(message.messageType, 'standard');
      expect(message.jobId, 'job123');
    });

    test('converts Message to JSON correctly', () {
      final message = Message(message: 'Test message', messageType: 'comment', jobId: 'job123');

      final json = message.toJson();

      expect(json['message'], 'Test message');
      expect(json['messageType'], 'comment');
      expect(json['jobId'], 'job123');
    });
  });

  group('ConversationModel', () {
    test('creates ConversationModel from JSON with data', () {
      final json = {
        'success': true,
        'message': 'Success',
        'data': [
          {
            '_id': '1',
            'conversationId': 'conv123',
            'message': {'message': 'Hello'},
          },
          {
            '_id': '2',
            'conversationId': 'conv123',
            'message': {'message': 'Hi'},
          },
        ],
        'pages': 1,
        'total': 2,
      };

      final model = ConversationModel.fromJson(json);

      expect(model.success, true);
      expect(model.message, 'Success');
      expect(model.data?.length, 2);
      expect(model.pages, 1);
      expect(model.total, 2);
    });

    test('handles empty data array', () {
      final json = {'success': true, 'message': 'No messages', 'data': [], 'pages': 0, 'total': 0};

      final model = ConversationModel.fromJson(json);

      expect(model.success, true);
      expect(model.data?.isEmpty, true);
      expect(model.pages, 0);
      expect(model.total, 0);
    });

    test('handles error response', () {
      final json = {'success': false, 'message': 'Error', 'error': 'Not found'};

      final model = ConversationModel.fromJson(json);

      expect(model.success, false);
      expect(model.message, 'Error');
      expect(model.error, 'Not found');
      expect(model.data, isNull);
    });
  });

  group('Sender Model', () {
    test('creates Sender from JSON', () {
      final json = {'email': 'user@test.com', 'name': 'Test User'};

      final sender = Sender.fromJson(json);

      expect(sender.email, 'user@test.com');
      expect(sender.name, 'Test User');
    });

    test('converts Sender to JSON', () {
      final sender = Sender(email: 'user@test.com', name: 'Test User');

      final json = sender.toJson();

      expect(json['email'], 'user@test.com');
      expect(json['name'], 'Test User');
    });
  });

  group('Quotation Model', () {
    test('creates Quotation from JSON', () {
      final json = {
        'quotationName': 'Screen Repair',
        'text': 'Replace broken screen',
        'subTotal': 50000,
        'vat': 10000,
        'total': 60000,
        'accepted': true,
        'paymentStatus': 'Paid',
        'serviceItemList': [
          {'name': 'Screen', 'price': 50000},
        ],
        'createdAt': '2025-12-16T10:00:00.000Z',
      };

      final quotation = Quotation.fromJson(json);

      expect(quotation.quotationName, 'Screen Repair');
      expect(quotation.text, 'Replace broken screen');
      expect(quotation.subTotal, 50000);
      expect(quotation.vat, 10000.0);
      expect(quotation.total, 60000.0);
      expect(quotation.accepted, true);
      expect(quotation.paymentStatus, 'Paid');
      expect(quotation.serviceItemList?.length, 1);
    });

    test('handles unaccepted quotation', () {
      final json = {
        'quotationName': 'Battery Replacement',
        'subTotal': 30000,
        'vat': 6000,
        'total': 36000,
        'accepted': false,
      };

      final quotation = Quotation.fromJson(json);

      expect(quotation.quotationName, 'Battery Replacement');
      expect(quotation.accepted, false);
      expect(quotation.paymentStatus, isNull);
    });
  });
}
