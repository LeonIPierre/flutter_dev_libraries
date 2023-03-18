part of 'authenticationbloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class CreateNewUserEvent extends AuthenticationEvent {}

class AuthenticationUserChangedEvent extends AuthenticationEvent {
  const AuthenticationUserChangedEvent(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

class AuthenticationLogoutRequestedEvent extends AuthenticationEvent {}