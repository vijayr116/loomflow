import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loomflow/features/job/bloc/job_event.dart';
import 'package:loomflow/features/job/bloc/job_state.dart';
import 'package:loomflow/features/job/repo/job_repository.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final JobRepository repository;
  JobBloc({required this.repository})
    : super(JobState(status: JobStatus.initial)) {
    on<CreateJobEvent>(_onCreateJobEvent);
    on<FetchJobEvent>(_onfetchJobEvent);
    on<UpdateJobEvent>(_onupdateJobEvent);
    on<DeleteJobEvent>(_onDeleteJob);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print("BLOC ERROR: $error");
    super.onError(error, stackTrace);
  }

  // 🔥 GLOBAL TRANSITION LOGGER
  @override
  void onTransition(Transition<JobEvent, JobState> transition) {
    print("TRANSITION: $transition");
    super.onTransition(transition);
  }

  Future<void> _onCreateJobEvent(
    CreateJobEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(state.copyWith(status: JobStatus.loading));
    try {
      print('creating === ${event.job}');
      final createjob = await repository.createJob(event.job);
      final job = [...state.jobs, createjob];
      emit(state.copyWith(status: JobStatus.success, jobs: job));
      // add(FetchJobEvent());
    } catch (e) {
      print('creating job failed-------------');
      emit(
        state.copyWith(errorMessage: e.toString(), status: JobStatus.failure),
      );
    }
  }

  Future<void> _onupdateJobEvent(
    UpdateJobEvent event,
    Emitter<JobState> emit,
  ) async {
    print("Updating job id: ${event.job.id}");
    emit(state.copyWith(status: JobStatus.loading));
    try {
      await repository.updateJob(event.job);

      final uptJobs = state.jobs.map((j) {
        if (j.id == event.job.id) {
          return event.job;
        }
        return j;
      }).toList();

      emit(state.copyWith(status: JobStatus.success, jobs: uptJobs));

      // add(FetchJobEvent());
    } catch (e) {
      print('Updating job failed-------------  ${e.toString()}');
      emit(
        state.copyWith(errorMessage: e.toString(), status: JobStatus.failure),
      );
    }
  }

  Future<void> _onfetchJobEvent(
    FetchJobEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(state.copyWith(status: JobStatus.loading));

    try {
      final jobs = await repository.fetchJobs();
      emit(state.copyWith(status: JobStatus.success, jobs: jobs));
    } catch (e) {
      emit(
        state.copyWith(errorMessage: e.toString(), status: JobStatus.failure),
      );
    }
  }

  Future<void> _onDeleteJob(
    DeleteJobEvent event,
    Emitter<JobState> emit,
  ) async {
    print('coming to delete........');
    await repository.deleteJob(event.jobId);
    final jobs = state.jobs
        .where((element) => element.id != event.jobId)
        .toList();
    emit(state.copyWith(status: JobStatus.success, jobs: jobs));
    // add(FetchJobEvent());
  }
}
