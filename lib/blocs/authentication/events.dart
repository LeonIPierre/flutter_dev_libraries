import 'package:dev_libraries/models/authentication/user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationUserChanged extends AuthenticationEvent {
  const AuthenticationUserChanged(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

class AuthenticationLogoutRequested extends AuthenticationEvent {}