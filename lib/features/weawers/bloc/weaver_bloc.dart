import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loomflow/features/weawers/bloc/weaver_event.dart';
import 'package:loomflow/features/weawers/bloc/weaver_state.dart';
import 'package:loomflow/features/weawers/repository/weaver_repository.dart';
import 'package:loomflow/models/user_model.dart';

class WeaverBloc extends Bloc<WeaverEvent, WeaverState> {
  final WeaverRepository repository;

  WeaverBloc({required this.repository})
    : super(WeaverState(status: WeaverStatus.initial)) {
    on<FetchWeaversEvent>(_onFetchWeavers);
    on<AddWeaverEvent>(_onAddWeaver);
    on<UpdateWeaverEvent>(_onUpdateWeaver);
    on<DeleteWeaverEvent>(_onDeleteWeaver);
  }

  // 🔥 FETCH
  Future<void> _onFetchWeavers(
    FetchWeaversEvent event,
    Emitter<WeaverState> emit,
  ) async {
    emit(state.copyWith(status: WeaverStatus.loading));

    try {
      final weavers = await repository.fetchActiveWeavers();

      emit(state.copyWith(status: WeaverStatus.success, weavers: weavers));
    } catch (e) {
      emit(
        state.copyWith(
          status: WeaverStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // 🔥 ADD
  Future<void> _onAddWeaver(
    AddWeaverEvent event,
    Emitter<WeaverState> emit,
  ) async {
    try {
      await repository.addWeaver(event.weaver);

      // ✅ refresh list
      add(FetchWeaversEvent());
    } catch (e) {
      emit(
        state.copyWith(
          status: WeaverStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // 🔥 UPDATE
  Future<void> _onUpdateWeaver(
    UpdateWeaverEvent event,
    Emitter<WeaverState> emit,
  ) async {
    emit(state.copyWith(status: WeaverStatus.loading));
    try {
      await repository.updateWeaver(event.weaver);

      // ✅ update locally (fast UI)
      final updated = state.weavers.map((w) {
        if (w.id == event.weaver.id) return event.weaver;
        return w;
      }).toList();

      print(updated);

      emit(
        state.copyWith(
          status: WeaverStatus.success,
          weavers: List<UserModel>.from(updated),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WeaverStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // 🔥 DELETE
  Future<void> _onDeleteWeaver(
    DeleteWeaverEvent event,
    Emitter<WeaverState> emit,
  ) async {
    try {
      await repository.deleteWeaver(event.id);

      final updated = state.weavers.where((w) => w.id != event.id).toList();

      emit(state.copyWith(status: WeaverStatus.success, weavers: updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: WeaverStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
