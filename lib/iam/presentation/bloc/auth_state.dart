import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String username; 
  final String token;
  
  const AuthAuthenticated({
    required this.userId,
    required this.username,
    required this.token,
  });
  @override
  List<Object?> get props => [userId, username, token];
}

class AuthUnauthenticated extends AuthState {}

class AuthSignUpSuccess extends AuthState {
  final String message;
  
  const AuthSignUpSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}