part of 'login_cubit.dart';


class LoginState extends Equatable {
  const LoginState({
    this.email = const FormInput("Email", "email", "Email"),
    this.password = const FormInput("Password", "password", "Password"),
    this.isValid = false,
    this.message = ''
  });

  final FormInput email;
  final FormInput password;
  final bool isValid;
  final String message;

  @override
  List<Object> get props => [email, password, isValid];

  LoginState copyWith({
    FormInput email,
    FormInput password,
    bool isValid,
    String message
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      message: message ?? this.message
    );
  }
}

class LoginLoadingState extends LoginState { }

class LoginFailedState extends LoginState { 
  final String message;

  LoginFailedState({this.message});

  @override
  List<Object> get props => [message];
}

class LoginSuccessState extends LoginState {
  @override
  List<Object> get props => [true];
 }
