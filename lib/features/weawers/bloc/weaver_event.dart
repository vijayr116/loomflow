import 'package:equatable/equatable.dart';
import 'package:loomflow/models/user_model.dart';

abstract class WeaverEvent extends Equatable {}

class AddWeaverEvent extends WeaverEvent {
  final UserModel weaver;
  AddWeaverEvent({required this.weaver});
  @override
  List<Object?> get props => [weaver];
}

class UpdateWeaverEvent extends WeaverEvent {
  final UserModel weaver;
  UpdateWeaverEvent({required this.weaver});
  @override
  List<Object?> get props => [weaver];
}

class FetchWeaversEvent extends WeaverEvent {
  @override
  List<Object?> get props => [];
}

class DeleteWeaverEvent extends WeaverEvent {
  final String id;
  DeleteWeaverEvent({required this.id});
  @override
  List<Object?> get props => [id];
}
