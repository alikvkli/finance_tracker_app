import 'package:equatable/equatable.dart';
import 'transaction_model.dart';

class TransactionSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final int totalTransactionCount;

  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.totalTransactionCount,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
      totalTransactionCount: json['total_transaction_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_amount': netAmount,
      'total_transaction_count': totalTransactionCount,
    };
  }

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    netAmount,
    totalTransactionCount,
  ];
}

class PaginationModel extends Equatable {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;
  final bool hasMorePages;

  const PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
    required this.hasMorePages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      from: json['from'] as int?,
      to: json['to'] as int?,
      hasMorePages: json['has_more_pages'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'from': from,
      'to': to,
      'has_more_pages': hasMorePages,
    };
  }

  @override
  List<Object?> get props => [
        currentPage,
        lastPage,
        perPage,
        total,
        from,
        to,
        hasMorePages,
      ];
}

class TransactionsResponse extends Equatable {
  final bool success;
  final String message;
  final List<TransactionModel> data;
  final PaginationModel pagination;
  final TransactionSummary summary;

  const TransactionsResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
    required this.summary,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
      summary: TransactionSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
      'summary': summary.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, message, data, pagination, summary];
}
