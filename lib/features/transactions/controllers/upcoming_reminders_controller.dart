import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/upcoming_reminder_model.dart';
import '../services/upcoming_reminders_service.dart';
import '../../../core/di/injection.dart';
import '../../../shared/services/storage_service.dart';

class UpcomingRemindersState {
  final bool isLoading;
  final List<UpcomingReminderModel> reminders;
  final String? error;

  const UpcomingRemindersState({
    this.isLoading = false,
    this.reminders = const [],
    this.error,
  });

  UpcomingRemindersState copyWith({
    bool? isLoading,
    List<UpcomingReminderModel>? reminders,
    String? error,
  }) {
    return UpcomingRemindersState(
      isLoading: isLoading ?? this.isLoading,
      reminders: reminders ?? this.reminders,
      error: error,
    );
  }

  bool get hasError => error != null;
  bool get isEmpty => !isLoading && reminders.isEmpty;
}

class UpcomingRemindersController extends StateNotifier<UpcomingRemindersState> {
  final UpcomingRemindersService _upcomingRemindersService;

  UpcomingRemindersController(this._upcomingRemindersService) : super(const UpcomingRemindersState());

  Future<void> loadUpcomingReminders() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reminders = await _upcomingRemindersService.getUpcomingReminders();
      state = state.copyWith(
        isLoading: false,
        reminders: reminders,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> refreshUpcomingReminders() async {
    await loadUpcomingReminders();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final upcomingRemindersServiceProvider = Provider<UpcomingRemindersService>((ref) {
  return UpcomingRemindersService(getIt<Dio>(), getIt<StorageService>());
});

final upcomingRemindersControllerProvider = 
    StateNotifierProvider<UpcomingRemindersController, UpcomingRemindersState>((ref) {
  final service = ref.watch(upcomingRemindersServiceProvider);
  return UpcomingRemindersController(service);
});
