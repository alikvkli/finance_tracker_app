import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/transactions/models/transaction_model.dart';
import '../../shared/widgets/transaction_skeleton.dart';
import '../../shared/widgets/custom_snackbar.dart';

class UnifiedTransactionList extends ConsumerWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;
  final bool enableSwipeToDelete;
  final int? maxItems;
  final EdgeInsets? padding;
  final Future<void> Function()? onRefresh;
  final Future<void> Function(TransactionModel)? onDelete;
  final Widget Function()? skeletonBuilder;
  final String? emptyTitle;
  final String? emptySubtitle;
  final Widget? emptyActionButton;

  const UnifiedTransactionList({
    super.key,
    required this.transactions,
    required this.isLoading,
    this.error,
    this.enableSwipeToDelete = false,
    this.maxItems,
    this.padding,
    this.onRefresh,
    this.onDelete,
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

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.builder(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayTransactions.length,
        itemBuilder: (context, index) {
          final transaction = displayTransactions[index];
          return enableSwipeToDelete && onDelete != null
              ? _SwipeableTransactionCard(
                  transaction: transaction,
                  onDelete: onDelete!,
                )
              : _TransactionCard(transaction: transaction);
        },
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              emptyTitle ?? 'Henüz işlem yok',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
            Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              'Sil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) async {
        try {
          await onDelete(transaction);
          if (context.mounted) {
            CustomSnackBar.showSuccess(
              context,
              message: 'İşlem başarıyla silindi',
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
      },
      child: _TransactionCard(transaction: transaction),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('İşlemi Sil'),
        content: const Text('Bu işlemi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? Colors.red[600] : Colors.green[600];

    return Container(
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
              color: _parseColor(transaction.category.color),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(transaction.category.icon),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.category.nameTr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.transactionDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
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
                '${isExpense ? '-' : '+'}${_formatAmount(transaction.amount)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction.currency,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'salary':
        return Icons.work;
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      case 'gift':
        return Icons.card_giftcard;
      case 'flash_on':
        return Icons.flash_on;
      case 'water_drop':
        return Icons.water_drop;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'wifi':
        return Icons.wifi;
      case 'phone':
        return Icons.phone;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'fastfood':
        return Icons.fastfood;
      case 'trending_up':
        return Icons.trending_up;
      case 'currency_bitcoin':
        return Icons.currency_bitcoin;
      case 'account_balance':
        return Icons.account_balance;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'business':
        return Icons.business;
      case 'more':
        return Icons.more_horiz;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'movie':
        return Icons.movie;
      case 'credit_card':
        return Icons.credit_card;
      case 'checkroom':
        return Icons.checkroom;
      case 'receipt':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }

  String _formatAmount(dynamic amount) {
    // Amount'u double'a çevir
    double amountValue;
    if (amount is String) {
      amountValue = double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      amountValue = amount.toDouble();
    } else {
      amountValue = 0.0;
    }

    // Tam sayı kısmını al
    final integerPart = amountValue.floor();
    
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Bugün';
    } else if (transactionDate == yesterday) {
      return 'Dün';
    } else {
      final monthNames = [
        'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
        'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
      ];
      return '${date.day} ${monthNames[date.month - 1]}';
    }
  }
}
