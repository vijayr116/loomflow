import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignupButtonPressed extends SignupEvent {
  final String email;
  final String password;
  final String name;
  final String role;

  SignupButtonPressed({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
  @override
  List<Object?> get props => [email, password, name, role];
}
