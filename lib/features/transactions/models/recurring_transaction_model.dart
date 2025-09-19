import 'package:equatable/equatable.dart';
import 'categories_api_model.dart';

class RecurringTransactionModel extends Equatable {
  final int id;
  final String userId;
  final String categoryId;
  final String type;
  final String amount;
  final String currency;
  final String? description;
  final String recurringType;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final dynamic metadata;
  final DateTime? lastReminderSent;
  final int reminderCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoriesApiModel category;

  const RecurringTransactionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.currency,
    this.description,
    required this.recurringType,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.metadata,
    this.lastReminderSent,
    required this.reminderCount,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      type: json['type'] as String,
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      description: json['description'] as String?,
      recurringType: json['recurring_type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      metadata: json['metadata'],
      lastReminderSent: json['last_reminder_sent'] != null 
          ? DateTime.parse(json['last_reminder_sent'] as String)
          : null,
      reminderCount: json['reminder_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: CategoriesApiModel.fromJson(json['category'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'description': description,
      'recurring_type': recurringType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'metadata': metadata,
      'last_reminder_sent': lastReminderSent?.toIso8601String(),
      'reminder_count': reminderCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category': category.toJson(),
    };
  }

  double get amountAsDouble {
    return double.tryParse(amount) ?? 0.0;
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  String get recurringTypeDisplayName {
    switch (recurringType) {
      case 'daily':
        return 'Günlük';
      case 'weekly':
        return 'Haftalık';
      case 'monthly':
        return 'Aylık';
      case 'yearly':
        return 'Yıllık';
      default:
        return recurringType;
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    categoryId,
    type,
    amount,
    currency,
    description,
    recurringType,
    startDate,
    endDate,
    isActive,
    metadata,
    lastReminderSent,
    reminderCount,
    createdAt,
    updatedAt,
    category,
  ];
}
