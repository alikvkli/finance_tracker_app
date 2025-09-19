import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/constants/api_config.dart';
import '../../../shared/services/storage_service.dart';
import '../models/recurring_transactions_response.dart';

@injectable
class RecurringTransactionService {
  final Dio _dio;
  final StorageService _storageService;

  RecurringTransactionService(this._dio, this._storageService);

  Future<RecurringTransactionsResponse> getRecurringTransactions({
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
        ApiConfig.recurringTransactionsEndpoint,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return RecurringTransactionsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ DioException - Status: ${e.response?.statusCode}');
      print('❌ DioException - Message: ${e.message}');
      print('❌ DioException - Response: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as List<dynamic>?;
        throw Exception(errors?.first ?? 'Geçersiz veri');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Tekrarlayan işlemler servisi bulunamadı');
      } else {
        throw Exception('Tekrarlayan işlemler yüklenirken bir hata oluştu: ${e.message}');
      }
    } catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }

  Future<void> toggleRecurringTransaction(int transactionId, bool isActive) async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      await _dio.put(
        '${ApiConfig.recurringTransactionsEndpoint}/$transactionId/toggle-active',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Tekrarlayan işlem bulunamadı');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as List<dynamic>?;
        throw Exception(errors?.first ?? 'Geçersiz veri');
      } else {
        throw Exception('İşlem güncellenirken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }

  Future<void> updateRecurringTransaction(int transactionId, Map<String, dynamic> updateData) async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      await _dio.put(
        '${ApiConfig.recurringTransactionsEndpoint}/$transactionId',
        data: updateData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Tekrarlayan işlem bulunamadı');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as List<dynamic>?;
        throw Exception(errors?.first ?? 'Geçersiz veri');
      } else {
        throw Exception('İşlem güncellenirken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }

  Future<void> deleteRecurringTransaction(int transactionId) async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      await _dio.delete(
        '${ApiConfig.recurringTransactionsEndpoint}/$transactionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Tekrarlayan işlem bulunamadı');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as List<dynamic>?;
        throw Exception(errors?.first ?? 'Geçersiz veri');
      } else {
        throw Exception('İşlem silinirken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }
}
