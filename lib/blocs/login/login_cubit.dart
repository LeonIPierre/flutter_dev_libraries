import 'package:bloc/bloc.dart';
import 'package:dev_libraries/models/forminput.dart';
import 'package:dev_libraries/services/authentication/authenticationrepository.dart';
import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  static List<FormInput> inputs = [
    FormInput("Email", "email", "Email"),
    FormInput("Password", "password", "Password")
  ];

  final AuthenticationRepository _authenticationRepository;

  LoginCubit(this._authenticationRepository)
      : assert(_authenticationRepository != null),
        super(const LoginState());

  void emailChanged(String value) {
    var email = state.email.clone(value);
    var isValid = _validateInput(email);
    var message = isValid ? null : _getErrorMessage(state.email);

    emit(state.copyWith(
      email: email,
      //isValid: isValid && _validateInput(state.password),
      isValid: isValid,
      message: message
    ));
  }

  void passwordChanged(String value) {
    var password = state.password.clone(value);
    var isValid = _validateInput(password);
    var message = isValid ? null : _getErrorMessage(state.password);

    emit(state.copyWith(
      password: password,
      isValid: isValid,
      //isValid: isValid && _validateInput(state.email),
      message: message
    ));
  }

  Future<void> logInWithCredentials() async {
    if (!state.isValid) return;

    var email = state.email.value;
    var password = state.password.value;

    emit(LoginLoadingState());

    await _authenticationRepository.logInWithEmailAndPassword(
      email: email,
      password: password,
    )
    .then((_) => emit(LoginSuccessState()))
    .catchError((error) => emit(LoginFailedState(message: error.toString())));
  }

  Future<void> logInWithGoogle() async {
    await _authenticationRepository.logInWithGoogle()
    .then((_) => emit(LoginSuccessState()))
    .catchError((error) => emit(LoginFailedState(message: error.toString())));
  }

  bool _validateInput(FormInput input) {
    var isValid;

    switch (input.id) {
      case "Email":
        final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');

        return _emailRegExp.hasMatch(input.value);
      case "Password":
        final RegExp _passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
        return _passwordRegExp.hasMatch(input.value);

      default:
        isValid = input.value != null;
        break;
    }

    return isValid;
  }

  String _getErrorMessage(FormInput input) {
    switch (input.id) {
      case "Email":
        return "Please enter a valid email";
      case "Password":
        return "Please enter a valid password";

      default:
        return null;
    }
  }
}
