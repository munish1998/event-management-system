import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final email = event.email.trim();
    final password = event.password.trim();

    if (email.isEmpty || password.isEmpty) {
      emit(const AuthFailure(errorMessage: 'Please enter both email and password'));
      return;
    }

    try {
      final user = await _authRepository.signIn(email: email, password: password);
      emit(Authenticated(user: user));
    } catch (e) {
      try {
        final newUser = await _authRepository.signUp(
          email: email,
          password: password,
          name: email.split('@').first.toUpperCase(),
        );
        emit(Authenticated(user: newUser));
      } catch (signUpError) {
        emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final email = event.email.trim();
    final password = event.password.trim();
    final name = event.name.trim();

    if (email.isEmpty || password.isEmpty) {
      emit(const AuthFailure(errorMessage: 'Please enter both email and password'));
      return;
    }

    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
    } catch (_) {}
    emit(Unauthenticated());
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authRepository.getCurrentUserModel();
      if (user != null) {
        emit(Authenticated(user: user));
        return;
      }
    } catch (_) {}
    emit(Unauthenticated());
  }
}
