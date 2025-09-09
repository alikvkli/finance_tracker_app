import 'package:equatable/equatable.dart';

class RegisterRequest extends Equatable {
  final String email;
  final String name;
  final String surname;
  final String password;
  final String passwordConfirmation;
  
  const RegisterRequest({
    required this.email,
    required this.name,
    required this.surname,
    required this.password,
    required this.passwordConfirmation,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'surname': surname,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
  
  @override
  List<Object?> get props => [email, name, surname, password, passwordConfirmation];
}
