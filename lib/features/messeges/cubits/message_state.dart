part of 'message_cubit.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class ConversationsLoaded extends MessageState {
  final List<Conversation> conversations;

  ConversationsLoaded({required this.conversations});
}

class MessagesLoaded extends MessageState {
  final List<Conversation> messages;
  final String conversationId;

  MessagesLoaded({required this.messages, required this.conversationId});
}

class MessageSent extends MessageState {
  final Conversation message;
  final List<Conversation> messages;
  final String conversationId;

  MessageSent({required this.message, required this.messages, required this.conversationId});
}

class MessageError extends MessageState {
  final String message;

  MessageError({required this.message});
}

class MessageReceived extends MessageState {
  final Conversation message;
  final List<Conversation> messages;
  final String conversationId;

  MessageReceived({required this.message, required this.messages, required this.conversationId});
}
