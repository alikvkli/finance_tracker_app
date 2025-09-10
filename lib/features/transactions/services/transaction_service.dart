import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/constants/api_config.dart';
import '../../../shared/services/storage_service.dart';
import '../models/transactions_response.dart';
import '../models/categories_response.dart';
import '../models/add_transaction_request.dart';
import '../models/add_transaction_response.dart';

@injectable
class TransactionService {
  final Dio _dio;
  final StorageService _storageService;

  TransactionService(this._dio, this._storageService);

  Future<TransactionsResponse> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? search,
    int? categoryId,
  }) async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['start_date'] = _formatDate(startDate);
      }
      
      if (endDate != null) {
        queryParams['end_date'] = _formatDate(endDate);
      }
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }
      
      
      final response = await _dio.get(
        ApiConfig.transactionsEndpoint,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        
        if (data.containsKey('success')) {
        }
        
        if (data.containsKey('message')) {
        }
        
        if (data.containsKey('data')) {
          final transactions = data['data'] as List<dynamic>;          
        }
        
        if (data.containsKey('pagination')) {
          final pagination = data['pagination'] as Map<String, dynamic>;
        }
      }

      return TransactionsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as List<dynamic>?;
        throw Exception(errors?.first ?? 'Geçersiz veri');
      } else {
        throw Exception('İşlemler yüklenirken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }

  Future<CategoriesResponse> getCategories() async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final response = await _dio.get(
        ApiConfig.categoriesEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return CategoriesResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as List<dynamic>?;
        throw Exception(errors?.first ?? 'Geçersiz veri');
      } else {
        throw Exception('Kategoriler yüklenirken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }

  Future<AddTransactionResponse> addTransaction(AddTransactionRequest request) async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final response = await _dio.post(
        ApiConfig.transactionsEndpoint,
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return AddTransactionResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as List<dynamic>?;
        throw Exception(errors?.first ?? 'Geçersiz veri');
      } else {
        throw Exception('İşlem eklenirken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final response = await _dio.delete(
        '${ApiConfig.transactionsEndpoint}/$transactionId',
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
        throw Exception('İşlem bulunamadı');
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

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }
}