part of 'message_cubit.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class ConversationsLoaded extends MessageState {
  final List<ConversationModel> conversations;

  ConversationsLoaded({required this.conversations});
}

class MessagesLoaded extends MessageState {
  final List<MessageModel> messages;
  final String conversationId;

  MessagesLoaded({required this.messages, required this.conversationId});
}

class MessageSent extends MessageState {
  final MessageModel message;

  MessageSent({required this.message});
}

class MessageError extends MessageState {
  final String message;

  MessageError({required this.message});
}

class MessageReceived extends MessageState {
  final MessageModel message;

  MessageReceived({required this.message});
}
