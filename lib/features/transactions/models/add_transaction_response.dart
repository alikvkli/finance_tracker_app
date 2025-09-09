import 'package:equatable/equatable.dart';
import 'transaction_model.dart';

class AddTransactionResponse extends Equatable {
  final bool success;
  final String message;
  final TransactionModel data;

  const AddTransactionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AddTransactionResponse.fromJson(Map<String, dynamic> json) {
    return AddTransactionResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TransactionModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, message, data];
}
