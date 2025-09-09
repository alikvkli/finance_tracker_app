import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int userId;
  final String name;
  final String surname;
  final String phone;
  final String email;
  final String oneSignalId;
  
  const UserModel({
    required this.userId,
    required this.name,
    required this.surname,
    required this.phone,
    required this.email,
    required this.oneSignalId,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int,
      name: json['name'] as String,
      surname: json['surname'] as String,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String,
      oneSignalId: json['onesignal_id'] as String? ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'surname': surname,
      'phone': phone,
      'email': email,
      'onesignal_id': oneSignalId,
    };
  }
  
  @override
  List<Object?> get props => [userId, name, surname, phone, email, oneSignalId];
}
