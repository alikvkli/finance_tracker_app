import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/constants/api_config.dart';
import '../../../shared/services/storage_service.dart';
import '../models/notifications_response.dart';

@injectable
class NotificationService {
  final Dio _dio;
  final StorageService _storageService;

  NotificationService(this._dio, this._storageService);

  Future<NotificationsResponse> getNotifications({
    int page = 1,
  }) async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final queryParams = <String, dynamic>{
        'page': page,
      };

      final response = await _dio.get(
        ApiConfig.notificationsEndpoint,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return NotificationsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as List<dynamic>?;
        throw Exception(errors?.first ?? 'Geçersiz veri');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Bildirimler servisi bulunamadı');
      } else {
        throw Exception('Bildirimler yüklenirken bir hata oluştu: ${e.message}');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }

  Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final response = await _dio.put(
        '${ApiConfig.notificationsEndpoint}/$notificationId/read',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Bildirim bulunamadı');
      } else {
        throw Exception('Bildirim okundu olarak işaretlenirken bir hata oluştu: ${e.response?.statusCode}');
      }
    } catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final response = await _dio.put(
        '${ApiConfig.notificationsEndpoint}/mark-all-read',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else {
        throw Exception('Bildirimler okundu olarak işaretlenirken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }

  Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final response = await _dio.delete(
        '${ApiConfig.notificationsEndpoint}/$notificationId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Bildirim bulunamadı');
      } else {
        throw Exception('Bildirim silinirken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }
}
