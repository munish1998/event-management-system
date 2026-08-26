import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/model/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    final email = event.email.trim();
    if (email.isEmpty) {
      emit(const AuthFailure(errorMessage: 'Please enter a valid email address'));
      return;
    }

    final role = UserModel.determineRoleFromEmail(email);
    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
      role: role,
    );

    emit(Authenticated(user: user));
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) {
    emit(Unauthenticated());
  }

  void _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) {
    // Default to unauthenticated on app launch
    emit(Unauthenticated());
  }
}
