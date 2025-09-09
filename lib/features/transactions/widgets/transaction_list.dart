import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../controllers/transaction_controller.dart';

class TransactionList extends ConsumerWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionControllerProvider);

    print('🎨 TransactionList - Building widget:');
    print('   isLoading: ${transactionState.isLoading}');
    print('   error: ${transactionState.error}');
    print('   transactions count: ${transactionState.transactions.length}');
    print('   totalIncome: ${transactionState.totalIncome}');
    print('   totalExpense: ${transactionState.totalExpense}');
    print('   balance: ${transactionState.balance}');
    
    if (transactionState.transactions.isNotEmpty) {
      print('   First transaction: ${transactionState.transactions.first.id} - ${transactionState.transactions.first.amount} ${transactionState.transactions.first.currency}');
    }

    if (transactionState.isLoading) {
      print('   Showing loading indicator');
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (transactionState.error != null) {
      print('   Showing error widget: ${transactionState.error}');
      return _buildErrorWidget(context, ref, transactionState.error!);
    }

    if (transactionState.transactions.isEmpty) {
      print('   Showing empty widget');
      return _buildEmptyWidget(context);
    }

    print('   Showing transaction list with ${transactionState.transactions.length} items');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactionState.transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactionState.transactions[index];
        return _SwipeableTransactionCard(transaction: transaction);
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, String error) {
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
                fontWeight: FontWeight.bold,
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
              onPressed: () {
                ref.read(transactionControllerProvider.notifier).clearError();
                ref.read(transactionControllerProvider.notifier).loadTransactions();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
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
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz işlem yok',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seçilen dönemde herhangi bir işlem bulunamadı',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeableTransactionCard extends ConsumerWidget {
  final TransactionModel transaction;

  const _SwipeableTransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('transaction_${transaction.id}'),
      direction: DismissDirection.endToStart, // Sağdan sola kaydırma
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
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
        // Onay dialog'u göster
        return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Simple Icon
                  Icon(
                    Icons.delete_outline,
                    color: Colors.red[600],
                    size: 32,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    'İşlemi Sil',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Transaction Info - Minimal
                  Text(
                    '${transaction.category.nameTr} • ${_formatAmount(transaction.amountAsDouble)} ₺',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons - Minimal
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
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      
                      // Delete Button
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Sil',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontWeight: FontWeight.w600,
                            ),
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
      },
      onDismissed: (direction) {
        // İşlemi sil
        ref.read(transactionControllerProvider.notifier).deleteTransaction(transaction.id);
        
        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İşlem başarıyla silindi'),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: _TransactionCard(transaction: transaction),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'salary':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'trending_up':
        return Icons.trending_up;
      case 'work':
        return Icons.work_outline;
      case 'more':
        return Icons.more_horiz;
      case 'receipt':
        return Icons.receipt;
      case 'restaurant':
        return Icons.restaurant;
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
      case 'account_balance':
        return Icons.account_balance;
      case 'checkroom':
        return Icons.checkroom;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'fastfood':
        return Icons.fastfood;
      case 'local_cafe':
        return Icons.local_cafe;
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
      case 'currency_bitcoin':
        return Icons.currency_bitcoin;
      case 'receipt_long':
        return Icons.receipt_long;
      default:
        return Icons.category;
    }
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _parseColor(transaction.category.color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(transaction.category.icon),
              color: _parseColor(transaction.category.color),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category.nameTr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.transactionDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isIncome ? '+' : '-'}${_formatAmount(transaction.amountAsDouble)} ₺',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: transaction.isIncome
                      ? Colors.green[600]
                      : Colors.red[600],
                ),
              ),
              if (transaction.isRecurring) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getRecurringText(transaction.recurringType),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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
      default:
        return Icons.category;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  String _getRecurringText(String? recurringType) {
    switch (recurringType) {
      case 'daily':
        return 'Günlük';
      case 'weekly':
        return 'Haftalık';
      case 'monthly':
        return 'Aylık';
      case 'yearly':
        return 'Yıllık';
      default:
        return 'Tekrarlayan';
    }
  }
}
