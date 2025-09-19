import 'package:equatable/equatable.dart';
import '../../transactions/models/categories_api_model.dart';

class NotificationModel extends Equatable {
  final int id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? sentAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final NotificationAutoFill? autoFill;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.isRead,
    this.readAt,
    this.sentAt,
    this.createdAt,
    this.updatedAt,
    this.autoFill,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null 
          ? DateTime.tryParse(json['read_at'] as String)
          : null,
      sentAt: json['sent_at'] != null 
          ? DateTime.tryParse(json['sent_at'] as String)
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      autoFill: json['auto_fill'] != null 
          ? NotificationAutoFill.fromJson(json['auto_fill'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'data': data,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'auto_fill': autoFill?.toJson(),
    };
  }

  bool get isTransactionReminder => type == 'transaction';
  bool get isSystemNotification => type == 'system';

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    message,
    type,
    data,
    isRead,
    readAt,
    sentAt,
    createdAt,
    updatedAt,
    autoFill,
  ];
}

class NotificationAutoFill extends Equatable {
  final int? recurringTransactionId;
  final String categoryId;
  final double amount;
  final String description;
  final String type;
  final String currency;
  final String transactionDate;
  final bool isRecurring;
  final String? recurringType;
  final String? recurringEndDate;
  final CategoriesApiModel category;

  const NotificationAutoFill({
    this.recurringTransactionId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.type,
    required this.currency,
    required this.transactionDate,
    required this.isRecurring,
    this.recurringType,
    this.recurringEndDate,
    required this.category,
  });

  factory NotificationAutoFill.fromJson(Map<String, dynamic> json) {
    return NotificationAutoFill(
      recurringTransactionId: json['recurring_transaction_id'] as int?,
      categoryId: json['category_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'expense',
      currency: json['currency'] as String? ?? 'TRY',
      transactionDate: json['transaction_date'] as String? ?? DateTime.now().toIso8601String(),
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringType: json['recurring_type'] as String?,
      recurringEndDate: json['recurring_end_date'] as String?,
      category: CategoriesApiModel.fromJson(json['category'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recurring_transaction_id': recurringTransactionId,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'type': type,
      'currency': currency,
      'transaction_date': transactionDate,
      'is_recurring': isRecurring,
      'recurring_type': recurringType,
      'recurring_end_date': recurringEndDate,
      'category': category.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    recurringTransactionId,
    categoryId,
    amount,
    description,
    type,
    currency,
    transactionDate,
    isRecurring,
    recurringType,
    recurringEndDate,
    category,
  ];
}
