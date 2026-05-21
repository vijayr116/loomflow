import 'package:equatable/equatable.dart';
import 'package:loomflow/models/job_model.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();
}

class CreateJobEvent extends JobEvent {
  final JobModel job;
  const CreateJobEvent({required this.job});

  @override
  List<Object?> get props => [job];
}

class FetchJobEvent extends JobEvent {
  @override
  List<Object?> get props => [];
}

class UpdateJobEvent extends JobEvent {
  final JobModel job;

  const UpdateJobEvent({required this.job});

  @override
  List<Object?> get props => [job];
}

class DeleteJobEvent extends JobEvent {
  final String jobId;
  const DeleteJobEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}
