import 'package:equatable/equatable.dart';
import 'package:loomflow/models/job_model.dart';

enum JobStatus { initial, loading, success, failure }

class JobState extends Equatable {
  final JobStatus status;
  final List<JobModel> jobs;
  final String? errorMessage;

  const JobState({
    this.status = JobStatus.initial,
    this.jobs = const [],
    this.errorMessage,
  });

  JobState copyWith({
    JobStatus? status,
    List<JobModel>? jobs,
    String? errorMessage,
  }) {
    return JobState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, jobs, errorMessage];
}
