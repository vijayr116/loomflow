import 'package:equatable/equatable.dart';
import 'package:loomflow/models/user_model.dart';

enum WeaverStatus { initial, loading, success, failure }

class WeaverState extends Equatable {
  final WeaverStatus status;
  final List<UserModel> weavers;
  final String? errorMessage;

  const WeaverState({
    this.status = WeaverStatus.initial,
    this.weavers = const [],
    this.errorMessage,
  });

  WeaverState copyWith({
    WeaverStatus? status,
    String? errorMessage,
    List<UserModel>? weavers,
  }) {
    return WeaverState(
      weavers: weavers ?? this.weavers,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [errorMessage, status, weavers];
}
