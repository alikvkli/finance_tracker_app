import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../models/transaction_model.dart';
import '../models/add_transaction_request.dart';
import '../services/transaction_service.dart';
import '../../../core/di/injection.dart';

class TransactionState extends Equatable {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final String? searchQuery;
  final int? selectedCategoryId;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int currentPage;
  final bool hasMorePages;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    required this.selectedStartDate,
    required this.selectedEndDate,
    this.searchQuery,
    this.selectedCategoryId,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.balance = 0.0,
    this.currentPage = 1,
    this.hasMorePages = false,
  });

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
    String? searchQuery,
    int? selectedCategoryId,
    double? totalIncome,
    double? totalExpense,
    double? balance,
    int? currentPage,
    bool? hasMorePages,
    bool clearSearchQuery = false,
    bool clearSelectedCategoryId = false,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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
    selectedStartDate,
    selectedEndDate,
    searchQuery,
    selectedCategoryId,
    totalIncome,
    totalExpense,
    balance,
    currentPage,
    hasMorePages,
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

  Future<void> loadTransactions({bool isRefresh = false}) async {
    print('🚀 Loading transactions with filters:');
    print('📅 Date range: ${state.selectedStartDate} to ${state.selectedEndDate}');
    print('🔍 Search: ${state.searchQuery}');
    print('🏷️ Category ID: ${state.selectedCategoryId}');
    
    state = state.copyWith(
      isLoading: true, 
      error: null,
      currentPage: 1,
      hasMorePages: false,
    );

    try {
      final response = await _transactionService.getTransactions(
        startDate: state.selectedStartDate,
        endDate: state.selectedEndDate,
        search: state.searchQuery,
        categoryId: state.selectedCategoryId,
        page: 1,
      );

      print('✅ Loaded ${response.data.length} transactions');
      print('📄 Pagination: Page ${response.pagination.currentPage}/${response.pagination.lastPage}');
      print('💰 Summary - Income: ${response.summary.totalIncome}, Expense: ${response.summary.totalExpense}, Balance: ${response.summary.netAmount}');
      
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

  Future<void> loadMoreTransactions() async {
    if (state.isLoadingMore || !state.hasMorePages) return;
    
    print('📄 Loading more transactions - Page ${state.currentPage + 1}');
    
    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _transactionService.getTransactions(
        startDate: state.selectedStartDate,
        endDate: state.selectedEndDate,
        search: state.searchQuery,
        categoryId: state.selectedCategoryId,
        page: state.currentPage + 1,
      );

      print('✅ Loaded ${response.data.length} more transactions');
      print('📄 New pagination: Page ${response.pagination.currentPage}/${response.pagination.lastPage}');
      
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

  void updateDateRange(DateTime startDate, DateTime endDate) {
    state = state.copyWith(
      selectedStartDate: startDate,
      selectedEndDate: endDate,
    );
    // Don't call loadTransactions here - will be called after all filters are applied
  }

  void updateSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
    // Don't call loadTransactions here - will be called after all filters are applied
  }

  void updateCategoryFilter(int? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
    // Don't call loadTransactions here - will be called after all filters are applied
  }

  void applyFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int? categoryId,
    bool clearCategory = false,
  }) {
    state = state.copyWith(
      selectedStartDate: startDate ?? state.selectedStartDate,
      selectedEndDate: endDate ?? state.selectedEndDate,
      searchQuery: searchQuery,
      selectedCategoryId: clearCategory ? null : categoryId,
      clearSelectedCategoryId: clearCategory,
    );
    loadTransactions(); // Only call once after all filters are set
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

  Future<void> updateTransaction(int transactionId, AddTransactionRequest request) async {
    try {
      // API'ye güncelleme isteği gönder
      await _transactionService.updateTransaction(transactionId, request);

      // Başarılı olursa işlemleri yeniden yükle
      await loadTransactions();

    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      throw e; // Hata durumunda exception'ı tekrar fırlat
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    // Silinecek işlemi bul
    final transactionToDelete = state.transactions.firstWhere(
      (transaction) => transaction.id == transactionId,
      orElse: () => throw Exception('Transaction not found'),
    );

    try {
      // API'den sil
      await _transactionService.deleteTransaction(transactionId);

      // UI'dan kaldır
      final updatedTransactions = state.transactions
          .where((transaction) => transaction.id != transactionId)
          .toList();

      // Sadece silinen işlemin değerini summary'den çıkar
      double newIncome = state.totalIncome;
      double newExpense = state.totalExpense;
      
      if (transactionToDelete.isIncome) {
        newIncome -= transactionToDelete.amountAsDouble;
      } else {
        newExpense -= transactionToDelete.amountAsDouble;
      }

      state = state.copyWith(
        transactions: updatedTransactions,
        totalIncome: newIncome,
        totalExpense: newExpense,
        balance: newIncome - newExpense,
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
