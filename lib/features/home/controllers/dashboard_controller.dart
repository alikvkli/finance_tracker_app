import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/models/add_transaction_request.dart';
import '../../transactions/services/transaction_service.dart';
import '../../../core/di/injection.dart';

class DashboardState extends Equatable {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final DateTime currentMonth;
  final int currentPage;
  final bool hasMorePages;

  const DashboardState({
    this.transactions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.balance = 0.0,
    required this.currentMonth,
    this.currentPage = 1,
    this.hasMorePages = false,
  });

  DashboardState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    double? totalIncome,
    double? totalExpense,
    double? balance,
    DateTime? currentMonth,
    int? currentPage,
    bool? hasMorePages,
  }) {
    return DashboardState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      currentMonth: currentMonth ?? this.currentMonth,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        isLoading,
        isLoadingMore,
        error,
        totalIncome,
        totalExpense,
        balance,
        currentMonth,
        currentPage,
        hasMorePages,
      ];
}

class DashboardController extends StateNotifier<DashboardState> {
  final TransactionService _transactionService;

  DashboardController(this._transactionService)
      : super(DashboardState(currentMonth: DateTime.now()));

  Future<void> loadDashboardData() async {
    state = state.copyWith(
      isLoading: true, 
      error: null,
      currentPage: 1,
      hasMorePages: false,
    );

    try {
      // Dashboard için son 30 günün verilerini yükle
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final response = await _transactionService.getTransactions(
        startDate: startDate,
        endDate: endDate,
        page: 1,
      );

      state = state.copyWith(
        transactions: response.data,
        isLoading: false,
        totalIncome: response.summary.totalIncome,
        totalExpense: response.summary.totalExpense,
        balance: response.summary.netAmount,
        currentPage: response.pagination.currentPage,
        hasMorePages: response.pagination.hasMorePages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadMoreDashboardData() async {
    if (state.isLoadingMore || !state.hasMorePages) return;
    
    state = state.copyWith(isLoadingMore: true);

    try {
      // Dashboard için son 30 günün verilerini yükle
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final response = await _transactionService.getTransactions(
        startDate: startDate,
        endDate: endDate,
        page: state.currentPage + 1,
      );

      // Mevcut transactions'lara yenilerini ekle
      final allTransactions = [...state.transactions, ...response.data];
      
      state = state.copyWith(
        transactions: allTransactions,
        isLoadingMore: false,
        currentPage: response.pagination.currentPage,
        hasMorePages: response.pagination.hasMorePages,
        // Summary'yi güncelleme - ilk sayfadan gelen summary geçerli
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
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

  Future<void> updateTransaction(int transactionId, AddTransactionRequest request) async {
    try {
      await _transactionService.updateTransaction(transactionId, request);
      // Refresh dashboard data after update
      await refreshDashboard();
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      throw e; // Hata durumunda exception'ı tekrar fırlat
    }
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
