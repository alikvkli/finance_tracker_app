import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/statistics_models.dart';
import '../../../core/constants/api_config.dart';
import '../../../shared/services/storage_service.dart';

@injectable
class StatisticsService {
  final Dio _dio;
  final StorageService _storageService;

  StatisticsService(this._dio, this._storageService);

  /// Fetch transaction statistics with optional date range
  Future<StatisticsResponse> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final queryParameters = <String, dynamic>{};
      
      if (startDate != null) {
        queryParameters['start_date'] = _formatDate(startDate);
      }
      
      if (endDate != null) {
        queryParameters['end_date'] = _formatDate(endDate);
      }

      final response = await _dio.get(
        ApiConfig.transactionsStatisticsEndpoint,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return StatisticsResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('İstatistikler alınırken bir hata oluştu: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Erişim reddedildi');
      } else if (e.response?.statusCode == 404) {
        throw Exception('İstatistikler bulunamadı');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as List<dynamic>?;
        throw Exception(errors?.first ?? 'Geçersiz veri');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Sunucu hatası. Lütfen daha sonra tekrar deneyin.');
      } else {
        throw Exception('Ağ hatası: ${e.message}');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu: ${e.toString()}');
    }
  }

  /// Format date for API requests (same format as transaction service)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
