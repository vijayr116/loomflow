import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loomflow/features/interview/bloc/iv_event.dart';
import 'package:loomflow/features/interview/bloc/iv_state.dart';
import 'package:loomflow/features/interview/repo/iv_repo.dart';

class IvBloc extends Bloc<IvEvent, IvState> {
  final IvRepo repo;
  IvBloc({required this.repo}) : super(IvState(status: IvStatus.initial)) {
    on<IvEventAdd>(_onIvAdd);
    on<IvEventFetch>(_onFetch);
  }

  Future<void> _onIvAdd(IvEventAdd event, Emitter<IvState> emit) async {
    emit(state.copyWith(status: IvStatus.loading));
    await repo.addData(event.name, event.address);
    emit(state.copyWith(status: IvStatus.success));
  }

  Future<void> _onFetch(IvEventFetch event, Emitter<IvState> emit) async {
    emit(state.copyWith(status: IvStatus.loading));
    var data = repo.getData();
    emit(state.copyWith(status: IvStatus.success, datas: data));
  }
}
