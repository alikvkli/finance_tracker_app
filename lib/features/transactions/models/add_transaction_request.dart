import 'package:equatable/equatable.dart';

class AddTransactionRequest extends Equatable {
  final int categoryId;
  final String type;
  final String amount;
  final String? description;
  final String transactionDate;
  final String currency;
  final String? metadata;
  final bool isRecurring;
  final String? recurringType;
  final String? recurringEndDate;

  const AddTransactionRequest({
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
  });

  Map<String, dynamic> toJson() {
    final json = {
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'transaction_date': transactionDate,
      'currency': currency,
      'is_recurring': isRecurring,
    };

    if (description != null && description!.isNotEmpty) {
      json['description'] = description!;
    }

    if (metadata != null && metadata!.isNotEmpty) {
      json['metadata'] = metadata!;
    }

    if (isRecurring && recurringType != null && recurringType!.isNotEmpty) {
      json['recurring_type'] = recurringType!;
    }

    if (isRecurring && recurringEndDate != null && recurringEndDate!.isNotEmpty) {
      json['recurring_end_date'] = recurringEndDate!;
    }

    return json;
  }

  @override
  List<Object?> get props => [
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
      ];
}
