import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/statistics_models.dart';
import '../../../core/extensions/category_icon_extension.dart';
import '../../../core/extensions/color_extension.dart';
import '../../../core/extensions/amount_formatting_extension.dart';

/// Widget to display category-based statistics with pie chart
class CategoryStatisticsWidget extends ConsumerStatefulWidget {
  final List<CategoryStats> categories;
  final String title;
  final Color accentColor;

  const CategoryStatisticsWidget({
    super.key,
    required this.categories,
    required this.title,
    required this.accentColor,
  });

  @override
  ConsumerState<CategoryStatisticsWidget> createState() => _CategoryStatisticsWidgetState();
}

class _CategoryStatisticsWidgetState extends ConsumerState<CategoryStatisticsWidget> {
  int _touchedIndex = -1;
  bool _showAllCategories = false;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate total amount for percentage calculations
    final totalAmount = widget.categories.fold<double>(
      0.0,
      (sum, category) => sum + category.totalAmount,
    );

    // Group small categories into "Others" for cleaner pie chart
    final processedCategories = _processCategoriesForDisplay();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.accentColor,
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
                  '${widget.categories.length} kategori',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Pie Chart and Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                // Pie Chart Container with proper constraints
                Container(
                  width: 130,
                  height: 130,
                  padding: const EdgeInsets.all(8),
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 1.5,
                      centerSpaceRadius: 25,
                      sections: _buildPieChartSections(processedCategories, totalAmount),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Legend
                Expanded(
                  child: _buildCompactLegend(processedCategories, totalAmount),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }


  Map<String, dynamic> _processCategoriesForDisplay() {
    // Sort categories by amount (descending)
    final sortedCategories = List<CategoryStats>.from(widget.categories)
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    // Show top 5 categories + group others if more than 5
    final topCategories = sortedCategories.take(5).toList();
    final otherCategories = sortedCategories.skip(5).toList();

    final displayCategories = <CategoryStats>[];
    displayCategories.addAll(topCategories);

    // Group small categories into "Others"
    if (otherCategories.isNotEmpty) {
      final othersTotal = otherCategories.fold<double>(
        0.0,
        (sum, category) => sum + category.totalAmount,
      );

      // Create a synthetic "Others" category
      final othersCategory = CategoryStats(
        categoryId: 'others',
        type: 'expense',
        category: CategoryInfo(
          id: 999,
          name: 'Others',
          nameTr: 'Diğerleri',
          nameEn: 'Others',
          type: 'expense',
          icon: 'more_horiz',
          color: '#9E9E9E',
        ),
        totalAmount: othersTotal,
        transactionCount: otherCategories.fold<int>(
          0,
          (sum, category) => sum + category.transactionCount,
        ),
      );

      displayCategories.add(othersCategory);
    }

    return {
      'displayCategories': displayCategories,
      'allCategories': widget.categories,
      'hasOthers': otherCategories.isNotEmpty,
    };
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, dynamic> processedData, double totalAmount) {
    final displayCategories = processedData['displayCategories'] as List<CategoryStats>;
    
    return displayCategories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final percentage = totalAmount > 0 ? (category.totalAmount / totalAmount) * 100 : 0.0;
      final categoryColor = category.category.color.parseColor();
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 50.0 : 42.0;

      // Only show percentage for very large slices (>10%) to keep chart clean
      final showPercentage = percentage >= 10.0;

      return PieChartSectionData(
        color: categoryColor,
        value: category.totalAmount,
        title: showPercentage ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 11 : 9,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        badgeWidget: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: categoryColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            category.category.icon.getCategoryIcon(),
            size: 7,
            color: categoryColor,
          ),
        ),
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }



  Widget _buildCompactLegend(Map<String, dynamic> processedData, double totalAmount) {
    final displayCategories = processedData['displayCategories'] as List<CategoryStats>;
    final allCategories = processedData['allCategories'] as List<CategoryStats>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show compact grid for display categories
        ...displayCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final percentage = totalAmount > 0 ? (category.totalAmount / totalAmount) * 100 : 0.0;
        final categoryColor = category.category.color.parseColor();
        final isTouched = index == _touchedIndex;

        return Padding(
            padding: const EdgeInsets.only(bottom: 6),
          child: InkWell(
            onTap: () {
              setState(() {
                _touchedIndex = _touchedIndex == index ? -1 : index;
              });
            },
              borderRadius: BorderRadius.circular(6),
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                  color: isTouched 
                    ? categoryColor.withValues(alpha: 0.08)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                    // Compact color indicator
                  Container(
                      width: 8,
                      height: 8,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                    const SizedBox(width: 6),
                    // Compact category icon
                  Icon(
                    category.category.icon.getCategoryIcon(),
                      size: 12,
                    color: categoryColor,
                  ),
                    const SizedBox(width: 4),
                    // Category name (truncated)
                  Expanded(
                    child: Text(
                      category.category.nameTr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isTouched 
                          ? categoryColor
                          : Theme.of(context).colorScheme.onSurface,
                          fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                    // Compact percentage and amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: categoryColor,
                            fontSize: 10,
                        ),
                      ),
                      Text(
                        category.totalAmount.formatAsTurkishLira(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),

        // Show "View All" button if there are more categories
        if (allCategories.length > 5) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              setState(() {
                _showAllCategories = !_showAllCategories;
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showAllCategories ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showAllCategories ? 'Daha Az Göster' : 'Tümünü Göster',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Show all categories in expanded view
          if (_showAllCategories) ...[
            const SizedBox(height: 8),
            ...allCategories.skip(5).map((category) {
              final percentage = totalAmount > 0 ? (category.totalAmount / totalAmount) * 100 : 0.0;
              final categoryColor = category.category.color.parseColor();

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      category.category.icon.getCategoryIcon(),
                      size: 10,
                      color: categoryColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        category.category.nameTr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: categoryColor,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ],
    );
  }
}
