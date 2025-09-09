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
}

class AuthException implements Exception {
  final List<String> errors;
  
  AuthException(this.errors);
  
  @override
  String toString() => errors.join('\n');
}
