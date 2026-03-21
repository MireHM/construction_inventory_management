import 'package:equatable/equatable.dart';
import '../../domain/entities/usuario_autenticado.dart';
import '../../../../core/errors/failures.dart';

// ── EVENTS ──────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// El usuario presiona el botón "Iniciar Sesión".
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// El usuario presiona "Cerrar Sesión".
class LogoutRequested extends AuthEvent {}

/// Al iniciar la app, verifica si hay sesión activa.
class CheckAuthStatus extends AuthEvent {}

// ── STATES ──────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UsuarioAutenticado usuario;
  const AuthAuthenticated(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final Failure failure;
  const AuthError(this.failure);

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}
