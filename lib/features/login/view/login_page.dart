import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loomflow/core/common/loading_screen.dart';
import 'package:loomflow/features/login/bloc/login_bloc.dart';
import 'package:loomflow/features/login/bloc/login_event.dart';
import 'package:loomflow/features/login/bloc/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController(text: 'test@gmail.com');
    TextEditingController password = TextEditingController(text: '123456');
    return SafeArea(
      child: Scaffold(
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              // context.go('/home');
            }
            if (state.status == LoginStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Something went wrong!'),
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  state.status == LoginStatus.loading
                      ? LoomLoadingWidget()
                      : ElevatedButton(
                          onPressed: () {
                            context.read<LoginBloc>().add(
                              LoginButtonPressed(
                                email: email.text,
                                password: password.text,
                              ),
                            );
                          },
                          child: Text('Login'),
                        ),

                  TextButton(
                    onPressed: () {
                      context.push('/signup');
                    },
                    child: Text("Create account"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
