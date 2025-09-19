import 'package:equatable/equatable.dart';
import 'recurring_transaction_model.dart';

class RecurringSummary extends Equatable {
  final int totalCount;
  final int activeCount;
  final int inactiveCount;

  const RecurringSummary({
    required this.totalCount,
    required this.activeCount,
    required this.inactiveCount,
  });

  factory RecurringSummary.fromJson(Map<String, dynamic> json) {
    return RecurringSummary(
      totalCount: json['total_count'] as int,
      activeCount: json['active_count'] as int,
      inactiveCount: json['inactive_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'active_count': activeCount,
      'inactive_count': inactiveCount,
    };
  }

  @override
  List<Object?> get props => [totalCount, activeCount, inactiveCount];
}

class RecurringPaginationModel extends Equatable {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;
  final bool hasMorePages;

  const RecurringPaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
    required this.hasMorePages,
  });

  factory RecurringPaginationModel.fromJson(Map<String, dynamic> json) {
    return RecurringPaginationModel(
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

class RecurringTransactionsResponse extends Equatable {
  final bool success;
  final String message;
  final List<RecurringTransactionModel> data;
  final RecurringPaginationModel pagination;
  final RecurringSummary summary;

  const RecurringTransactionsResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
    required this.summary,
  });

  factory RecurringTransactionsResponse.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => RecurringTransactionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: RecurringPaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
      summary: RecurringSummary.fromJson(json['summary'] as Map<String, dynamic>),
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
