import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../repository/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository})
    : super(const DashboardState(status: DashboardStatus.initial)) {
    on<LoadDashboardEvent>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      final totalJobs = await repository.getTotalJobs();

      final completedJobs = await repository.getCompletedJobs();

      final activeWeavers = await repository.getActiveWeavers();

      final recentJobs = await repository.getRecentJobs();

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          totalJobs: totalJobs,
          completedJobs: completedJobs,
          activeWeavers: activeWeavers,
          recentJobs: recentJobs,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
