import 'package:equatable/equatable.dart';

import 'user_model.dart';

class AuthResponse extends Equatable {
  final UserModel user;
  final String token;
  
  const AuthResponse({
    required this.user,
    required this.token,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }
  
  @override
  List<Object?> get props => [user, token];
}

class AuthErrorResponse extends Equatable {
  final List<String> errors;
  
  const AuthErrorResponse({
    required this.errors,
  });
  
  factory AuthErrorResponse.fromJson(Map<String, dynamic> json) {
    return AuthErrorResponse(
      errors: (json['errors'] as List<dynamic>)
          .map((error) => error as String)
          .toList(),
    );
  }
  
  @override
  List<Object?> get props => [errors];
}
