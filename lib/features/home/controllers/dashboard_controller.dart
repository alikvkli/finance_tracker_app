import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/services/transaction_service.dart';
import '../../../core/di/injection.dart';

class DashboardState extends Equatable {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final DateTime currentMonth;

  const DashboardState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.balance = 0.0,
    required this.currentMonth,
  });

  DashboardState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
    double? totalIncome,
    double? totalExpense,
    double? balance,
    DateTime? currentMonth,
  }) {
    return DashboardState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      currentMonth: currentMonth ?? this.currentMonth,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        isLoading,
        error,
        totalIncome,
        totalExpense,
        balance,
        currentMonth,
      ];
}

class DashboardController extends StateNotifier<DashboardState> {
  final TransactionService _transactionService;

  DashboardController(this._transactionService)
      : super(DashboardState(currentMonth: DateTime.now()));

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Dashboard için son 30 günün verilerini yükle
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final response = await _transactionService.getTransactions(
        startDate: startDate,
        endDate: endDate,
      );

      final income = response.data
          .where((t) => t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amountAsDouble);

      final expense = response.data
          .where((t) => t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amountAsDouble);

      state = state.copyWith(
        transactions: response.data,
        isLoading: false,
        totalIncome: income,
        totalExpense: expense,
        balance: income - expense,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      await _transactionService.deleteTransaction(transactionId);
      // Refresh dashboard data after deletion
      await refreshDashboard();
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  final transactionService = ref.watch(transactionServiceProvider);
  return DashboardController(transactionService);
});
