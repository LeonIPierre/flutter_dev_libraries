import 'package:dev_libraries/models/authentication/user.dart';
import 'package:flutter/widgets.dart';

/// Thrown if during the sign up process if a failure occurs.
class SignUpFailure implements Exception {}

/// Thrown during the login process if a failure occurs.
class LogInWithEmailAndPasswordFailure implements Exception {}

/// Thrown during the sign in with google process if a failure occurs.
class LogInWithGoogleFailure implements Exception {}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

enum AuthenticationProvider {
  Facebook,
  Google,
  Firebase,
  Twitter
}

abstract class AuthenticationService {
  Stream<User> get user;

  Future<void> initialize();

  Future<void> signUp({
    @required String email,
    @required String password,
  });

  Future<void> loginWithToken(String token);

  Future<void> loginInWithProvider(AuthenticationProvider provider);

  Future<void> logInWithEmailAndPassword(String email, String password);

  Future<void> logOut();
}