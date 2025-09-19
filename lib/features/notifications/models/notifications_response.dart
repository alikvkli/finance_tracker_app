import 'package:equatable/equatable.dart';
import 'notification_model.dart';

class NotificationsResponse extends Equatable {
  final bool success;
  final String message;
  final List<NotificationModel> data;
  final NotificationPagination pagination;
  final NotificationSummary summary;

  const NotificationsResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
    required this.summary,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: NotificationPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {}
      ),
      summary: NotificationSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {}
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((notification) => notification.toJson()).toList(),
      'pagination': pagination.toJson(),
      'summary': summary.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, message, data, pagination, summary];
}

class NotificationPagination extends Equatable {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;
  final bool hasMorePages;

  const NotificationPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
    required this.hasMorePages,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      from: json['from'] as int? ?? 0,
      to: json['to'] as int? ?? 0,
      hasMorePages: json['has_more_pages'] as bool? ?? false,
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
  List<Object?> get props => [currentPage, lastPage, perPage, total, from, to, hasMorePages];
}

class NotificationSummary extends Equatable {
  final int totalNotifications;
  final int unreadCount;
  final int readCount;

  const NotificationSummary({
    required this.totalNotifications,
    required this.unreadCount,
    required this.readCount,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      totalNotifications: json['total_notifications'] as int? ?? 0,
      unreadCount: json['unread_count'] as int? ?? 0,
      readCount: json['read_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_notifications': totalNotifications,
      'unread_count': unreadCount,
      'read_count': readCount,
    };
  }

  @override
  List<Object?> get props => [totalNotifications, unreadCount, readCount];
}
