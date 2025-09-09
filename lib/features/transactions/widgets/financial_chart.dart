import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/transaction_controller.dart';

class FinancialChart extends ConsumerWidget {
  const FinancialChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionControllerProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Finansal Durum',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatDateRange(transactionState.selectedStartDate, transactionState.selectedEndDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Chart
          SizedBox(
            height: 200,
            child: _buildPieChart(context, transactionState),
          ),
          
          const SizedBox(height: 20),
          
          // Legend
          _buildLegend(context, transactionState),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, TransactionState state) {
    if (state.totalIncome == 0 && state.totalExpense == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Veri yok',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: [
          if (state.totalIncome > 0)
            PieChartSectionData(
              color: Colors.green[400],
              value: state.totalIncome,
              title: 'Gelir',
              radius: 60,
              titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (state.totalExpense > 0)
            PieChartSectionData(
              color: Colors.red[400],
              value: state.totalExpense,
              title: 'Gider',
              radius: 60,
              titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        startDegreeOffset: -90,
      ),
    );
  }

  Widget _buildLegend(BuildContext context, TransactionState state) {
    return Row(
      children: [
        // Income Legend
        Expanded(
          child: _buildLegendItem(
            context,
            'Gelir',
            state.totalIncome,
            Colors.green[400]!,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 16),
        // Expense Legend
        Expanded(
          child: _buildLegendItem(
            context,
            'Gider',
            state.totalExpense,
            Colors.red[400]!,
            Icons.trending_down,
          ),
        ),
        const SizedBox(width: 16),
        // Balance Legend
        Expanded(
          child: _buildLegendItem(
            context,
            'Bakiye',
            state.balance,
            state.balance >= 0 ? Colors.green[600]! : Colors.red[600]!,
            state.balance >= 0 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatAmount(amount)} ₺',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime startDate, DateTime endDate) {
    final months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];

    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return '${months[startDate.month - 1]} ${startDate.year}';
    } else {
      return '${months[startDate.month - 1]} - ${months[endDate.month - 1]}';
    }
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
}
