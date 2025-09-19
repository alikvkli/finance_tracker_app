import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/api_config.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

@singleton
class AuthService {
  final Dio _dio;
  
  AuthService(this._dio);
  
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiConfig.registerEndpoint,
        data: request.toJson(),
      );
      
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Validation errors
        final errorResponse = AuthErrorResponse.fromJson(
          e.response?.data as Map<String, dynamic>,
        );
        throw AuthException(errorResponse.errors);
      } else {
        throw AuthException(['Bir hata oluştu. Lütfen tekrar deneyin.']);
      }
    } catch (e) {
      throw AuthException(['Bir hata oluştu. Lütfen tekrar deneyin.']);
    }
  }
  
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: request.toJson(),
      );
      
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Validation errors
        final errorResponse = AuthErrorResponse.fromJson(
          e.response?.data as Map<String, dynamic>,
        );
        throw AuthException(errorResponse.errors);
      } else {
        throw AuthException(['Bir hata oluştu. Lütfen tekrar deneyin.']);
      }
    } catch (e) {
      throw AuthException(['Bir hata oluştu. Lütfen tekrar deneyin.']);
    }
  }

  Future<Map<String, dynamic>> deleteAccount(String password, String token) async {
    try {
      final response = await _dio.delete(
        ApiConfig.deleteAccountEndpoint,
        data: {
          'password': password,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Validation errors (wrong password)
        final errors = e.response?.data['errors'] as List<dynamic>?;
        throw AuthException(errors?.cast<String>() ?? ['Şifre doğrulama hatası']);
      } else if (e.response?.statusCode == 401) {
        throw AuthException(['Oturum süresi dolmuş. Lütfen tekrar giriş yapın.']);
      } else {
        throw AuthException(['Hesap silinirken bir hata oluştu']);
      }
    } catch (e) {
      throw AuthException(['Beklenmeyen bir hata oluştu']);
    }
  }
}

class AuthException implements Exception {
  final List<String> errors;
  
  AuthException(this.errors);
  
  @override
  String toString() => errors.join('\n');
}
