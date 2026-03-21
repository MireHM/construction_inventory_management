import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event_state.dart';
import '../../domain/repositories/auth_repository.dart';

/// BLoC de Autenticación.
/// Patrón BLoC: recibe Events → ejecuta lógica → emite States.
/// La UI solo interactúa con este BLoC, nunca directamente con el repositorio.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final haySession = await _authRepository.haySessionActiva();
    if (haySession) {
      final usuario = await _authRepository.obtenerSesionActual();
      if (usuario != null) {
        emit(AuthAuthenticated(usuario));
        return;
      }
    }
    emit(AuthUnauthenticated());
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.login(
      email: event.email.trim(),
      password: event.password,
    );
    if (result.failure != null) {
      emit(AuthError(result.failure!));
    } else {
      emit(AuthAuthenticated(result.usuario!));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
