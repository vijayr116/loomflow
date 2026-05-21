import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {}

class LoadDashboardEvent extends DashboardEvent {
  @override
  List<Object?> get props => [];
}
