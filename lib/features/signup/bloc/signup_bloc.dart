import 'package:bloc/bloc.dart';
import 'package:loomflow/features/signup/bloc/signup_event.dart';
import 'package:loomflow/features/signup/bloc/signup_state.dart';
import 'package:loomflow/features/signup/repo/signup_repository.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupRepository repository;

  SignupBloc({required this.repository}) : super(const SignupState()) {
    on<SignupButtonPressed>(_onSignup);
  }

  Future<void> _onSignup(
    SignupButtonPressed event,
    Emitter<SignupState> emit,
  ) async {
    emit(state.copyWith(status: SignupStatus.loading, errorMessage: null));

    try {
      await repository.signup(
        event.email.trim(),
        event.password.trim(),
        event.name,
        event.role,
      );

      emit(state.copyWith(status: SignupStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: SignupStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
