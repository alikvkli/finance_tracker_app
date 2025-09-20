import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/config_response.dart';
import '../services/config_service.dart';
import '../../core/di/injection.dart';

class ConfigState {
  final bool isLoading;
  final ConfigData? config;
  final String? error;

  const ConfigState({
    this.isLoading = false,
    this.config,
    this.error,
  });

  ConfigState copyWith({
    bool? isLoading,
    ConfigData? config,
    String? error,
  }) {
    return ConfigState(
      isLoading: isLoading ?? this.isLoading,
      config: config ?? this.config,
      error: error ?? this.error,
    );
  }
}

class ConfigController extends StateNotifier<ConfigState> {
  final ConfigService _configService;

  ConfigController(this._configService) : super(const ConfigState());

  Future<void> loadConfig() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _configService.getConfig();
      
      state = state.copyWith(
        isLoading: false,
        config: response.data,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void updateNotificationCount(int newCount) {
    if (state.config != null) {
      final updatedNotifications = NotificationConfig(unreadCount: newCount);
      final updatedConfig = ConfigData(
        notifications: updatedNotifications,
        admob: state.config!.admob,
        userPreferences: state.config!.userPreferences,
        timestamp: state.config!.timestamp,
      );
      
      state = state.copyWith(config: updatedConfig);
    }
  }

  void decrementNotificationCount() {
    final currentCount = state.config?.notifications.unreadCount ?? 0;
    if (currentCount > 0) {
      updateNotificationCount(currentCount - 1);
    }
  }

  void resetNotificationCount() {
    updateNotificationCount(0);
  }

  // Helper getters
  int get unreadNotificationCount => state.config?.notifications.unreadCount ?? 0;
  bool get shouldShowAds => state.config?.userPreferences.showAds ?? false;
  bool get isAdMobEnabled => state.config?.admob.enabled ?? false;
  AdMobConfig? get adMobConfig => state.config?.admob;
}

final configControllerProvider = StateNotifierProvider<ConfigController, ConfigState>((ref) {
  return ConfigController(getIt<ConfigService>());
});
