import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loomflow/core/common/loading_screen.dart';
import 'package:loomflow/features/signup/bloc/signup_bloc.dart';
import 'package:loomflow/features/signup/bloc/signup_event.dart';
import 'package:loomflow/features/signup/bloc/signup_state.dart';
import 'package:loomflow/features/signup/repo/signup_repository.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final roleController = TextEditingController();

  List<String> roles = ['admin', 'weaver'];
  String? selectedRole;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: BlocProvider(
        create: (_) => SignupBloc(repository: SignupRepository()),
        child: BlocConsumer<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state.status == SignupStatus.success) {
              Navigator.pushReplacementNamed(context, '/login');
            }

            if (state.status == SignupStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? "Signup Failed")),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "User Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: passwordController,
                    obscureText: false,
                    decoration: const InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    hint: Text('Select Role'),
                    value: selectedRole,
                    items: roles.map((e) {
                      return DropdownMenuItem<String>(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  ),

                  state.status == SignupStatus.loading
                      ? const LoomLoadingWidget()
                      : ElevatedButton(
                          onPressed: () {
                            context.read<SignupBloc>().add(
                              SignupButtonPressed(
                                email: emailController.text,
                                password: passwordController.text,
                                name: nameController.text,
                                role: selectedRole!,
                              ),
                            );
                          },
                          child: const Text("Signup"),
                        ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      context.push('/login');
                    },
                    child: const Text("Already have account? Login"),
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
