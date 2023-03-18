import 'dart:async';

import 'package:dev_libraries/contracts/authentication/authenticationservice.dart';
import 'package:dev_libraries/contracts/authentication/userservice.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:dev_libraries/models/authentication/user.dart';

part 'events.dart';
part 'states.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationService _authenticationService;
  final UserService _userService;

  AuthenticationBloc(
      AuthenticationService authenticationService, UserService userService)
      : _authenticationService = authenticationService,
        _userService = userService,
        super(const AuthenticationState.unknown()) {

    on<AuthenticationUserChangedEvent>((event, emit) async {
      await emit.forEach(
        _authenticationService.user,
        onData: (User user) => _mapAuthenticationUserToState(user),
      );
    });

    on<CreateNewUserEvent>((event, emit) async {
      emit(await _userService
          .create()
          .then((user) => _authenticationService
              .loginWithToken(user.accesToken!)
              .then((_) => user))
          .then((user) => AuthenticationState.anonymous(user)));
    });

    on<AuthenticationLogoutRequestedEvent>((event, emit) {
      unawaited(_authenticationService.logOut());

      emit(LoggedOutState.unknown());
    });
  }

  AuthenticationState _mapAuthenticationUserToState(
    User user,
  ) =>
      user != User.empty
          ? AuthenticationState.authenticated(user)
          : const AuthenticationState.unauthenticated();
}
