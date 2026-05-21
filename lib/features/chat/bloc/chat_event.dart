import 'package:equatable/equatable.dart';
import 'package:loomflow/models/message_model.dart';

abstract class ChatEvent extends Equatable {}

class LoadMessageEvent extends ChatEvent {
  final String chatId;

  LoadMessageEvent(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String text;

  SendMessageEvent({required this.chatId, required this.text});

  @override
  List<Object?> get props => [];
}

class MessagesUpdatedEvent extends ChatEvent {
  final List<MessageModel> messages;

  MessagesUpdatedEvent({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class DeleteAllMessagesEvent extends ChatEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}
