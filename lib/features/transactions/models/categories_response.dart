import 'package:equatable/equatable.dart';
import 'categories_api_model.dart';

class CategoriesResponse extends Equatable {
  final bool success;
  final String message;
  final List<CategoriesApiModel> data;

  const CategoriesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => CategoriesApiModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [success, message, data];
}
