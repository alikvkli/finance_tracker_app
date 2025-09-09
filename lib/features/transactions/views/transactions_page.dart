import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_list.dart';
import '../widgets/month_selector.dart';
import '../widgets/transaction_filters.dart';
import '../widgets/add_transaction_modal.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../core/routing/app_router.dart';
import '../../auth/controllers/auth_controller.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  int _currentIndex = 1; // İşlemler sayfası aktif

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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(context),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TransactionList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterBottomSheet(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.tune_rounded,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final transactionState = ref.watch(transactionControllerProvider);
    
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
          // Top Row with Title and Action Buttons
          Row(
            children: [
              // App Title
              Expanded(
                child: Text(
                  'İşlemler',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                  ),
                ),
              ),
              
              // Action Buttons
              Row(
                children: [
                  // Notification Button
                  IconButton(
                    onPressed: () {
                      // Notification action
                    },
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                  
                  const SizedBox(width: 4),
                  
                  // Logout Button
                  IconButton(
                    onPressed: () => _showLogoutDialog(context),
                    icon: Icon(
                      Icons.logout_rounded,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
          
          const SizedBox(height: 24),
          
          // Financial Overview
          _buildFinancialOverview(context, transactionState),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(BuildContext context, TransactionState transactionState) {
    return Column(
      children: [
        // Net Balance - Primary Focus
        _buildNetBalanceSection(context, transactionState.balance),
        
        const SizedBox(height: 32),
        
        // Income & Expense - Secondary
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                'Gelir',
                _formatAmount(transactionState.totalIncome),
                Icons.arrow_upward_rounded,
                const Color(0xFF059669),
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
            Expanded(
              child: _buildStatItem(
                context,
                'Gider',
                _formatAmount(transactionState.totalExpense),
                Icons.arrow_downward_rounded,
                const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetBalanceSection(BuildContext context, double balance) {
    final isPositive = balance >= 0;
    final color = isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final transactionState = ref.watch(transactionControllerProvider);
    
    return Column(
      children: [
        // Month Badge
        _buildMonthBadge(context, transactionState),
        
        const SizedBox(height: 16),
        
        // Net Balance Label
        Text(
          'Net Bakiye',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Net Balance Amount with Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _formatAmount(balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 32,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String amount, IconData icon, Color color) {
    return Column(
      children: [
        // Icon and Label Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Amount
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthBadge(BuildContext context, TransactionState transactionState) {
    final monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    
    final startDate = transactionState.selectedStartDate;
    final endDate = transactionState.selectedEndDate;
    
    String monthText;
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      // Same month
      monthText = '${monthNames[startDate.month - 1]} ${startDate.year}';
    } else if (startDate.year == endDate.year) {
      // Same year, different months
      monthText = '${monthNames[startDate.month - 1]} - ${monthNames[endDate.month - 1]} ${startDate.year}';
    } else {
      // Different years
      monthText = '${monthNames[startDate.month - 1]} ${startDate.year} - ${monthNames[endDate.month - 1]} ${endDate.year}';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        monthText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == 0) return '₺0,00';
    
    // Negatif değerleri pozitif yap
    final absAmount = amount.abs();
    
    if (absAmount >= 1000000) {
      return '₺${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      return '₺${(absAmount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₺${absAmount.toStringAsFixed(0)}';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Handle navigation
    switch (index) {
      case 0:
        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
        break;
      case 1:
        // Already on transactions
        break;
      case 2:
        // Add transaction
        _showAddTransactionModal(context);
        break;
    }
  }


  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      builder: (context) => const TransactionFilters(),
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionModal(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'İptal',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
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
                        Navigator.of(context).pop();
                        await ref.read(authControllerProvider.notifier).logout();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.login,
                            (route) => false,
                          );
                        }
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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
  }

}
