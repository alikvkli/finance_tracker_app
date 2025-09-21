import 'package:dio/dio.dart';
import '../../../core/constants/api_config.dart';
import '../../../shared/services/storage_service.dart';
import '../models/upcoming_reminder_model.dart';

class UpcomingRemindersService {
  final Dio _dio;
  final StorageService _storageService;

  UpcomingRemindersService(this._dio, this._storageService);

  Future<List<UpcomingReminderModel>> getUpcomingReminders() async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/recurring-transactions/upcoming-reminders',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        if (responseData['success'] == true) {
          final data = responseData['data'] as List<dynamic>;
          
          return data
              .map((item) => UpcomingReminderModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          final errorMessage = responseData['message'] ?? 'Yaklaşan hatırlatmalar alınırken bir hata oluştu';
          throw Exception(errorMessage);
        }
      } else {
        throw Exception('Yaklaşan hatırlatmalar alınırken bir hata oluştu: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Bu işlem için yetkiniz bulunmamaktadır.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Yaklaşan hatırlatma bulunamadı.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Sunucu hatası. Lütfen daha sonra tekrar deneyin.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Bağlantı zaman aşımı. İnternet bağlantınızı kontrol edin.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('İnternet bağlantısı bulunamadı. Lütfen bağlantınızı kontrol edin.');
      } else {
        throw Exception('Yaklaşan hatırlatmalar alınırken bir hata oluştu: ${e.message}');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }
}
