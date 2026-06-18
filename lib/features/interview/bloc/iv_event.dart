import 'package:equatable/equatable.dart';

abstract class IvEvent extends Equatable {
  const IvEvent();
}

class IvEventFetch extends IvEvent {
  @override
  List<Object?> get props => [];
}

class IvEventAdd extends IvEvent {
  final String name;
  final String address;

  const IvEventAdd({required this.name, required this.address});

  @override
  List<Object?> get props => [name, address];
}
