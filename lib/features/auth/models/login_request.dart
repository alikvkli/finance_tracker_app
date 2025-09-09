import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  final String email;
  final String password;
  final String? oneSignalId;
  
  const LoginRequest({
    required this.email,
    required this.password,
    this.oneSignalId,
  });
  
  Map<String, dynamic> toJson() {
    final json = {
      'email': email,
      'password': password,
    };
    
    
    if (oneSignalId != null && oneSignalId!.isNotEmpty) {
      json['onesignal_id'] = oneSignalId!;
    } else {
    }
    
    return json;
  }
  
  @override
  List<Object?> get props => [email, password, oneSignalId];
}
