import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/transactions/models/transaction_model.dart';
import '../../features/transactions/widgets/edit_transaction_modal.dart';
import '../../shared/widgets/transaction_skeleton.dart';
import '../../shared/widgets/custom_snackbar.dart';
import '../../shared/widgets/rewarded_ad_helper.dart';
import '../../core/extensions/category_icon_extension.dart';
import '../../core/extensions/color_extension.dart';
import '../../core/extensions/amount_formatting_extension.dart';
import '../../core/extensions/date_formatting_extension.dart';

class UnifiedTransactionList extends ConsumerWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool enableSwipeToDelete;
  final int? maxItems;
  final EdgeInsets? padding;
  final Future<void> Function()? onRefresh;
  final Future<void> Function(TransactionModel)? onDelete;
  final Future<void> Function()? onLoadMore;
  final bool hasMorePages;
  final Widget Function()? skeletonBuilder;
  final String? emptyTitle;
  final String? emptySubtitle;
  final Widget? emptyActionButton;

  const UnifiedTransactionList({
    super.key,
    required this.transactions,
    required this.isLoading,
    this.isLoadingMore = false,
    this.error,
    this.enableSwipeToDelete = false,
    this.maxItems,
    this.padding,
    this.onRefresh,
    this.onDelete,
    this.onLoadMore,
    this.hasMorePages = false,
    this.skeletonBuilder,
    this.emptyTitle,
    this.emptySubtitle,
    this.emptyActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return skeletonBuilder?.call() ?? const TransactionsPageSkeleton();
    }

    if (error != null) {
      return _buildErrorWidget(context, error!);
    }

    if (transactions.isEmpty) {
      return _buildEmptyWidget(context);
    }

    final displayTransactions = maxItems != null
        ? transactions.take(maxItems!).toList()
        : transactions;

    // Calculate total item count (transactions + loading indicator)
    final totalItemCount =
        displayTransactions.length + (hasMorePages && isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.builder(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalItemCount,
        itemBuilder: (context, index) {
          // Show loading indicator at the end if loading more
          if (index == displayTransactions.length &&
              hasMorePages &&
              isLoadingMore) {
            return _buildLoadingMoreIndicator();
          }

          // Trigger load more when near the end
          if (index == displayTransactions.length - 3 &&
              hasMorePages &&
              !isLoadingMore &&
              onLoadMore != null &&
              maxItems == null) {
            // Only for full lists, not dashboard preview
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onLoadMore!();
            });
          }

          final transaction = displayTransactions[index];
          return enableSwipeToDelete && onDelete != null
              ? _SwipeableTransactionCard(
                  transaction: transaction,
                  onDelete: onDelete!,
                )
              : _TransactionCard(
                  transaction: transaction,
                  onTap: () => _showEditTransactionModal(context, transaction),
                );
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Yükleniyor...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Bir hata oluştu',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Deneyiniz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern empty illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              emptyTitle ?? 'Henüz işlem yok',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                emptySubtitle ?? 'Henüz herhangi bir işlem bulunamadı',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ),

            // Action button if provided
            if (emptyActionButton != null) emptyActionButton!,
          ],
        ),
      ),
    );
  }

  void _showEditTransactionModal(
    BuildContext context,
    TransactionModel transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTransactionModal(transaction: transaction),
    );
  }
}

class _SwipeableTransactionCard extends ConsumerWidget {
  final TransactionModel transaction;
  final Future<void> Function(TransactionModel) onDelete;

  const _SwipeableTransactionCard({
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 32),
            SizedBox(height: 4),
            Text('Sil', style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) async {
        await _handleDelete(context, ref);
      },
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context, ref),
        child: _TransactionCard(
          transaction: transaction,
          onTap: () => _showEditTransactionModal(context, transaction),
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final success = await RewardedAdHelper.showRewardedAdForAction(
      context,
      ref,
      actionTitle: 'İşlemi Sil',
      actionDescription: 'Bu işlemi silmek için kısa bir reklam izlemeniz gerekiyor.',
      onRewardEarned: () async {
        await onDelete(transaction);
      },
    );

    if (!success && context.mounted) {
      CustomSnackBar.showError(
        context,
        message: 'İşlem iptal edildi',
      );
    }
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TransactionActionsBottomSheet(
        transaction: transaction,
        onDelete: () async {
          Navigator.pop(context);
          final shouldDelete = await _showDeleteConfirmation(context);
          if (shouldDelete == true && context.mounted) {
            await _handleDelete(context, ref);
          }
        },
        onEdit: () {
          Navigator.pop(context);
          _showEditTransactionModal(context, transaction);
        },
      ),
    );
  }

  void _showEditTransactionModal(
    BuildContext context,
    TransactionModel transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTransactionModal(transaction: transaction),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Icon(
                Icons.delete_outline_rounded,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                size: 48,
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                'İşlemi Sil',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                'Bu işlemi silmek istediğinizden emin misiniz?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'İptal',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Delete Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Sil', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const _TransactionCard({
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? Colors.red[600] : Colors.green[600];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
          // Category Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: transaction.category.color.parseColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.category.icon.getCategoryIcon(),
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Transaction Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? transaction.category.nameTr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.category.nameTr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.transactionDate.formatForTransaction(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? '-' : '+'}${transaction.amount.formatAsTurkishLira()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: amountColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction.currency,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }



}

class _TransactionActionsBottomSheet extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _TransactionActionsBottomSheet({
    required this.transaction,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          const SizedBox(height: 28),

          // Transaction Info Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    transaction.category.icon.getCategoryIcon(),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description ?? transaction.category.nameTr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.category.nameTr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.transactionDate.formatForTransaction(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.type == 'expense' ? '-' : '+'}${transaction.amount.formatAsTurkishLira()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.currency,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Edit Button
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Düzenle',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Delete Button
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sil',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.red[600], fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }



}
