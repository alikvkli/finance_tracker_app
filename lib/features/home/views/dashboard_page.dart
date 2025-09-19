import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/dashboard_controller.dart';
import '../../../shared/widgets/transaction_skeleton.dart';
import '../../../shared/widgets/financial_header.dart';
import '../../../shared/widgets/month_badge.dart';
import '../../../shared/widgets/unified_transaction_list.dart';

class DashboardPage extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToTransactions;
  
  const DashboardPage({
    super.key,
    this.onNavigateToTransactions,
  });

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {

  @override
  void initState() {
    super.initState();
    // Load dashboard data when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardControllerProvider.notifier).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardControllerProvider);

    return PopScope(
      canPop: false, // Geri tuşunu devre dışı bırak
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
        child: dashboardState.isLoading
            ? _buildDashboardSkeleton(context)
            : Column(
                children: [
                  // Financial Header
                  FinancialHeader(
                    title: 'Finans Takip',
                    balance: dashboardState.balance,
                    totalIncome: dashboardState.totalIncome,
                    totalExpense: dashboardState.totalExpense,
                    monthBadge: MonthBadge.current(),
                    onNotificationTap: () {
                      // Notification action
                    },
                  ),

                  // Recent Transactions Section
                  Expanded(
                    child: _buildRecentTransactionsSection(context, dashboardState),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildDashboardSkeleton(BuildContext context) {
    return Column(
      children: [
        // Header Skeleton
        _buildHeaderSkeleton(context),
        
        // Transactions Section Skeleton
        Expanded(
          child: _buildTransactionsSkeleton(context),
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
              _buildSkeletonContainer(width: 140, height: 24),
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
              // Current Month Badge Skeleton
              _buildSkeletonContainer(width: 80, height: 28, borderRadius: 16),
              
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

  Widget _buildTransactionsSkeleton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Skeleton
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildSkeletonContainer(width: 40, height: 40, borderRadius: 12),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonContainer(width: 100, height: 14),
                      const SizedBox(height: 4),
                      _buildSkeletonContainer(width: 150, height: 12),
                    ],
                  ),
                ),
                _buildSkeletonContainer(width: 100, height: 32, borderRadius: 12),
              ],
            ),
          ),
          
          // Transaction List Skeleton
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: 8,
              itemBuilder: (context, index) => _buildTransactionItemSkeleton(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItemSkeleton(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: index == 7 ? 0 : 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
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
                _buildSkeletonContainer(width: 120, height: 16),
                const SizedBox(height: 6),
                _buildSkeletonContainer(width: 80, height: 12),
                const SizedBox(height: 4),
                _buildSkeletonContainer(width: 60, height: 10),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Amount Skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSkeletonContainer(width: 80, height: 16),
              const SizedBox(height: 4),
              _buildSkeletonContainer(width: 40, height: 10),
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


  Widget _buildRecentTransactionsSection(
    BuildContext context,
    DashboardState dashboardState,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Recent Transactions Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Son İşlemler',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Son 30 günün işlemleri',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onNavigateToTransactions,
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: UnifiedTransactionList(
              transactions: dashboardState.transactions,
              isLoading: false, // Already handled at page level
              isLoadingMore: dashboardState.isLoadingMore,
              error: dashboardState.error,
              enableSwipeToDelete: true, // Enable swipe to delete on dashboard
              maxItems: null, // Remove limit to enable infinite scroll
              hasMorePages: dashboardState.hasMorePages,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              onRefresh: () async {
                ref.read(dashboardControllerProvider.notifier).refreshDashboard();
              },
              onDelete: (transaction) async {
                // Delete transaction and refresh dashboard
                await ref.read(dashboardControllerProvider.notifier).deleteTransaction(transaction.id);
              },
              onLoadMore: () async {
                // Load more transactions for infinite scroll
                await ref.read(dashboardControllerProvider.notifier).loadMoreDashboardData();
              },
              skeletonBuilder: () => const DashboardTransactionSkeleton(),
              emptyTitle: 'Henüz işlem yok',
              emptySubtitle: 'Son 30 günde herhangi bir işlem bulunamadı',
            ),
          ),
        ],
      ),
    );
  }




}
