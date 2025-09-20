import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/constants/api_config.dart';
import '../models/config_response.dart';
import 'storage_service.dart';

@injectable
class ConfigService {
  final Dio _dio;
  final StorageService _storageService;

  ConfigService(this._dio, this._storageService);

  Future<ConfigResponse> getConfig() async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final response = await _dio.get(
        ApiConfig.configEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ConfigResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as List<dynamic>?;
        throw Exception(errors?.first ?? 'Geçersiz veri');
      } else {
        throw Exception('Konfigürasyon yüklenirken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }
}
