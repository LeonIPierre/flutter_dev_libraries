import 'dart:async';

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
  StreamSubscription<User> _userSubscription;
  
  AuthenticationBloc({
    @required AuthenticationService authenticationService,
  })  : assert(authenticationService != null),
        _authenticationService = authenticationService,
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
      yield await _authenticationService.createUser()
        .then((_) => AuthenticationState.unauthenticated());
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
