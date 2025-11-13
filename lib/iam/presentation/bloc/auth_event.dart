import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthSignInRequested extends AuthEvent {
  final String username;
  final String password;
  
  const AuthSignInRequested({required this.username, required this.password});
  @override
  List<Object?> get props => [username, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String username;
  final String password; 
  final String name;
  final String lastname;
  final String email;
  
  const AuthSignUpRequested({
    required this.username,
    required this.password,
    required this.name,
    required this.lastname, 
    required this.email,
  });
  @override
  List<Object?> get props => [username, password, name, lastname, email];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthCheckStatusRequested extends AuthEvent {}