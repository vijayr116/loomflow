import 'package:equatable/equatable.dart';

enum IvStatus { initial, loading, success, failure }

class IvState extends Equatable {
  final IvStatus status;
  final List<Map<String, dynamic>> datas;
  final String? errorMessage;

  const IvState({
    this.status = IvStatus.initial,
    this.datas = const [],
    this.errorMessage,
  });

  IvState copyWith({
    IvStatus? status,
    List<Map<String, dynamic>>? datas,
    String? errorMessage,
  }) {
    return IvState(
      status: status ?? this.status,
      datas: datas ?? this.datas,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, datas, errorMessage];
}
