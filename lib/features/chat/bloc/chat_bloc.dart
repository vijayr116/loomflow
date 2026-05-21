import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loomflow/features/chat/bloc/chat_event.dart';
import 'package:loomflow/features/chat/bloc/chat_state.dart';
import 'package:loomflow/features/chat/repository/chat_repository.dart';
import 'package:loomflow/models/message_model.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  StreamSubscription<List<MessageModel>>? _subscription;

  ChatBloc({required this.repository}) : super(ChatState()) {
    on<LoadMessageEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
    on<DeleteAllMessagesEvent>((event, emit) async {
      await repository.deleteAllMessages();
    });
  }

  Future<void> _onLoadMessages(
    LoadMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      await _subscription?.cancel();
      _subscription = repository.getMessages(event.chatId).listen((messages) {
        print("🔥 messages count: ${messages.length}");
        add(MessagesUpdatedEvent(messages: messages));
      });
      print('after bloc');
    } catch (e) {
      print('catch bloc-----');
      emit(
        state.copyWith(status: ChatStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // emit(state.copyWith(status: ChatStatus.loading));
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final messages = MessageModel(
        chatId: event.chatId,
        senderId: user.uid,
        text: event.text,
        timestamp: DateTime.now(),
      );
      await repository.sendMessage(messages: messages);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onMessagesUpdated(MessagesUpdatedEvent event, Emitter<ChatState> emit) {
    print('calling message upt...');
    emit(state.copyWith(status: ChatStatus.success, messages: event.messages));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
