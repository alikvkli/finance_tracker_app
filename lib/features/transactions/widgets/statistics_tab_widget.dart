import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/statistics_controller.dart';
import '../widgets/category_statistics_widget.dart';
import '../widgets/daily_statistics_chart.dart';
import '../models/statistics_models.dart';
import '../../../core/extensions/amount_formatting_extension.dart';

/// Widget to display statistics tab in transactions page
class StatisticsTabWidget extends ConsumerStatefulWidget {
  const StatisticsTabWidget({super.key});

  @override
  ConsumerState<StatisticsTabWidget> createState() =>
      _StatisticsTabWidgetState();
}

class _StatisticsTabWidgetState extends ConsumerState<StatisticsTabWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final statisticsState = ref.watch(statisticsControllerProvider);

    if (statisticsState.isLoading) {
      return const _StatisticsSkeleton();
    }

    if (statisticsState.error != null) {
      return _buildErrorWidget(context, ref, statisticsState.error!);
    }

    final statistics = statisticsState.statistics;
    if (statistics == null) {
      return _buildEmptyWidget(context);
    }

    // Check if filtered result is empty
    if (statisticsState.isFiltered && statisticsState.isEmpty) {
      return _buildFilteredEmptyWidget(context, ref);
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(statisticsControllerProvider.notifier)
              .refreshStatistics();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              _buildSummaryCards(context, statistics.summary),

              const SizedBox(height: 16),

              // Income Categories
              CategoryStatisticsWidget(
                categories: statisticsState.incomeCategories,
                title: 'Gelir Özeti',
                accentColor: Colors.green,
              ),

              const SizedBox(height: 16),

              // Expense Categories
              CategoryStatisticsWidget(
                categories: statisticsState.expenseCategories,
                title: 'Gider Özeti',
                accentColor: Colors.red,
              ),
              const SizedBox(height: 32),

              // Daily Chart
              DailyStatisticsChart(
                dailyStats: statistics.dailyStats,
                title: 'Günlük Trend',
              ),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDateFilterModal(context, ref);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.filter_alt),
        tooltip: 'Tarih Filtresi',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSummaryCards(BuildContext context, SummaryStats summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Net Amount Card
          Expanded(
            child: _buildSummaryCard(
              context,
              'Net Tutar',
              summary.netAmount,
              summary.netAmount >= 0 ? Colors.green : Colors.red,
              Icons.account_balance_wallet,
            ),
          ),

          const SizedBox(width: 12),

          // Transaction Count Card
          Expanded(
            child: _buildSummaryCard(
              context,
              'İşlem Sayısı',
              summary.transactionCount.toDouble(),
              Theme.of(context).colorScheme.primary,
              Icons.receipt_long,
              isCount: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double value,
    Color color,
    IconData icon, {
    bool isCount = false,
  }) {
    return Container(
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
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              if (isCount)
                Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                )
              else
                Text(
                  value.formatAsTurkishLira(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(statisticsControllerProvider.notifier)
                    .loadStatistics();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
              Icons.analytics_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz veri yok',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'İstatistikleri görmek için önce işlem eklemeniz gerekiyor.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Sonuç bulunamadı',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Seçilen tarih aralığında herhangi bir işlem bulunamadı.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _clearFilter(context, ref);
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Filtreyi Temizle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDateFilterModal(context, ref);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.filter_alt),
        tooltip: 'Tarih Filtresi',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showDateFilterModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tarih Aralığı Filtresi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Date pickers
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      context: context,
                      label: 'Başlangıç Tarihi',
                      date: _startDate,
                      onDateSelected: (date) {
                        setModalState(() {
                          _startDate = date;
                          if (_endDate != null &&
                              date != null &&
                              date.isAfter(_endDate!)) {
                            _endDate = null;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      context: context,
                      label: 'Bitiş Tarihi',
                      date: _endDate,
                      onDateSelected: (date) {
                        setModalState(() {
                          _endDate = date;
                          if (_startDate != null &&
                              date != null &&
                              date.isBefore(_startDate!)) {
                            _startDate = null;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),

              if (_startDate != null || _endDate != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getDateRangeText(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _startDate != null || _endDate != null
                          ? () {
                              setModalState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Temizle'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _startDate != null || _endDate != null
                          ? () {
                              _applyDateFilter(context, ref);
                              Navigator.pop(context);
                            }
                          : null,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Filtreyi Uygula'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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

  Widget _buildDatePicker({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required Function(DateTime?) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        onDateSelected(selectedDate);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: date != null ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: date != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date != null
                  ? '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}'
                  : 'Tarih seçiniz',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: date != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
    } else if (_startDate != null) {
      return '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} tarihinden itibaren';
    } else if (_endDate != null) {
      return '${_endDate!.day}/${_endDate!.month}/${_endDate!.year} tarihine kadar';
    }
    return '';
  }

  void _applyDateFilter(BuildContext context, WidgetRef ref) {
    // API'ye tarih filtresi ile istek at
    ref
        .read(statisticsControllerProvider.notifier)
        .loadStatistics(startDate: _startDate, endDate: _endDate);

    // Snackbar göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _getDateRangeText().isEmpty
              ? 'Tüm veriler gösteriliyor'
              : 'Filtre uygulandı',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _clearFilter(BuildContext context, WidgetRef ref) {
    // Clear filter and reload all statistics
    ref.read(statisticsControllerProvider.notifier).clearFilter();

    // Reset local state
    setState(() {
      _startDate = null;
      _endDate = null;
    });

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Filtre temizlendi, tüm veriler gösteriliyor'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Skeleton widget for statistics loading state
class _StatisticsSkeleton extends StatelessWidget {
  const _StatisticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Summary Cards Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildCardSkeleton(context)),
                const SizedBox(width: 12),
                Expanded(child: _buildCardSkeleton(context)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Categories Skeleton
          ...List.generate(
            2,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSkeleton(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
