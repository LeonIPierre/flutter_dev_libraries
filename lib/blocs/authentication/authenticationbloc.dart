import 'dart:async';

import 'package:dev_libraries/services/userservice.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:dev_libraries/models/authentication/authenticationservice.dart';
import 'package:dev_libraries/models/authentication/user.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

part 'events.dart';
part 'states.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationService _authenticationService;
  final UserService _userService;
  StreamSubscription<User> _userSubscription;
  
  AuthenticationBloc({
    @required AuthenticationService authenticationService,
    @required UserService userService
  })  : assert(authenticationService != null),
        assert(userService != null),
        _authenticationService = authenticationService,
        _userService = userService,
        super(const AuthenticationState.unknown()) {
  
    _userSubscription = _authenticationService.user.listen(
      (user) => add(AuthenticationUserChanged(user)),
    );
  }

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AuthenticationUserChanged) {
      yield _mapAuthenticationUserChangedToState(event);
    } 
    else if(event is CreateNewUserEvent) {
      yield await _userService.createUserAsync()
        .then((user) => _authenticationService
          .loginWithToken(user.accesToken)
          .then((value) => user))
        .then((user) => AuthenticationState.anonymous(user));
    }
    else if (event is AuthenticationLogoutRequested) {
      unawaited(_authenticationService.logOut());
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  AuthenticationState _mapAuthenticationUserChangedToState(
    AuthenticationUserChanged event,
  ) {
    return event.user != User.empty
        ? AuthenticationState.authenticated(event.user)
        : const AuthenticationState.unauthenticated();
  }
}
