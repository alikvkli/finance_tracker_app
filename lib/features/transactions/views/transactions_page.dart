import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_controller.dart';
import '../../../shared/widgets/financial_header.dart';
import '../../../shared/widgets/month_badge.dart';
import '../../../shared/widgets/unified_transaction_list.dart';
import '../../../shared/widgets/transaction_skeleton.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {

  @override
  void initState() {
    super.initState();
    // Load transactions when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionControllerProvider.notifier).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionControllerProvider);
    
    // Debug: Print current state
    print('🏠 TransactionsPage build - Transaction count: ${transactionState.transactions.length}');
    print('🏠 Loading: ${transactionState.isLoading}, Error: ${transactionState.error}');
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: transactionState.isLoading
            ? _buildTransactionsPageSkeleton(context)
            : Column(
                children: [
                  // Financial Header
                  FinancialHeader(
                    title: 'İşlemler',
                    balance: transactionState.balance,
                    totalIncome: transactionState.totalIncome,
                    totalExpense: transactionState.totalExpense,
                    monthBadge: MonthBadge.dateRange(
                      start: transactionState.selectedStartDate,
                      end: transactionState.selectedEndDate,
                    ),
                    onNotificationTap: () {
                      // Notification action
                    },
                  ),
                  
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: UnifiedTransactionList(
                        transactions: transactionState.transactions,
                        isLoading: false, // Already handled at page level
                        error: transactionState.error,
                        enableSwipeToDelete: true, // Enable swipe to delete
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onRefresh: () async {
                          ref.read(transactionControllerProvider.notifier).refreshTransactions();
                        },
                        onDelete: (transaction) async {
                          // Delete transaction and refresh list
                          await ref.read(transactionControllerProvider.notifier).deleteTransaction(transaction.id);
                        },
                        skeletonBuilder: () => const TransactionsPageSkeleton(),
                        emptyTitle: 'Henüz işlem yok',
                        emptySubtitle: 'Seçilen tarih aralığında herhangi bir işlem bulunamadı',
                        emptyActionButton: _buildClearFiltersButton(context, transactionState),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget? _buildClearFiltersButton(BuildContext context, TransactionState transactionState) {
    // Eğer herhangi bir filtre aktifse buton göster
    final now = DateTime.now();
    final defaultStartDate = DateTime(now.year, now.month, 1);
    final defaultEndDate = DateTime(now.year, now.month + 1, 0);
    
    final isDateFiltered = transactionState.selectedStartDate != defaultStartDate ||
                          transactionState.selectedEndDate != defaultEndDate;
    final isCategoryFiltered = transactionState.selectedCategoryId != null;
    final isSearchFiltered = transactionState.searchQuery != null && 
                            transactionState.searchQuery!.isNotEmpty;
    
    final isFiltered = isDateFiltered || isCategoryFiltered || isSearchFiltered;
    
    if (!isFiltered) return null;
    
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        children: [          
            // Clear filters button
            ElevatedButton.icon(
              onPressed: () {
                // Tüm filtreleri temizle
                ref.read(transactionControllerProvider.notifier).clearFilters();
              },
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Filtreleri Temizle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
        ],
      ),
    );
  }



  Widget _buildTransactionsPageSkeleton(BuildContext context) {
    return Column(
      children: [
        // Header Skeleton
        _buildHeaderSkeleton(context),
        
        // Transactions List Skeleton
        Expanded(
          child: _buildTransactionsListSkeleton(context),
        ),
      ],
    );
  }

  Widget _buildHeaderSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row Skeleton
          Row(
            children: [
              // App Title Skeleton
              _buildSkeletonContainer(width: 100, height: 24),
              const Spacer(),
              
              // Action Buttons Skeleton
              Row(
                children: [
                  _buildSkeletonContainer(width: 40, height: 40, isCircle: true),
                  const SizedBox(width: 4),
                  _buildSkeletonContainer(width: 40, height: 40, isCircle: true),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Financial Overview Skeleton
          Column(
            children: [
              // Month Badge Skeleton
              _buildSkeletonContainer(width: 120, height: 28, borderRadius: 16),
              
              const SizedBox(height: 16),
              
              // Net Balance Label Skeleton
              _buildSkeletonContainer(width: 80, height: 14),
              
              const SizedBox(height: 8),
              
              // Net Balance Amount Skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSkeletonContainer(width: 180, height: 32),
                  const SizedBox(width: 8),
                  _buildSkeletonContainer(width: 20, height: 20, isCircle: true),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Income & Expense Row Skeleton
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSkeletonContainer(width: 16, height: 16, isCircle: true),
                            const SizedBox(width: 6),
                            _buildSkeletonContainer(width: 40, height: 12),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildSkeletonContainer(width: 80, height: 16),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSkeletonContainer(width: 16, height: 16, isCircle: true),
                            const SizedBox(width: 6),
                            _buildSkeletonContainer(width: 40, height: 12),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildSkeletonContainer(width: 80, height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsListSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 15, // Show more items for transactions page
        itemBuilder: (context, index) => _buildTransactionItemSkeleton(context, index),
      ),
    );
  }

  Widget _buildTransactionItemSkeleton(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: index == 14 ? 0 : 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category Icon Skeleton
          _buildSkeletonContainer(width: 48, height: 48, borderRadius: 12),
          
          const SizedBox(width: 16),
          
          // Transaction Info Skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonContainer(width: double.infinity, height: 16),
                const SizedBox(height: 6),
                _buildSkeletonContainer(width: 120, height: 14),
                const SizedBox(height: 4),
                _buildSkeletonContainer(width: 80, height: 12),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Amount Skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSkeletonContainer(width: 100, height: 16),
              const SizedBox(height: 4),
              _buildSkeletonContainer(width: 30, height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonContainer({
    double? width,
    double? height,
    double? borderRadius,
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height ?? 16,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: isCircle 
            ? BorderRadius.circular((height ?? 16) / 2)
            : BorderRadius.circular(borderRadius ?? 8),
      ),
    );
  }
}