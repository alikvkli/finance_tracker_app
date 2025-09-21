import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/recurring_transaction_controller.dart';
import '../models/recurring_transaction_model.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/transaction_skeleton.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/widgets/banner_ad_widget.dart';
import '../../../shared/controllers/config_controller.dart';
import '../../../shared/widgets/notification_badge.dart';
import '../../../core/extensions/category_icon_extension.dart';
import '../../../core/utils/logout_helper.dart';

class RecurringTransactionsPage extends ConsumerStatefulWidget {
  const RecurringTransactionsPage({super.key});

  @override
  ConsumerState<RecurringTransactionsPage> createState() =>
      _RecurringTransactionsPageState();
}

class _RecurringTransactionsPageState
    extends ConsumerState<RecurringTransactionsPage> {
  @override
  void initState() {
    super.initState();
    // Load recurring transactions when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recurringTransactionControllerProvider.notifier)
          .loadRecurringTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final recurringState = ref.watch(recurringTransactionControllerProvider);
    final configState = ref.watch(configControllerProvider);

    return PopScope(
      canPop: false, // Geri tuşunu devre dışı bırak
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: recurringState.isLoading
              ? _buildLoadingSkeleton(context)
              : Column(
                  children: [
                    // Custom Header for Recurring Transactions
                    _buildRecurringHeader(context, recurringState, configState),

                    // Banner Ad (if ads should be shown)
                    if (configState.config?.userPreferences.showAds == true)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: const BannerAdWidget(screenId: 'recurring'),
                      ),

                    // Content
                    Expanded(child: _buildContent(context, recurringState)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRecurringHeader(
    BuildContext context,
    RecurringTransactionState state,
    ConfigState configState,
  ) {
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
      child: Row(
        children: [
          // App Title
          Expanded(
            child: Text(
              'Hatırlatıcılar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
              ),
            ),
          ),

          // Action Buttons
          Row(
            children: [
              // Notification Button with Badge
              NotificationBadge(
                count: configState.config?.notifications.unreadCount ?? 0,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.notifications);
                  },
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 22,
                  ),
                  tooltip: 'Bildirimler',
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(40, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // Logout Button
              IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: Icon(
                  Icons.logout_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 22,
                ),
                tooltip: 'Çıkış Yap',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(40, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, RecurringTransactionState state) {
    if (state.error != null) {
      return _buildErrorWidget(context, state.error!);
    }

    if (state.transactions.isEmpty) {
      return _buildEmptyWidget(context);
    }

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
          // Content Header
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
                    Icons.schedule_rounded,
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
                        'Tekrarlayan Hatırlatmalar',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${state.transactions.length} işlem listeleniyor',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(child: _buildTransactionList(context, state)),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    RecurringTransactionState state,
  ) {
    // Calculate total item count (transactions + loading indicator)
    final totalItemCount =
        state.transactions.length +
        (state.hasMorePages && state.isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () async {
        ref
            .read(recurringTransactionControllerProvider.notifier)
            .refreshRecurringTransactions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: totalItemCount,
        itemBuilder: (context, index) {
          // Show loading indicator at the end if loading more
          if (index == state.transactions.length &&
              state.hasMorePages &&
              state.isLoadingMore) {
            return _buildLoadingMoreIndicator(context);
          }

          // Trigger load more when near the end
          if (index == state.transactions.length - 3 &&
              state.hasMorePages &&
              !state.isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(recurringTransactionControllerProvider.notifier)
                  .loadMoreRecurringTransactions();
            });
          }

          final transaction = state.transactions[index];
          return _RecurringTransactionCard(
            transaction: transaction,
            isToggling: state.togglingTransactions.contains(transaction.id),
            isEditing: state.editingTransactions.contains(transaction.id),
            isDeleting: state.deletingTransactions.contains(transaction.id),
            onToggle: (isActive) async {
              await ref
                  .read(recurringTransactionControllerProvider.notifier)
                  .toggleTransaction(transaction.id, isActive);
            },
            onEdit: () async {
              await _showEditTransactionModal(context, transaction);
            },
            onDelete: () async {
              final shouldDelete = await _showDeleteConfirmation(
                context,
                transaction,
              );
              if (shouldDelete == true) {
                try {
                  await ref
                      .read(recurringTransactionControllerProvider.notifier)
                      .deleteTransaction(transaction.id);
                  if (context.mounted) {
                    CustomSnackBar.showSuccess(
                      context,
                      message: 'Tekrarlayan işlem başarıyla silindi',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    CustomSnackBar.showError(
                      context,
                      message: 'İşlem silinirken bir hata oluştu',
                    );
                  }
                }
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator(BuildContext context) {
    return Container(
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
            'Daha fazla hatırlatıcı yükleniyor...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
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
              ).textTheme.titleLarge?.copyWith(fontSize: 18),
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
              onPressed: () {
                ref
                    .read(recurringTransactionControllerProvider.notifier)
                    .refreshRecurringTransactions();
              },
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
                Icons.repeat_rounded,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Henüz hatırlatıcı yok',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                'Henüz herhangi bir tekrarlayan işlem bulunamadı. Yeni işlem eklerken tekrarlama seçeneğini kullanabilirsiniz.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Column(
      children: [
        // Simple Header Skeleton (like FinancialHeader)
        _buildSimpleHeaderSkeleton(context),

        // Content Skeleton with TransactionSkeleton
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: const TransactionSkeleton(itemCount: 6),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleHeaderSkeleton(BuildContext context) {
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
      child: Row(
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
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: isCircle
            ? BorderRadius.circular((height ?? 16) / 2)
            : BorderRadius.circular(borderRadius ?? 8),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    RecurringTransactionModel transaction,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _DeleteConfirmationDialog(
        transaction: transaction,
        onDelete: () {
          Navigator.of(context).pop(true);
        },
        onCancel: () {
          Navigator.of(context).pop(false);
        },
      ),
    );
  }

  Future<void> _showEditTransactionModal(
    BuildContext context,
    RecurringTransactionModel transaction,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          _EditRecurringTransactionDialog(transaction: transaction),
    );

    if (result != null) {
      try {
        await ref
            .read(recurringTransactionControllerProvider.notifier)
            .updateTransaction(
              transaction.id,
              amount: result['amount'] as double?,
              startDate: result['start_date'] as DateTime?,
              endDate: result['end_date'] as DateTime?,
            );

        if (context.mounted) {
          CustomSnackBar.showSuccess(
            context,
            message: 'Tekrarlayan işlem başarıyla güncellendi',
          );
        }
      } catch (e) {
        if (context.mounted) {
          CustomSnackBar.showError(
            context,
            message: 'İşlem güncellenirken bir hata oluştu',
          );
        }
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 20,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red[600],
                  size: 36,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Çıkış Yap',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'İptal',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Logout Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await LogoutHelper.logout(context, ref);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Çıkış Yap',
                        style: TextStyle(fontSize: 16),
                      ),
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

class _RecurringTransactionCard extends StatelessWidget {
  final RecurringTransactionModel transaction;
  final bool isToggling;
  final bool isEditing;
  final bool isDeleting;
  final Function(bool) onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecurringTransactionCard({
    required this.transaction,
    required this.isToggling,
    required this.isEditing,
    required this.isDeleting,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? Colors.red[600] : Colors.green[600];

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: transaction.isActive
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Category Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _parseColor(transaction.category.color),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _parseColor(
                            transaction.category.color,
                          ).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                          transaction.description ??
                              transaction.category.nameTr,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          transaction.category.nameTr,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Recurring Type Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                transaction.recurringTypeDisplayName,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontSize: 11,
                                    ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Active/Inactive Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: transaction.isActive
                                    ? Colors.green[50]
                                    : Colors.orange[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: transaction.isActive
                                      ? Colors.green[200]!
                                      : Colors.orange[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                transaction.isActive ? 'Aktif' : 'Pasif',
                                style: TextStyle(
                                  color: transaction.isActive
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Amount & Controls
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isExpense ? '-' : '+'}${_formatAmount(transaction.amountAsDouble)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: amountColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.currency,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Toggle Switch
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: transaction.isActive,
                              onChanged: (isToggling || isEditing || isDeleting)
                                  ? null
                                  : onToggle, // Disable during any loading
                              activeColor: Colors.green[600],
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Edit Button
                          InkWell(
                            onTap: (isToggling || isEditing || isDeleting)
                                ? null
                                : onEdit,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: (isToggling || isEditing || isDeleting)
                                    ? Colors.grey[100]
                                    : Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: (isToggling || isEditing || isDeleting)
                                    ? Colors.grey[400]
                                    : Colors.blue[600],
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Delete Button
                          InkWell(
                            onTap: (isToggling || isEditing || isDeleting)
                                ? null
                                : onDelete,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: (isToggling || isEditing || isDeleting)
                                    ? Colors.grey[100]
                                    : Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: (isToggling || isEditing || isDeleting)
                                    ? Colors.grey[400]
                                    : Colors.red[600],
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bottom Info Row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(transaction.startDate)} - ${_formatDate(transaction.endDate)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (transaction.lastReminderSent != null) ...[
                      Icon(
                        Icons.notifications_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${transaction.reminderCount} hatırlatma',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Loading Overlay
        if (isToggling || isEditing || isDeleting)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                        isDeleting
                            ? 'Siliniyor...'
                            : isEditing
                            ? 'Kaydediliyor...'
                            : 'Güncelleniyor...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.grey;
    }
  }


  String _formatAmount(double amount) {
    // Tam sayı kısmını al
    final integerPart = amount.floor();

    // Binlik ayırıcılarla formatla
    final formattedAmount = _addThousandSeparators(integerPart.toString());

    return '₺$formattedAmount';
  }

  String _addThousandSeparators(String number) {
    if (number.isEmpty) return number;

    // Regex ile binlik ayırıcı ekle (nokta kullanarak)
    return number.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }
}

class _DeleteConfirmationDialog extends StatelessWidget {
  final RecurringTransactionModel transaction;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const _DeleteConfirmationDialog({
    required this.transaction,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              'Hatırlatıcıyı Sil',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              'Bu tekrarlayan işlemi silmek istediğinizden emin misiniz?',
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
                    onPressed: onCancel,
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

                // Delete Button (Simple)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDelete,
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
    );
  }
}

class _EditRecurringTransactionDialog extends StatefulWidget {
  final RecurringTransactionModel transaction;

  const _EditRecurringTransactionDialog({required this.transaction});

  @override
  State<_EditRecurringTransactionDialog> createState() =>
      _EditRecurringTransactionDialogState();
}

class _EditRecurringTransactionDialogState
    extends State<_EditRecurringTransactionDialog> {
  late TextEditingController _amountController;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;

  @override
  void initState() {
    super.initState();
    // Amount'u Turkish format ile göster
    final amountValue = widget.transaction.amountAsDouble;
    final formattedAmount = _formatAmountForDisplay(amountValue);
    _amountController = TextEditingController(text: formattedAmount);
    _selectedStartDate = widget.transaction.startDate;
    _selectedEndDate = widget.transaction.endDate;

    // Amount input listener ekle
    _amountController.addListener(() {
      _formatAmountInput(_amountController.text);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hatırlatıcıyı Düzenle',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Amount Field
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Tutar',
                prefixIcon: Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '₺',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
            ),

            const SizedBox(height: 16),

            // Start Date Field
            InkWell(
              onTap: () => _selectStartDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Başlangıç Tarihi',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(_selectedStartDate),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // End Date Field
            InkWell(
              onTap: () => _selectEndDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bitiş Tarihi',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(_selectedEndDate),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('İptal'),
                  ),
                ),

                const SizedBox(width: 12),

                // Save Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveChanges(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2020), // Allow past dates
      lastDate: _selectedEndDate, // Can't be after end date
    );

    if (selectedDate != null) {
      setState(() {
        _selectedStartDate = selectedDate;
        // If start date is after end date, adjust end date
        if (_selectedStartDate.isAfter(_selectedEndDate)) {
          _selectedEndDate = _selectedStartDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: _selectedStartDate, // Can't be before start date
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );

    if (selectedDate != null) {
      setState(() {
        _selectedEndDate = selectedDate;
        // If end date is before start date, adjust start date
        if (_selectedEndDate.isBefore(_selectedStartDate)) {
          _selectedStartDate = _selectedEndDate.subtract(const Duration(days: 30));
        }
      });
    }
  }

  void _formatAmountInput(String value) {
    // Sadece rakam ve virgül karakterlerine izin ver (nokta sadece binlik ayırıcı olarak kullanılacak)
    final cleanValue = value.replaceAll(RegExp(r'[^\d,]'), '');

    // Virgül kontrolü - sadece bir tane olabilir
    final commaCount = cleanValue.split(',').length - 1;
    if (commaCount > 1) {
      return; // Geçersiz format, değişiklik yapma
    }

    // Virgülden sonra maksimum 2 rakam
    if (cleanValue.contains(',')) {
      final parts = cleanValue.split(',');
      if (parts.length == 2 && parts[1].length > 2) {
        return; // Virgülden sonra 2'den fazla rakam
      }
    }

    // Formatlanmış değeri hesapla
    String formattedValue = _formatNumberWithSeparators(cleanValue);

    // Eğer değer değiştiyse, controller'ı güncelle
    if (formattedValue != value) {
      _amountController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }
  }

  String _formatNumberWithSeparators(String value) {
    if (value.isEmpty) return value;

    // Virgül varsa, ondalık kısmını ayır
    String integerPart = value;
    String decimalPart = '';

    if (value.contains(',')) {
      final parts = value.split(',');
      integerPart = parts[0];
      decimalPart = parts.length > 1 ? parts[1] : '';
    }

    // Tam sayı kısmını binlik ayırıcılarla formatla
    if (integerPart.isNotEmpty) {
      final number = int.tryParse(integerPart);
      if (number != null) {
        integerPart = _addThousandSeparators(number.toString());
      }
    }

    // Ondalık kısmını ekle
    if (decimalPart.isNotEmpty) {
      return '$integerPart,$decimalPart';
    }

    return integerPart;
  }

  String _addThousandSeparators(String number) {
    if (number.isEmpty) return number;

    // Regex ile binlik ayırıcı ekle (nokta kullanarak)
    return number.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );
  }

  String _formatAmountForDisplay(double amount) {
    // Ondalık kısmı var mı kontrol et
    if (amount == amount.floor()) {
      // Tam sayı ise ondalık gösterme
      final integerPart = amount.floor().toString();
      return _addThousandSeparators(integerPart);
    } else {
      // Ondalık varsa göster
      final parts = amount.toString().split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '';

      // Ondalık kısmını 2 haneli yap
      final formattedDecimal = decimalPart.padRight(2, '0').substring(0, 2);

      return '${_addThousandSeparators(integerPart)},$formattedDecimal';
    }
  }

  double _parseAmountFromText(String text) {
    // Nokta ve virgül karakterlerini temizle
    String cleanText = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleanText) ?? 0.0;
  }

  void _saveChanges(BuildContext context) {
    final amount = _parseAmountFromText(_amountController.text);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir tutar giriniz')),
      );
      return;
    }

    if (_selectedStartDate.isAfter(_selectedEndDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlangıç tarihi bitiş tarihinden sonra olamaz')),
      );
      return;
    }

    Navigator.of(context).pop({
      'amount': amount, 
      'start_date': _selectedStartDate,
      'end_date': _selectedEndDate
    });
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }
}
