import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loomflow/core/auth/auth_notifier.dart';
import 'package:loomflow/core/common/splash_screen.dart';
import 'package:loomflow/core/utills/chat_utills.dart';
import 'package:loomflow/features/chat/bloc/chat_bloc.dart';
import 'package:loomflow/features/chat/bloc/chat_event.dart';
import 'package:loomflow/features/chat/repository/chat_repository.dart';
import 'package:loomflow/features/chat/view/chat_screen.dart';
import 'package:loomflow/features/dashboard/view/dashboard_screen.dart';
import 'package:loomflow/features/job/view/job_details_screen.dart';
import 'package:loomflow/features/job/view/job_screen.dart';
import 'package:loomflow/features/login/view/login_page.dart';
import 'package:loomflow/features/root_screen.dart';
import 'package:loomflow/features/settings/view/settings_screen.dart';
import 'package:loomflow/features/signup/view/signup_page.dart';
import 'package:loomflow/features/weawers/view/weavers_screen.dart';
import 'package:loomflow/models/job_model.dart';

class AppRouter {
  final AuthNotifier authNotifier;

  AppRouter(this.authNotifier);

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,

    routes: [
      // 🔹 AUTH SCREENS
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (c, s) => const SignupScreen()),

      // 🔥 MAIN APP WITH BOTTOM NAV
      ShellRoute(
        builder: (context, state, child) {
          return HomeScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (c, s) => const DashboardScreen(),
          ),

          GoRoute(path: '/jobs', builder: (c, s) => const JobListScreen()),

          GoRoute(
            path: '/weavers',
            builder: (c, s) => const WeaverListScreen(),
          ),

          GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        ],
      ),

      // 🔹 FULL SCREEN (NO BOTTOM NAV)
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final job = state.extra as JobModel;

          final uid = FirebaseAuth.instance.currentUser!.uid;
          final chatId = getChatId(uid, job.id);

          return BlocProvider(
            create: (_) =>
                ChatBloc(repository: ChatRepository(FirebaseFirestore.instance))
                  ..add(LoadMessageEvent(chatId)),
            child: ChatScreen(chatId: chatId, weaverName: job.weaverName),
          );
        },
      ),

      GoRoute(
        path: '/job-details',
        name: 'jobDetails',
        builder: (context, state) {
          final job = state.extra as JobModel;
          return JobDetailScreen(initialJob: job);
        },
      ),
    ],

    redirect: (context, state) {
      final user = authNotifier.user;

      final isAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (user == null) {
        return isAuthPage ? null : '/login';
      }

      if (isAuthPage || state.matchedLocation == '/splash') {
        return '/dashboard';
      }

      return null;
    },
  );
}
