import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/statistics_models.dart';

enum ChartViewMode {
  overview,    // Tüm veri, genel bakış
  detailed,    // Detaylı görünüm
  comparison,  // Karşılaştırma modu
}

/// Widget to display daily statistics as a chart
class DailyStatisticsChart extends ConsumerStatefulWidget {
  final List<DailyStats> dailyStats;
  final String title;

  const DailyStatisticsChart({
    super.key,
    required this.dailyStats,
    required this.title,
  });

  @override
  ConsumerState<DailyStatisticsChart> createState() => _DailyStatisticsChartState();
}

class _DailyStatisticsChartState extends ConsumerState<DailyStatisticsChart> {
  // Chart view modes
  ChartViewMode _viewMode = ChartViewMode.overview;
  
  // Adaptive scaling
  late double _optimalBarWidth;
  late int _maxVisibleBars;
  
  // Smart intervals
  int _dateInterval = 1;

  @override
  void initState() {
    super.initState();
    _initializeChartSettings();
  }

  void _initializeChartSettings() {
    // Calculate optimal bar width based on data density
    final dataCount = widget.dailyStats.length;
    
    // Default to detailed view for better user experience
    _viewMode = ChartViewMode.detailed;
    
    if (dataCount <= 7) {
      // Week view - wider bars
      _optimalBarWidth = 16.0;
      _maxVisibleBars = 7;
    } else if (dataCount <= 30) {
      // Month view - medium bars
      _optimalBarWidth = 12.0;
      _maxVisibleBars = 10;
    } else {
      // Long period - medium bars, but still detailed view
      _optimalBarWidth = 8.0;
      _maxVisibleBars = 12;
    }
    
    // Calculate smart intervals
    _calculateSmartIntervals();
  }

  void _calculateSmartIntervals() {
    final dataCount = widget.dailyStats.length;
    
    // Since we default to detailed view, use smaller intervals
    if (dataCount <= 7) {
      _dateInterval = 1; // Show every day
    } else if (dataCount <= 30) {
      _dateInterval = 1; // Show every day for better detail
    } else if (dataCount <= 90) {
      _dateInterval = 2; // Show every 2 days
    } else {
      _dateInterval = 3; // Show every 3 days
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dailyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group data by date
    final groupedData = _groupDataByDate(widget.dailyStats);
    final dates = groupedData.keys.toList()..sort();
    
    if (dates.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate max amount for scaling
    final maxAmount = groupedData.values.fold<double>(
      0.0,
      (max, dayData) => (dayData['income'] ?? 0.0) + (dayData['expense'] ?? 0.0),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.none, // Tooltip'lerin taşmasına izin ver
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
          // Header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${dates.length} gün',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Chart
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 180,
                padding: const EdgeInsets.all(8),
                child: maxAmount > 0
                    ? _buildAdaptiveChart(context, groupedData, dates, maxAmount)
                    : _buildEmptyChart(context),
              );
            },
          ),

          const SizedBox(height: 16),

          // Legend
          _buildLegend(context),
        ],
      ),
    );
  }

  Map<DateTime, Map<String, double>> _groupDataByDate(List<DailyStats> stats) {
    final Map<DateTime, Map<String, double>> grouped = {};

    for (final stat in stats) {
      final date = DateTime(
        stat.transactionDate.year,
        stat.transactionDate.month,
        stat.transactionDate.day,
      );

      grouped.putIfAbsent(date, () => {'income': 0.0, 'expense': 0.0});
      grouped[date]![stat.type] = stat.totalAmount;
    }

    return grouped;
  }

  Widget _buildAdaptiveChart(
    BuildContext context,
    Map<DateTime, Map<String, double>> groupedData,
    List<DateTime> dates,
    double maxAmount,
  ) {
    return OverflowBox(
      maxHeight: 220, // Tooltip için ekstra alan
      child: Stack(
        clipBehavior: Clip.none, // Tooltip'lerin taşmasına izin ver
        children: [
          // Chart
          _buildOptimizedChart(context, groupedData, dates, maxAmount),
          
          // View Mode Controls
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewModeButton(
                  context,
                  icon: _getViewModeIcon(),
                  onPressed: _toggleViewMode,
                  tooltip: _getViewModeTooltip(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getViewModeIcon() {
    switch (_viewMode) {
      case ChartViewMode.overview:
        return Icons.zoom_out_map;
      case ChartViewMode.detailed:
        return Icons.zoom_in;
      case ChartViewMode.comparison:
        return Icons.compare_arrows;
    }
  }

  String _getViewModeTooltip() {
    switch (_viewMode) {
      case ChartViewMode.overview:
        return 'Detaylı Görünüm';
      case ChartViewMode.detailed:
        return 'Genel Bakış';
      case ChartViewMode.comparison:
        return 'Karşılaştırma';
    }
  }

  void _toggleViewMode() {
    setState(() {
      switch (_viewMode) {
        case ChartViewMode.overview:
          _viewMode = ChartViewMode.detailed;
          break;
        case ChartViewMode.detailed:
          _viewMode = ChartViewMode.comparison;
          break;
        case ChartViewMode.comparison:
          _viewMode = ChartViewMode.overview;
          break;
      }
      _updateViewModeSettings();
    });
  }

  void _updateViewModeSettings() {
    final dataCount = widget.dailyStats.length;
    
    switch (_viewMode) {
      case ChartViewMode.overview:
        _optimalBarWidth = (dataCount > 30) ? 4.0 : 8.0;
        _maxVisibleBars = (dataCount > 30) ? 20 : 15;
        _dateInterval = (dataCount > 30) ? 10 : 5;
        break;
      case ChartViewMode.detailed:
        _optimalBarWidth = 16.0;
        _maxVisibleBars = 7;
        _dateInterval = 1;
        break;
      case ChartViewMode.comparison:
        _optimalBarWidth = 12.0;
        _maxVisibleBars = 10;
        _dateInterval = 2;
        break;
    }
  }

  Widget _buildViewModeButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildOptimizedChart(
    BuildContext context,
    Map<DateTime, Map<String, double>> groupedData,
    List<DateTime> dates,
    double maxAmount,
  ) {
    // Calculate optimal data sampling based on view mode
    final processedData = _processDataForViewMode(dates, groupedData);
    final visibleDates = processedData['dates'] as List<DateTime>;
    final sampledData = processedData['data'] as Map<DateTime, Map<String, double>>;


    final List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < visibleDates.length; i++) {
      final date = visibleDates[i];
      final dayData = sampledData[date]!;
      final income = dayData['income'] ?? 0.0;
      final expense = dayData['expense'] ?? 0.0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            // Income Bar
            BarChartRodData(
              toY: income,
              color: Colors.green.withValues(alpha: 0.8),
              width: _optimalBarWidth,
              borderRadius: BorderRadius.circular(_optimalBarWidth / 3),
            ),
            // Expense Bar
            BarChartRodData(
              toY: expense,
              color: Colors.red.withValues(alpha: 0.8),
              width: _optimalBarWidth,
              borderRadius: BorderRadius.circular(_optimalBarWidth / 3),
            ),
          ],
          barsSpace: _optimalBarWidth * 0.3,
        ),
      );
    }

    return BarChart(
      BarChartData(
        // Let fl_chart handle Y axis scaling automatically
        minY: 0.0,
        // Limit the visible bars based on zoom
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: visibleDates.length > 10 ? 2.0 : 1.0,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < visibleDates.length) {
                  final date = visibleDates[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _formatDateForChart(date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: _optimalBarWidth > 8 ? 8 : 7,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 16,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                return Text(
                  _formatCompactNumber(value),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 7,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                );
              },
              reservedSize: 24,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              strokeWidth: 0.5,
            );
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: barGroups,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 12,
            direction: TooltipDirection.top,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = visibleDates[group.x];
              final dayData = groupedData[date]!;
              final income = dayData['income'] ?? 0.0;
              final expense = dayData['expense'] ?? 0.0;
              
              // Kısa tarih formatı
              final formattedDate = _formatDateForTooltip(date);
              
              // Tooltip içeriği - tek satırda
              String content = '';
              
              if (rodIndex == 0 && income > 0) {
                content = 'Gelir: ${_formatCompactNumber(income)}₺ • $formattedDate';
              } else if (rodIndex == 1 && expense > 0) {
                content = 'Gider: ${_formatCompactNumber(expense)}₺ • $formattedDate';
              }
              
              return BarTooltipItem(
                content,
                TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _processDataForViewMode(
    List<DateTime> dates,
    Map<DateTime, Map<String, double>> groupedData,
  ) {
    switch (_viewMode) {
      case ChartViewMode.overview:
        return _processOverviewData(dates, groupedData);
      case ChartViewMode.detailed:
        return _processDetailedData(dates, groupedData);
      case ChartViewMode.comparison:
        return _processComparisonData(dates, groupedData);
    }
  }

  Map<String, dynamic> _processOverviewData(
    List<DateTime> dates,
    Map<DateTime, Map<String, double>> groupedData,
  ) {
    // For overview, show every nth date based on data density
    final List<DateTime> visibleDates = [];
    final Map<DateTime, Map<String, double>> sampledData = {};
    
    for (int i = 0; i < dates.length; i += _dateInterval) {
      if (i < dates.length) {
        visibleDates.add(dates[i]);
        sampledData[dates[i]] = groupedData[dates[i]]!;
      }
    }
    
    return {
      'dates': visibleDates,
      'data': sampledData,
    };
  }

  Map<String, dynamic> _processDetailedData(
    List<DateTime> dates,
    Map<DateTime, Map<String, double>> groupedData,
  ) {
    // For detailed view, show recent data with full detail
    final recentCount = dates.length > _maxVisibleBars ? _maxVisibleBars : dates.length;
    final recentDates = dates.sublist(dates.length - recentCount);
    final Map<DateTime, Map<String, double>> detailedData = {};
    
    for (final date in recentDates) {
      detailedData[date] = groupedData[date]!;
    }
    
    return {
      'dates': recentDates,
      'data': detailedData,
    };
  }

  Map<String, dynamic> _processComparisonData(
    List<DateTime> dates,
    Map<DateTime, Map<String, double>> groupedData,
  ) {
    // For comparison, show key data points (beginning, middle, end)
    final List<DateTime> comparisonDates = [];
    final Map<DateTime, Map<String, double>> comparisonData = {};
    
    if (dates.length >= 3) {
      // Beginning, middle, end
      comparisonDates.addAll([
        dates.first,
        dates[dates.length ~/ 2],
        dates.last,
      ]);
    } else {
      comparisonDates.addAll(dates);
    }
    
    for (final date in comparisonDates) {
      comparisonData[date] = groupedData[date]!;
    }
    
    return {
      'dates': comparisonDates,
      'data': comparisonData,
    };
  }


  String _formatDateForChart(DateTime date) {
    // Pad with zero if needed (01, 02, etc.)
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    
    switch (_viewMode) {
      case ChartViewMode.overview:
        return '$month.$day';
      case ChartViewMode.detailed:
        return '$month.$day';
      case ChartViewMode.comparison:
        return '$month.$day.${date.year.toString().substring(2)}';
    }
  }

  String _formatDateForTooltip(DateTime date) {
    final monthNames = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    
    final monthName = monthNames[date.month - 1];
    
    // Kısa format: 15 Eyl 2024
    return '${date.day} $monthName ${date.year}';
  }

  String _formatCompactNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Veri bulunamadı',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          'Gelir',
          Colors.green,
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          context,
          'Gider',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

}
