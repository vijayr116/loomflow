import 'package:equatable/equatable.dart';
import 'package:loomflow/models/job_model.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final int totalJobs;
  final int completedJobs;
  final int activeWeavers;
  final List<JobModel> recentJobs;
  final String? errorMessage;

  const DashboardState({
    required this.status,
    this.totalJobs = 0,
    this.completedJobs = 0,
    this.activeWeavers = 0,
    this.recentJobs = const [],
    this.errorMessage = '',
  });

  DashboardState copyWith({
    DashboardStatus? status,
    int? totalJobs,
    int? completedJobs,
    int? activeWeavers,
    List<JobModel>? recentJobs,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      totalJobs: totalJobs ?? this.totalJobs,
      completedJobs: completedJobs ?? this.completedJobs,
      activeWeavers: activeWeavers ?? this.activeWeavers,
      recentJobs: recentJobs ?? this.recentJobs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    totalJobs,
    completedJobs,
    activeWeavers,
    recentJobs,
    errorMessage,
  ];
}
