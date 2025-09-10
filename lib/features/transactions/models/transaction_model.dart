import 'package:equatable/equatable.dart';
import 'category_model.dart';

class TransactionModel extends Equatable {
  final int id;
  final int userId;
  final int categoryId;
  final String type;
  final String amount;
  final String? description;
  final DateTime transactionDate;
  final String currency;
  final List<dynamic>? metadata;
  final bool isRecurring;
  final String? recurringType;
  final DateTime? recurringEndDate;
  final bool? isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryModel category;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.description,
    required this.transactionDate,
    required this.currency,
    this.metadata,
    required this.isRecurring,
    this.recurringType,
    this.recurringEndDate,
    this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    try {
      
      return TransactionModel(
        id: (json['id'] is int) ? json['id'] as int : int.parse(json['id'].toString()),
        userId: (json['user_id'] is int) ? json['user_id'] as int : int.parse(json['user_id'].toString()),
        categoryId: (json['category_id'] is int) ? json['category_id'] as int : int.parse(json['category_id'].toString()),
        type: json['type'] as String,
        amount: json['amount'] as String,
        description: json['description'] as String?,
        transactionDate: DateTime.parse(json['transaction_date'] as String),
        currency: json['currency'] as String,
        metadata: json['metadata'] as List<dynamic>?,
        isRecurring: json['is_recurring'] as bool,
        recurringType: json['recurring_type'] as String?,
        recurringEndDate: json['recurring_end_date'] != null
            ? DateTime.parse(json['recurring_end_date'] as String)
            : null,
        isActive: json['is_active'] as bool?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      );
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate.toIso8601String(),
      'currency': currency,
      'metadata': metadata,
      'is_recurring': isRecurring,
      'recurring_type': recurringType,
      'recurring_end_date': recurringEndDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category': category.toJson(),
    };
  }

  double get amountAsDouble => double.parse(amount);

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        type,
        amount,
        description,
        transactionDate,
        currency,
        metadata,
        isRecurring,
        recurringType,
        recurringEndDate,
        isActive,
        createdAt,
        updatedAt,
        category,
      ];
}
