/// Extension for formatting recurring transaction types
extension RecurringTextExtension on String? {
  /// Gets Turkish display text for recurring transaction type
  String getRecurringDisplayText() {
    switch (this) {
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
