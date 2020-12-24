import 'package:dev_libraries/models/authentication/user.dart';
import 'package:flutter/widgets.dart';

enum AuthenticationProvider {
  Facebook,
  Google,
  Firebase,
  Twitter
}

abstract class AuthenticationService {
  Stream<User> get user;

  Future<void> signUp({
    @required String email,
    @required String password,
  });

  Future<void> loginWithToken(String token);

  Future<void> loginInWithProvider(AuthenticationProvider provider);

  Future<void> logInWithEmailAndPassword({
    @required String email,
    @required String password,
  });

  Future<void> logOut();
}