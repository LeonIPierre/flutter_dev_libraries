import 'dart:async';
import 'dart:convert';

import 'package:dev_libraries/models/authentication/authenticationservice.dart';
import 'package:dev_libraries/models/authentication/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:http/http.dart' as http;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

/// Thrown if during the sign up process if a failure occurs.
class SignUpFailure implements Exception {}

/// Thrown during the login process if a failure occurs.
class LogInWithEmailAndPasswordFailure implements Exception {}

/// Thrown during the sign in with google process if a failure occurs.
class LogInWithGoogleFailure implements Exception {}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class FirebaseAuthenticationRepository extends AuthenticationService {
  final firebase.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final String _apiUrl;

  /// {@macro authentication_repository}
  FirebaseAuthenticationRepository({
    String apiUrl,
    firebase.FirebaseAuth firebaseAuth,
    GoogleSignIn googleSignIn,
  })  : _apiUrl = apiUrl,
        _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user => _firebaseAuth.authStateChanges().map((firebaseUser) =>
      firebaseUser == null ? User.empty : firebaseUser.toUser);

  @override
  Future<void> createUser() => http.get(_apiUrl)
      .then((response) => User.fromJson(json.decode(response.body)))
      .then((user) => loginWithToken(user.accesToken));

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpFailure] if an exception occurs.
  Future<void> signUp({
    @required String email,
    @required String password,
  }) async {
    assert(email != null && password != null);
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception {
      throw SignUpFailure();
    }
  }

  @override
  Future<void> loginInWithProvider(AuthenticationProvider provider) async {
    switch (provider) {
      case AuthenticationProvider.Facebook:
        // TODO: Handle this case.
        break;
      case AuthenticationProvider.Firebase:
        // TODO: Handle this case.
        break;
      case AuthenticationProvider.Twitter:
        // TODO: Handle this case.
        break;
      case AuthenticationProvider.Google:
        try {
          final googleUser = await _googleSignIn.signIn();
          final googleAuth = await googleUser.authentication;
          final credential = firebase.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await _firebaseAuth.signInWithCredential(credential);
        } on Exception {
          throw LogInWithGoogleFailure();
        }
        break;
    }
  }

  @override
  Future<void> loginWithToken(String token) async =>
    _firebaseAuth.signInWithCustomToken(token)
      .catchError((error)
      {
        switch(error.code)
        {
          case 'custom-token-mismatch':
          case 'invalid-custom-token':
            break;
        }
      });
  

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    assert(email != null && password != null);
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception {
      throw LogInWithEmailAndPasswordFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } on Exception {
      throw LogOutFailure();
    }
  }
}

extension on firebase.User {
  User get toUser => User(id: uid, email: email, name: displayName, 
    type: UserType.Anonymous);
}
