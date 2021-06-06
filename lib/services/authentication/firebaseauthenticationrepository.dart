import 'dart:async';

import 'package:dev_libraries/contracts/authentication/authenticationservice.dart';
import 'package:dev_libraries/models/authentication/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_core/firebase_core.dart';

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
  late firebase.FirebaseAuth _firebaseAuth;
  late GoogleSignIn _googleSignIn;

  initialize({
    firebase.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) async {
    await Firebase.initializeApp()
      .then((app) {
        _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance;
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();
      });
  }

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user => _firebaseAuth.authStateChanges().map((firebaseUser) =>
      firebaseUser == null ? User.empty : firebaseUser.toUser);

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpFailure] if an exception occurs.
  Future<void> signUp({
    @required String? email,
    @required String? password,
  }) async {
    assert(email != null && password != null);
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email ?? '',
        password: password ?? '',
      );
    } on Exception {
      throw SignUpFailure();
    }
  }

  @override
  Future<void> loginInWithProvider(AuthenticationProvider provider) async {
    switch (provider) {
      case AuthenticationProvider.Facebook:
      case AuthenticationProvider.Twitter:
      case AuthenticationProvider.Firebase:
        //firebase.FacebookAuthProvider.credential();
        break;
      case AuthenticationProvider.Google:
        try {
          final googleUser = await _googleSignIn.signIn();
          final googleAuth = await googleUser!.authentication;
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
  Future<void> logInWithEmailAndPassword(
    String email,
    String password) async {
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

  static getUser(String id) {
    return UserType.Anonymous;
  }
}

extension on firebase.User {
  User get toUser => User(id: uid, email: email, name: displayName);
}