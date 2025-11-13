import 'package:equatable/equatable.dart';
import '../../data/models/enums.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileCreateRequested extends ProfileEvent {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final Position position;
  final Department department;

  const ProfileCreateRequested({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    required this.position,
    required this.department,
  });

  @override
  List<Object?> get props => [
    userId, firstName, lastName, email, avatarUrl, position, department
  ];
}

class ProfileLoadRequested extends ProfileEvent {
  final String profileId;

  const ProfileLoadRequested(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

class ProfileLoadByUserRequested extends ProfileEvent {
  final String userId;

  const ProfileLoadByUserRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ProfileUpdateRequested extends ProfileEvent {
  final String profileId;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final Position position;
  final Department department;

  const ProfileUpdateRequested({
    required this.profileId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    required this.position,
    required this.department,
  });

  @override
  List<Object?> get props => [
    profileId, firstName, lastName, email, avatarUrl, position, department
  ];
}

class AllProfilesLoadRequested extends ProfileEvent {}