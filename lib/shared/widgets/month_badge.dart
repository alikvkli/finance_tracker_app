import 'package:flutter/material.dart';

class MonthBadge extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const MonthBadge({
    super.key,
    this.startDate,
    this.endDate,
  });

  // Current month constructor
  MonthBadge.current({super.key}) 
    : startDate = null,
      endDate = null;

  // Date range constructor
  MonthBadge.dateRange({
    super.key,
    required DateTime start,
    required DateTime end,
  }) : startDate = start,
       endDate = end;

  @override
  Widget build(BuildContext context) {
    final monthText = _getMonthText();

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

  String _getMonthText() {
    final monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    // If no dates provided, show current month
    if (startDate == null || endDate == null) {
      final now = DateTime.now();
      return monthNames[now.month - 1];
    }

    // Format date range
    if (startDate!.year == endDate!.year && startDate!.month == endDate!.month) {
      // Same month
      return '${monthNames[startDate!.month - 1]} ${startDate!.year}';
    } else if (startDate!.year == endDate!.year) {
      // Same year, different months
      return '${monthNames[startDate!.month - 1]} - ${monthNames[endDate!.month - 1]} ${startDate!.year}';
    } else {
      // Different years
      return '${monthNames[startDate!.month - 1]} ${startDate!.year} - ${monthNames[endDate!.month - 1]} ${endDate!.year}';
    }
  }
}
