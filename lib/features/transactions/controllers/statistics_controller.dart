import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/statistics_models.dart';
import '../services/statistics_service.dart';
import '../../../core/di/injection.dart';

/// Controller for managing transaction statistics state
class StatisticsController extends StateNotifier<StatisticsState> {
  final StatisticsService _statisticsService;

  StatisticsController(this._statisticsService) : super(const StatisticsState());

  /// Load statistics for the given date range
  Future<void> loadStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Auto-set end date to today if not provided
    final actualEndDate = endDate ?? DateTime.now();
    final hasFilter = startDate != null || endDate != null;
    
    state = state.copyWith(
      isLoading: true, 
      error: null,
      isFiltered: hasFilter,
      currentStartDate: startDate,
      currentEndDate: actualEndDate,
    );

    try {
      final response = await _statisticsService.getStatistics(
        startDate: startDate,
        endDate: actualEndDate,
      );

      if (response.success) {
        final isEmpty = _isStatisticsEmpty(response.data);
        state = state.copyWith(
          isLoading: false,
          statistics: response.data,
          error: null,
          isEmpty: isEmpty,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message,
          isEmpty: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isEmpty: false,
      );
    }
  }

  /// Refresh statistics with current date range
  Future<void> refreshStatistics() async {
    await loadStatistics(
      startDate: state.currentStartDate,
      endDate: state.currentEndDate,
    );
  }

  /// Update date range and reload statistics
  Future<void> updateDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(
      currentStartDate: startDate,
      currentEndDate: endDate,
    );

    await loadStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Clear statistics and reset state
  void clearStatistics() {
    state = const StatisticsState();
  }

  /// Clear filter and reload all statistics
  Future<void> clearFilter() async {
    await loadStatistics(); // Load without date filters
  }

  /// Check if statistics data is empty
  bool _isStatisticsEmpty(StatisticsData data) {
    return data.categoryStats.isEmpty && 
           data.dailyStats.isEmpty &&
           data.summary.transactionCount == 0;
  }
}

/// State for statistics controller
class StatisticsState {
  final bool isLoading;
  final StatisticsData? statistics;
  final String? error;
  final DateTime? currentStartDate;
  final DateTime? currentEndDate;
  final bool isFiltered;
  final bool isEmpty;

  const StatisticsState({
    this.isLoading = false,
    this.statistics,
    this.error,
    this.currentStartDate,
    this.currentEndDate,
    this.isFiltered = false,
    this.isEmpty = false,
  });

  StatisticsState copyWith({
    bool? isLoading,
    StatisticsData? statistics,
    String? error,
    DateTime? currentStartDate,
    DateTime? currentEndDate,
    bool? isFiltered,
    bool? isEmpty,
  }) {
    return StatisticsState(
      isLoading: isLoading ?? this.isLoading,
      statistics: statistics ?? this.statistics,
      error: error,
      currentStartDate: currentStartDate ?? this.currentStartDate,
      currentEndDate: currentEndDate ?? this.currentEndDate,
      isFiltered: isFiltered ?? this.isFiltered,
      isEmpty: isEmpty ?? this.isEmpty,
    );
  }

  /// Get income categories from statistics
  List<CategoryStats> get incomeCategories {
    return statistics?.categoryStats
        .where((category) => category.type == 'income')
        .toList() ?? [];
  }

  /// Get expense categories from statistics
  List<CategoryStats> get expenseCategories {
    return statistics?.categoryStats
        .where((category) => category.type == 'expense')
        .toList() ?? [];
  }

  /// Get daily income data for charts
  List<DailyStats> get dailyIncomeData {
    return statistics?.dailyStats
        .where((daily) => daily.type == 'income')
        .toList() ?? [];
  }

  /// Get daily expense data for charts
  List<DailyStats> get dailyExpenseData {
    return statistics?.dailyStats
        .where((daily) => daily.type == 'expense')
        .toList() ?? [];
  }
}

/// Provider for statistics controller
final statisticsControllerProvider = StateNotifierProvider<StatisticsController, StatisticsState>((ref) {
  return StatisticsController(getIt<StatisticsService>());
});

/// Provider for statistics service
final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return getIt<StatisticsService>();
});
