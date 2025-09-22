import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../models/recurring_transaction_model.dart';
import '../services/recurring_transaction_service.dart';
import '../../../core/di/injection.dart';

class RecurringTransactionState extends Equatable {
  final List<RecurringTransactionModel> transactions;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMorePages;
  final int totalCount;
  final int activeCount;
  final int inactiveCount;
  final Set<int> togglingTransactions;
  final Set<int> editingTransactions;
  final Set<int> deletingTransactions;

  const RecurringTransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePages = false,
    this.totalCount = 0,
    this.activeCount = 0,
    this.inactiveCount = 0,
    this.togglingTransactions = const {},
    this.editingTransactions = const {},
    this.deletingTransactions = const {},
  });

  RecurringTransactionState copyWith({
    List<RecurringTransactionModel>? transactions,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMorePages,
    int? totalCount,
    int? activeCount,
    int? inactiveCount,
    Set<int>? togglingTransactions,
    Set<int>? editingTransactions,
    Set<int>? deletingTransactions,
  }) {
    return RecurringTransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      totalCount: totalCount ?? this.totalCount,
      activeCount: activeCount ?? this.activeCount,
      inactiveCount: inactiveCount ?? this.inactiveCount,
      togglingTransactions: togglingTransactions ?? this.togglingTransactions,
      editingTransactions: editingTransactions ?? this.editingTransactions,
      deletingTransactions: deletingTransactions ?? this.deletingTransactions,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    isLoading,
    isLoadingMore,
    error,
    currentPage,
    hasMorePages,
    totalCount,
    activeCount,
    inactiveCount,
    togglingTransactions,
    editingTransactions,
    deletingTransactions,
  ];
}

class RecurringTransactionController extends StateNotifier<RecurringTransactionState> {
  final RecurringTransactionService _recurringTransactionService;

  RecurringTransactionController(this._recurringTransactionService)
      : super(const RecurringTransactionState());

  Future<void> loadRecurringTransactions({bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: true, 
      error: null,
      currentPage: 1,
      hasMorePages: false,
    );

    try {
      final response = await _recurringTransactionService.getRecurringTransactions(page: 1);
      
      state = state.copyWith(
        transactions: response.data,
        isLoading: false,
        currentPage: response.pagination.currentPage,
        hasMorePages: response.pagination.hasMorePages,
        totalCount: response.summary.totalCount,
        activeCount: response.summary.activeCount,
        inactiveCount: response.summary.inactiveCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadMoreRecurringTransactions() async {
    if (state.isLoadingMore || !state.hasMorePages) return;
    
    print('📄 Loading more recurring transactions - Page ${state.currentPage + 1}');
    
    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _recurringTransactionService.getRecurringTransactions(
        page: state.currentPage + 1,
      );

      print('✅ Loaded ${response.data.length} more recurring transactions');
      print('📄 New pagination: Page ${response.pagination.currentPage}/${response.pagination.lastPage}');
      
      // Mevcut transactions'lara yenilerini ekle
      final allTransactions = [...state.transactions, ...response.data];
      
      state = state.copyWith(
        transactions: allTransactions,
        isLoadingMore: false,
        currentPage: response.pagination.currentPage,
        hasMorePages: response.pagination.hasMorePages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> toggleTransaction(int transactionId, bool isActive) async {
    // Loading state'i başlat
    final currentTogglingSet = Set<int>.from(state.togglingTransactions);
    currentTogglingSet.add(transactionId);
    
    state = state.copyWith(
      togglingTransactions: currentTogglingSet,
      error: null,
    );

    try {
      await _recurringTransactionService.toggleRecurringTransaction(transactionId, isActive);
      
      // Local state'i güncelle
      final updatedTransactions = state.transactions.map((transaction) {
        if (transaction.id == transactionId) {
          return RecurringTransactionModel(
            id: transaction.id,
            userId: transaction.userId,
            categoryId: transaction.categoryId,
            type: transaction.type,
            amount: transaction.amount,
            currency: transaction.currency,
            description: transaction.description,
            recurringType: transaction.recurringType,
            startDate: transaction.startDate,
            endDate: transaction.endDate,
            isActive: isActive,
            metadata: transaction.metadata,
            lastReminderSent: transaction.lastReminderSent,
            reminderCount: transaction.reminderCount,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt,
            category: transaction.category,
          );
        }
        return transaction;
      }).toList();

      // Summary'yi güncelle
      final activeCount = updatedTransactions.where((t) => t.isActive).length;
      final inactiveCount = updatedTransactions.length - activeCount;

      // Loading state'i bitir
      final finalTogglingSet = Set<int>.from(currentTogglingSet);
      finalTogglingSet.remove(transactionId);

      state = state.copyWith(
        transactions: updatedTransactions,
        activeCount: activeCount,
        inactiveCount: inactiveCount,
        togglingTransactions: finalTogglingSet,
      );

    } catch (e) {
      // Loading state'i bitir (hata durumunda)
      final finalTogglingSet = Set<int>.from(currentTogglingSet);
      finalTogglingSet.remove(transactionId);
      
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        togglingTransactions: finalTogglingSet,
      );
    }
  }

  Future<void> updateTransaction(int transactionId, {double? amount, DateTime? startDate, DateTime? endDate}) async {
    // Loading state'i başlat
    final currentEditingSet = Set<int>.from(state.editingTransactions);
    currentEditingSet.add(transactionId);
    
    state = state.copyWith(
      editingTransactions: currentEditingSet,
      error: null,
    );

    try {
      final updateData = <String, dynamic>{};
      if (amount != null) updateData['amount'] = amount;
      if (startDate != null) updateData['start_date'] = startDate.toIso8601String();
      if (endDate != null) updateData['end_date'] = endDate.toIso8601String();

      await _recurringTransactionService.updateRecurringTransaction(transactionId, updateData);
      
      // Local state'i güncelle
      final updatedTransactions = state.transactions.map((transaction) {
        if (transaction.id == transactionId) {
          return RecurringTransactionModel(
            id: transaction.id,
            userId: transaction.userId,
            categoryId: transaction.categoryId,
            type: transaction.type,
            amount: amount != null ? amount.toString() : transaction.amount,
            currency: transaction.currency,
            description: transaction.description,
            recurringType: transaction.recurringType,
            startDate: startDate ?? transaction.startDate,
            endDate: endDate ?? transaction.endDate,
            isActive: transaction.isActive,
            metadata: transaction.metadata,
            lastReminderSent: transaction.lastReminderSent,
            reminderCount: transaction.reminderCount,
            createdAt: transaction.createdAt,
            updatedAt: DateTime.now(), // Update timestamp
            category: transaction.category,
          );
        }
        return transaction;
      }).toList();
      
      // Loading state'i bitir
      final finalEditingSet = Set<int>.from(currentEditingSet);
      finalEditingSet.remove(transactionId);
      
      state = state.copyWith(
        transactions: updatedTransactions,
        editingTransactions: finalEditingSet,
      );

    } catch (e) {
      // Loading state'i bitir (hata durumunda)
      final finalEditingSet = Set<int>.from(currentEditingSet);
      finalEditingSet.remove(transactionId);
      
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        editingTransactions: finalEditingSet,
      );
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    // Loading state'i başlat
    final currentDeletingSet = Set<int>.from(state.deletingTransactions);
    currentDeletingSet.add(transactionId);
    
    state = state.copyWith(
      deletingTransactions: currentDeletingSet,
      error: null,
    );

    try {
      await _recurringTransactionService.deleteRecurringTransaction(transactionId);

      // Local state'den kaldır
      final updatedTransactions = state.transactions
          .where((transaction) => transaction.id != transactionId)
          .toList();

      // Summary'yi güncelle
      final activeCount = updatedTransactions.where((t) => t.isActive).length;
      final inactiveCount = updatedTransactions.length - activeCount;

      // Loading state'i bitir
      final finalDeletingSet = Set<int>.from(currentDeletingSet);
      finalDeletingSet.remove(transactionId);

      state = state.copyWith(
        transactions: updatedTransactions,
        totalCount: updatedTransactions.length,
        activeCount: activeCount,
        inactiveCount: inactiveCount,
        deletingTransactions: finalDeletingSet,
      );

    } catch (e) {
      // Loading state'i bitir (hata durumunda)
      final finalDeletingSet = Set<int>.from(currentDeletingSet);
      finalDeletingSet.remove(transactionId);
      
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
        deletingTransactions: finalDeletingSet,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refreshRecurringTransactions() async {
    await loadRecurringTransactions(isRefresh: true);
  }
}

final recurringTransactionServiceProvider = Provider<RecurringTransactionService>((ref) {
  return RecurringTransactionService(getIt<Dio>(), ref.watch(storageServiceProvider));
});

final recurringTransactionControllerProvider =
    StateNotifierProvider<RecurringTransactionController, RecurringTransactionState>((ref) {
  final recurringTransactionService = ref.watch(recurringTransactionServiceProvider);
  return RecurringTransactionController(recurringTransactionService);
});
