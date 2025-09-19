import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../../../core/di/injection.dart';
import '../../../shared/services/storage_service.dart';

class NotificationState extends Equatable {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMorePages;
  final int totalNotifications;
  final int unreadCount;
  final int readCount;
  final Set<int> markingAsRead;
  final bool isMarkingAllAsRead;
  final Set<int> deletingNotifications;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePages = false,
    this.totalNotifications = 0,
    this.unreadCount = 0,
    this.readCount = 0,
    this.markingAsRead = const {},
    this.isMarkingAllAsRead = false,
    this.deletingNotifications = const {},
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMorePages,
    int? totalNotifications,
    int? unreadCount,
    int? readCount,
    Set<int>? markingAsRead,
    bool? isMarkingAllAsRead,
    Set<int>? deletingNotifications,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      totalNotifications: totalNotifications ?? this.totalNotifications,
      unreadCount: unreadCount ?? this.unreadCount,
      readCount: readCount ?? this.readCount,
      markingAsRead: markingAsRead ?? this.markingAsRead,
      isMarkingAllAsRead: isMarkingAllAsRead ?? this.isMarkingAllAsRead,
      deletingNotifications: deletingNotifications ?? this.deletingNotifications,
    );
  }

  @override
  List<Object?> get props => [
    notifications,
    isLoading,
    isLoadingMore,
    error,
    currentPage,
    hasMorePages,
    totalNotifications,
    unreadCount,
    readCount,
    markingAsRead,
    isMarkingAllAsRead,
    deletingNotifications,
  ];
}

class NotificationController extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;

  NotificationController(this._notificationService)
      : super(const NotificationState());

  Future<void> loadNotifications({bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: true, 
      error: null,
      currentPage: 1,
      hasMorePages: false,
    );

    try {
      final response = await _notificationService.getNotifications(page: 1);
      
      state = state.copyWith(
        notifications: response.data,
        isLoading: false,
        currentPage: response.pagination.currentPage,
        hasMorePages: response.pagination.hasMorePages,
        totalNotifications: response.summary.totalNotifications,
        unreadCount: response.summary.unreadCount,
        readCount: response.summary.readCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadMoreNotifications() async {
    if (state.isLoadingMore || !state.hasMorePages) return;
    
    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _notificationService.getNotifications(
        page: state.currentPage + 1,
      );
      
      // Mevcut notifications'lara yenilerini ekle
      final allNotifications = [...state.notifications, ...response.data];
      
      state = state.copyWith(
        notifications: allNotifications,
        isLoadingMore: false,
        currentPage: response.pagination.currentPage,
        hasMorePages: response.pagination.hasMorePages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> markAsRead(int notificationId) async {
    // Loading state'i başlat
    final currentMarkingSet = Set<int>.from(state.markingAsRead);
    currentMarkingSet.add(notificationId);
    
    state = state.copyWith(
      markingAsRead: currentMarkingSet,
      error: null,
    );

    try {
      final response = await _notificationService.markAsRead(notificationId);
      
      // API response'dan updated notification'ı parse et
      final data = response['data'] as Map<String, dynamic>?;
      final updatedNotificationData = data != null ? NotificationModel.fromJson(data) : null;
      
      // Local state'i güncelle
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          // API'dan gelen güncel data varsa onu kullan, yoksa local update yap
          if (updatedNotificationData != null) {
            return updatedNotificationData;
          } else {
            return NotificationModel(
              id: notification.id,
              userId: notification.userId,
              title: notification.title,
              message: notification.message,
              type: notification.type,
              data: notification.data,
              isRead: true,
              readAt: DateTime.now(),
              sentAt: notification.sentAt,
              createdAt: notification.createdAt,
              updatedAt: notification.updatedAt,
              autoFill: notification.autoFill,
            );
          }
        }
        return notification;
      }).toList();

      // Summary'yi güncelle
      final newUnreadCount = state.unreadCount > 0 ? state.unreadCount - 1 : 0;
      final newReadCount = state.readCount + 1;

      // Loading state'i bitir
      final finalMarkingSet = Set<int>.from(currentMarkingSet);
      finalMarkingSet.remove(notificationId);

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
        readCount: newReadCount,
        markingAsRead: finalMarkingSet,
      );

    } catch (e) {
      // Loading state'i bitir (hata durumunda)
      final finalMarkingSet = Set<int>.from(currentMarkingSet);
      finalMarkingSet.remove(notificationId);
      
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        markingAsRead: finalMarkingSet,
      );
    }
  }

  Future<void> markAllAsRead() async {
    // Loading state'i başlat
    state = state.copyWith(
      isMarkingAllAsRead: true,
      error: null,
    );

    try {
      final response = await _notificationService.markAllAsRead();
      
      // API response'dan gelen değerleri kullan
      final data = response['data'] as Map<String, dynamic>?;
      final updatedCount = data?['updated_count'] as int? ?? 0;
      final newUnreadCount = data?['unread_count'] as int? ?? 0;
      
      // Tüm notifications'ları read olarak işaretle
      final updatedNotifications = state.notifications.map((notification) {
        return NotificationModel(
          id: notification.id,
          userId: notification.userId,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          data: notification.data,
          isRead: true,
          readAt: DateTime.now(),
          sentAt: notification.sentAt,
          createdAt: notification.createdAt,
          updatedAt: notification.updatedAt,
          autoFill: notification.autoFill,
        );
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
        readCount: state.totalNotifications - newUnreadCount,
        isMarkingAllAsRead: false,
      );

    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        isMarkingAllAsRead: false,
      );
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    // Loading state'i başlat
    final currentDeletingSet = Set<int>.from(state.deletingNotifications);
    currentDeletingSet.add(notificationId);
    
    state = state.copyWith(
      deletingNotifications: currentDeletingSet,
      error: null,
    );

    try {
      final response = await _notificationService.deleteNotification(notificationId);
      
      // Notification'ı listeden kaldır
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();
      
      // Silinen notification unread ise count'u güncelle
      final deletedNotification = state.notifications
          .firstWhere((n) => n.id == notificationId);
      
      final newUnreadCount = deletedNotification.isRead 
          ? state.unreadCount 
          : (state.unreadCount > 0 ? state.unreadCount - 1 : 0);
      
      final newReadCount = deletedNotification.isRead
          ? (state.readCount > 0 ? state.readCount - 1 : 0)
          : state.readCount;
      
      final newTotalCount = state.totalNotifications > 0 
          ? state.totalNotifications - 1 
          : 0;

      // Loading state'i bitir
      final finalDeletingSet = Set<int>.from(currentDeletingSet);
      finalDeletingSet.remove(notificationId);

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
        readCount: newReadCount,
        totalNotifications: newTotalCount,
        deletingNotifications: finalDeletingSet,
      );

    } catch (e) {
      // Loading state'i bitir (hata durumunda)
      final finalDeletingSet = Set<int>.from(currentDeletingSet);
      finalDeletingSet.remove(notificationId);
      
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        deletingNotifications: finalDeletingSet,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refreshNotifications() async {
    await loadNotifications(isRefresh: true);
  }
}


final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
      final notificationService = NotificationService(getIt<Dio>(), StorageService(getIt<SharedPreferences>()));
      return NotificationController(notificationService);
    });
