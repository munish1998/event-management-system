import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/auth_bloc/auth_event.dart';
import 'bloc/auth_bloc/auth_state.dart';
import 'bloc/events_bloc/events_bloc.dart';
import 'bloc/events_bloc/events_event.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/events_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/events/presentation/screens/user_dashboard_screen.dart';
import 'ui/auth/login_screen.dart';
import 'ui/auth/splash_screen.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Initialization Note: $e');
  }

  await NotificationService().init();

  runApp(const EventManagementApp());
}

class EventManagementApp extends StatelessWidget {
  const EventManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<EventsRepository>(
          create: (_) => EventsRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider<EventsBloc>(
            create: (context) => EventsBloc(
              eventsRepository: context.read<EventsRepository>(),
            )..add(LoadEvents()),
          ),
        ],
        child: MaterialApp(
          title: 'allevents Organizer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          return const SplashScreenView();
        } else if (state is Authenticated) {
          if (state.user.isAdmin) {
            return AdminDashboardScreen(admin: state.user);
          } else {
            return UserDashboardScreen(user: state.user);
          }
        }
        return const LoginScreen();
      },
    );
  }
}
