// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:finance_tracker_app/features/auth/controllers/auth_controller.dart'
    as _i170;
import 'package:finance_tracker_app/features/auth/services/auth_service.dart'
    as _i924;
import 'package:finance_tracker_app/features/notifications/services/notification_service.dart'
    as _i971;
import 'package:finance_tracker_app/features/onboarding/controllers/onboarding_controller.dart'
    as _i552;
import 'package:finance_tracker_app/features/transactions/services/recurring_transaction_service.dart'
    as _i956;
import 'package:finance_tracker_app/features/transactions/services/statistics_service.dart'
    as _i496;
import 'package:finance_tracker_app/features/transactions/services/transaction_service.dart'
    as _i6;
import 'package:finance_tracker_app/shared/services/admob_service.dart'
    as _i512;
import 'package:finance_tracker_app/shared/services/config_service.dart'
    as _i174;
import 'package:finance_tracker_app/shared/services/notification_service.dart'
    as _i992;
import 'package:finance_tracker_app/shared/services/storage_service.dart'
    as _i329;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i512.AdMobService>(() => _i512.AdMobService());
    gh.singleton<_i992.NotificationService>(() => _i992.NotificationService());
    gh.singleton<_i329.StorageService>(
        () => _i329.StorageService(gh<_i460.SharedPreferences>()));
    gh.singleton<_i924.AuthService>(() => _i924.AuthService(gh<_i361.Dio>()));
    gh.factory<_i6.TransactionService>(() => _i6.TransactionService(
          gh<_i361.Dio>(),
          gh<_i329.StorageService>(),
        ));
    gh.factory<_i956.RecurringTransactionService>(
        () => _i956.RecurringTransactionService(
              gh<_i361.Dio>(),
              gh<_i329.StorageService>(),
            ));
    gh.factory<_i496.StatisticsService>(() => _i496.StatisticsService(
          gh<_i361.Dio>(),
          gh<_i329.StorageService>(),
        ));
    gh.factory<_i971.NotificationService>(() => _i971.NotificationService(
          gh<_i361.Dio>(),
          gh<_i329.StorageService>(),
        ));
    gh.factory<_i174.ConfigService>(() => _i174.ConfigService(
          gh<_i361.Dio>(),
          gh<_i329.StorageService>(),
        ));
    gh.factory<_i552.OnboardingController>(
        () => _i552.OnboardingController(gh<_i329.StorageService>()));
    gh.factory<_i170.AuthController>(() => _i170.AuthController(
          gh<_i924.AuthService>(),
          gh<_i329.StorageService>(),
          gh<_i992.NotificationService>(),
        ));
    return this;
  }
}
