import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../../core/di/injection.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/notification_service.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

@injectable
class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final StorageService _storageService;
  final NotificationService _notificationService;
  
  AuthController(this._authService, this._storageService, this._notificationService) : super(const AuthState());
  
  Future<void> register({
    required String email,
    required String name,
    required String surname,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true, errors: []);
    
    try {
      final request = RegisterRequest(
        email: email,
        name: name,
        surname: surname,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      
      final response = await _authService.register(request);
      
      // Save user credentials for auto-login
      await _storageService.saveUserEmail(email);
      await _storageService.saveUserPassword(password);
      
      state = state.copyWith(
        isLoading: false,
        user: response.user,
        token: response.token,
        isAuthenticated: false, // Don't set as authenticated yet
        isRegistrationSuccess: true, // Flag to redirect to login
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errors: e.errors,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errors: ['Beklenmeyen bir hata oluştu.'],
      );
    }
  }
  
  Future<void> login({
    required String email,
    required String password,
    String? oneSignalId,
  }) async {
    state = state.copyWith(isLoading: true, errors: []);
    
    try {
      // OneSignal ID'yi al veya mevcut olanı kullan
      String? finalOneSignalId = oneSignalId ?? _notificationService.playerId;
      
      // Eğer OneSignal ID yoksa, yeniden almaya çalış
      if (finalOneSignalId == null || finalOneSignalId.isEmpty) {
        finalOneSignalId = await _notificationService.refreshPlayerId();
      }
            
      final request = LoginRequest(
        email: email,
        password: password,
        oneSignalId: finalOneSignalId,
      );
      
      
      final response = await _authService.login(request);
      
      // OneSignal external user ID'yi ayarla
      await _notificationService.setExternalUserId(response.user.userId.toString());
      
      // Save auth data
      await _storageService.saveAuthToken(response.token);
      await _storageService.saveUserEmail(email);
      await _storageService.saveUserPassword(password);
      
      state = state.copyWith(
        isLoading: false,
        user: response.user,
        token: response.token,
        isAuthenticated: true,
        isRegistrationSuccess: false,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errors: e.errors,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errors: ['Beklenmeyen bir hata oluştu.'],
      );
    }
  }
  
  Future<void> checkAuthStatus() async {
    final token = _storageService.getAuthToken();
    if (token != null) {
      // TODO: Validate token with server
      state = state.copyWith(
        isAuthenticated: true,
        token: token,
      );
    }
  }
  
  Future<void> logout() async {
    // OneSignal external user ID'yi kaldır
    await _notificationService.removeExternalUserId();
    
    await _storageService.clearAuthData();
    state = const AuthState();
  }
  
  void clearErrors() {
    state = state.copyWith(errors: []);
  }
  
  void clearRegistrationSuccess() {
    state = state.copyWith(isRegistrationSuccess: false);
  }
}

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? token;
  final List<String> errors;
  final bool isRegistrationSuccess;
  
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.token,
    this.errors = const [],
    this.isRegistrationSuccess = false,
  });
  
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? token,
    List<String>? errors,
    bool? isRegistrationSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
      errors: errors ?? this.errors,
      isRegistrationSuccess: isRegistrationSuccess ?? this.isRegistrationSuccess,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return getIt<AuthController>();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return getIt<AuthService>();
});
