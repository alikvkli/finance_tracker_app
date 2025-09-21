/// Extension for formatting amounts and numbers
extension AmountFormattingExtension on num {
  /// Formats amount with Turkish Lira symbol and thousand separators
  String formatAsTurkishLira() {
    final integerPart = floor();
    final formattedAmount = integerPart.toString().addThousandSeparators();
    return '₺$formattedAmount';
  }

  /// Formats amount for display with Turkish Lira symbol
  /// Handles decimal places properly
  String formatForDisplay() {
    // Ondalık kısmı var mı kontrol et
    if (this == floor()) {
      // Tam sayı ise ondalık gösterme
      final integerPart = floor().toString();
      return integerPart.addThousandSeparators();
    } else {
      // Ondalık varsa göster
      final parts = toString().split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '';

      // Ondalık kısmını 2 haneli yap
      final formattedDecimal = decimalPart.padRight(2, '0').substring(0, 2);

      return '${integerPart.addThousandSeparators()},$formattedDecimal';
    }
  }

  /// Formats amount for dashboard display (with K, M suffixes)
  String formatForDashboard() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    } else {
      return toStringAsFixed(0);
    }
  }
}

/// Extension for dynamic amount formatting
extension DynamicAmountFormattingExtension on dynamic {
  /// Formats dynamic amount (String, int, double) as Turkish Lira
  String formatAsTurkishLira() {
    double amountValue;
    if (this is String) {
      amountValue = double.tryParse(this as String) ?? 0.0;
    } else if (this is num) {
      amountValue = (this as num).toDouble();
    } else {
      amountValue = 0.0;
    }

    final integerPart = amountValue.floor();
    final formattedAmount = integerPart.toString().addThousandSeparators();
    return '₺$formattedAmount';
  }
}

/// Extension for string number formatting
extension StringNumberFormattingExtension on String {
  /// Adds thousand separators to a number string
  String addThousandSeparators() {
    if (isEmpty) return this;

    // Regex ile binlik ayırıcı ekle (nokta kullanarak)
    return replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );
  }

  /// Formats number string with separators and decimal handling
  String formatNumberWithSeparators() {
    if (isEmpty) return this;

    // Virgül varsa, ondalık kısmını ayır
    String integerPart = this;
    String decimalPart = '';

    if (contains(',')) {
      final parts = split(',');
      integerPart = parts[0];
      decimalPart = parts.length > 1 ? parts[1] : '';
    }

    // Tam sayı kısmını binlik ayırıcılarla formatla
    if (integerPart.isNotEmpty) {
      final number = int.tryParse(integerPart);
      if (number != null) {
        integerPart = number.toString().addThousandSeparators();
      }
    }

    // Ondalık kısmını ekle
    if (decimalPart.isNotEmpty) {
      return '$integerPart,$decimalPart';
    }

    return integerPart;
  }
}
