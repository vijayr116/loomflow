import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loomflow/core/auth/auth_notifier.dart';
import 'package:loomflow/core/routes/app_router.dart';
import 'package:loomflow/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:loomflow/features/dashboard/repository/dashboard_repository.dart';
import 'package:loomflow/features/job/bloc/job_bloc.dart';
import 'package:loomflow/features/job/repo/job_repository.dart';
import 'package:loomflow/features/login/bloc/login_bloc.dart';
import 'package:loomflow/features/login/repository/login_repository.dart';
import 'package:loomflow/features/weawers/bloc/weaver_bloc.dart';
import 'package:loomflow/features/weawers/repository/weaver_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthNotifier authNotifier = AuthNotifier();

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(authNotifier);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => LoginRepository()),
        RepositoryProvider(create: (_) => JobRepository()),
        RepositoryProvider(create: (_) => WeaverRepository()),
        RepositoryProvider(create: (_) => DashboardRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                LoginBloc(repository: context.read<LoginRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                JobBloc(repository: context.read<JobRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                WeaverBloc(repository: context.read<WeaverRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                DashboardBloc(repository: context.read<DashboardRepository>()),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter.router,
        ),
      ),
    );
  }
}
