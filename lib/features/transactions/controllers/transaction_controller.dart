import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../../../core/di/injection.dart';

class TransactionState extends Equatable {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final String? searchQuery;
  final int? selectedCategoryId;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    required this.selectedStartDate,
    required this.selectedEndDate,
    this.searchQuery,
    this.selectedCategoryId,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.balance = 0.0,
  });

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
    String? searchQuery,
    int? selectedCategoryId,
    double? totalIncome,
    double? totalExpense,
    double? balance,
    bool clearSearchQuery = false,
    bool clearSelectedCategoryId = false,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedStartDate: selectedStartDate ?? this.selectedStartDate,
      selectedEndDate: selectedEndDate ?? this.selectedEndDate,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      selectedCategoryId: clearSelectedCategoryId
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    isLoading,
    error,
    selectedStartDate,
    selectedEndDate,
    searchQuery,
    selectedCategoryId,
    totalIncome,
    totalExpense,
    balance,
  ];
}

class TransactionController extends StateNotifier<TransactionState> {
  final TransactionService _transactionService;

  TransactionController(this._transactionService)
    : super(
        TransactionState(
          selectedStartDate: _getFirstDayOfCurrentMonth(),
          selectedEndDate: _getLastDayOfCurrentMonth(),
        ),
      );

  static DateTime _getFirstDayOfCurrentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime _getLastDayOfCurrentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _transactionService.getTransactions(
        startDate: state.selectedStartDate,
        endDate: state.selectedEndDate,
        search: state.searchQuery,
        categoryId: state.selectedCategoryId,
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

  void updateDateRange(DateTime startDate, DateTime endDate) {
    state = state.copyWith(
      selectedStartDate: startDate,
      selectedEndDate: endDate,
    );
    loadTransactions();
  }

  void updateSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
    loadTransactions();
  }

  void updateCategoryFilter(int? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
    loadTransactions();
  }

  void toggleCategoryFilter(int categoryId) {
    // Eğer aynı kategori seçiliyse, filtreyi kaldır
    if (state.selectedCategoryId == categoryId) {
      state = state.copyWith(clearSelectedCategoryId: true);
    } else {
      // Farklı kategori seçiliyse, yeni kategoriyi uygula
      state = state.copyWith(selectedCategoryId: categoryId);
    }
    loadTransactions();
  }

  void clearFilters() {
    // Reset to current month
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);

    state = state.copyWith(
      clearSearchQuery: true,
      clearSelectedCategoryId: true,
      selectedStartDate: currentMonthStart,
      selectedEndDate: currentMonthEnd,
    );

    loadTransactions(); // API'ye yeni istek gönder
  }

  void clearCategoryFilter() {

    state = state.copyWith(clearSelectedCategoryId: true);

    loadTransactions(); // API'ye yeni istek gönder
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refreshTransactions() async {
    await loadTransactions();
  }

  Future<void> deleteTransaction(int transactionId) async {

    try {
      // API'den sil
      await _transactionService.deleteTransaction(transactionId);

      // UI'dan kaldır
      final updatedTransactions = state.transactions
          .where((transaction) => transaction.id != transactionId)
          .toList();

      // Totalleri yeniden hesapla
      final income = updatedTransactions
          .where((t) => t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amountAsDouble);

      final expense = updatedTransactions
          .where((t) => t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amountAsDouble);

      state = state.copyWith(
        transactions: updatedTransactions,
        totalIncome: income,
        totalExpense: expense,
        balance: income - expense,
      );

    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final transactionControllerProvider =
    StateNotifierProvider<TransactionController, TransactionState>((ref) {
      final transactionService = ref.watch(transactionServiceProvider);
      return TransactionController(transactionService);
    });
