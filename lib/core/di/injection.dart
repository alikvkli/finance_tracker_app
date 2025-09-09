import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'injection.config.dart';
import '../constants/api_config.dart';
import '../../shared/services/storage_service.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/transactions/services/transaction_service.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Register Dio
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
    headers: ApiConfig.defaultHeaders,
  ));
  getIt.registerSingleton<Dio>(dio);
  
  // Initialize injectable dependencies
  getIt.init();
}

// Riverpod providers for dependency injection
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(getIt<SharedPreferences>());
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(getIt<Dio>());
});

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(getIt<Dio>(), ref.watch(storageServiceProvider));
});
