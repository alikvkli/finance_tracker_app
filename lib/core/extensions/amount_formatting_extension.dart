/// Extension for formatting amounts and numbers
extension AmountFormattingExtension on num {
  /// Formats amount with Turkish Lira symbol and thousand separators
  String formatAsTurkishLira() {
    final integerPart = floor();
    final formattedAmount = integerPart.toString().addThousandSeparators();
    return '$formattedAmount₺';
  }

  /// Formats amount for display with Turkish Lira symbol
  /// Handles decimal places properly
  String formatForDisplay() {
    // Ondalık kısmı var mı kontrol et
    if (this == floor()) {
      // Tam sayı ise ondalık gösterme
      final integerPart = floor().toString();
      return '${integerPart.addThousandSeparators()}₺';
    } else {
      // Ondalık varsa göster
      final parts = toString().split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '';

      // Ondalık kısmını 2 haneli yap
      final formattedDecimal = decimalPart.padRight(2, '0').substring(0, 2);

      return '${integerPart.addThousandSeparators()},$formattedDecimal₺';
    }
  }

  /// Formats amount for dashboard display with thousand separators
  String formatForDashboard() {
    final integerPart = floor();
    final formattedAmount = integerPart.toString().addThousandSeparators();
    return '$formattedAmount₺';
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
    return '$formattedAmount₺';
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

  /// Formats amount input with Turkish formatting (thousand separators and decimal handling)
  String formatAmountInput() {
    // Sadece rakam ve virgül karakterlerine izin ver (nokta sadece binlik ayırıcı olarak kullanılacak)
    final cleanValue = replaceAll(RegExp(r'[^\d,]'), '');

    // Virgül kontrolü - sadece bir tane olabilir
    final commaCount = cleanValue.split(',').length - 1;
    if (commaCount > 1) {
      return this; // Geçersiz format, değişiklik yapma
    }

    // Virgülden sonra maksimum 2 rakam
    if (cleanValue.contains(',')) {
      final parts = cleanValue.split(',');
      if (parts.length == 2 && parts[1].length > 2) {
        return this; // Virgülden sonra 2'den fazla rakam
      }
    }

    // Formatlanmış değeri hesapla
    return cleanValue.formatNumberWithSeparators();
  }

  /// Parses amount text input to double value
  double parseAmountFromText() {
    // Nokta ve virgül karakterlerini temizle
    String cleanText = replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleanText) ?? 0.0;
  }

  /// Formats amount for display with Turkish Lira symbol
  String formatAmountForDisplay() {
    final amount = parseAmountFromText();
    return amount.formatForDisplay();
  }
}
