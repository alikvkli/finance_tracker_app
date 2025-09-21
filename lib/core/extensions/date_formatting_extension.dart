/// Extension for formatting dates with Turkish localization
extension DateFormattingExtension on DateTime {
  /// Turkish month names
  static const List<String> _turkishMonths = [
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

  /// Formats date for transaction display with relative dates
  String formatForTransaction() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(year, month, day);

    if (transactionDate == today) {
      return 'Bugün';
    } else if (transactionDate == yesterday) {
      return 'Dün';
    } else {
      return '${day} ${_turkishMonths[month - 1]}';
    }
  }

  /// Formats date for dashboard display with relative dates
  String formatForDashboard() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(year, month, day);

    // Gün farkını doğru hesapla
    final difference = today.difference(transactionDate).inDays;

    if (difference == 0) {
      return 'Bugün';
    } else if (difference == 1) {
      return 'Dün';
    } else if (difference < 7 && difference > 0) {
      return '$difference gün önce';
    } else {
      return '${day} ${_turkishMonths[month - 1]} ${year}';
    }
  }

  /// Formats date for recurring transactions
  String formatForRecurring() {
    return '${day} ${_turkishMonths[month - 1]} ${year}';
  }

  /// Formats date for general display with full date
  String formatForDisplay() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }
}
