/// Models for transaction statistics API response

class StatisticsResponse {
  final bool success;
  final String message;
  final StatisticsData data;

  const StatisticsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: StatisticsData.fromJson(json['data'] ?? {}),
    );
  }
}

class StatisticsData {
  final SummaryStats summary;
  final List<CategoryStats> categoryStats;
  final List<DailyStats> dailyStats;
  final DateRange dateRange;

  const StatisticsData({
    required this.summary,
    required this.categoryStats,
    required this.dailyStats,
    required this.dateRange,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      summary: SummaryStats.fromJson(json['summary'] ?? {}),
      categoryStats: (json['category_stats'] as List<dynamic>?)
          ?.map((item) => CategoryStats.fromJson(item))
          .toList() ?? [],
      dailyStats: (json['daily_stats'] as List<dynamic>?)
          ?.map((item) => DailyStats.fromJson(item))
          .toList() ?? [],
      dateRange: DateRange.fromJson(json['date_range'] ?? {}),
    );
  }
}

class SummaryStats {
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final int transactionCount;

  const SummaryStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.transactionCount,
  });

  factory SummaryStats.fromJson(Map<String, dynamic> json) {
    return SummaryStats(
      totalIncome: double.tryParse(json['total_income']?.toString() ?? '0') ?? 0.0,
      totalExpense: double.tryParse(json['total_expense']?.toString() ?? '0') ?? 0.0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transaction_count'] ?? 0,
    );
  }
}

class CategoryStats {
  final String categoryId;
  final String type;
  final double totalAmount;
  final int transactionCount;
  final CategoryInfo category;

  const CategoryStats({
    required this.categoryId,
    required this.type,
    required this.totalAmount,
    required this.transactionCount,
    required this.category,
  });

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      categoryId: json['category_id']?.toString() ?? '',
      type: json['type'] ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      transactionCount: int.tryParse(json['transaction_count']?.toString() ?? '0') ?? 0,
      category: CategoryInfo.fromJson(json['category'] ?? {}),
    );
  }
}

class CategoryInfo {
  final int id;
  final String name;
  final String nameTr;
  final String nameEn;
  final String type;
  final String icon;
  final String color;

  const CategoryInfo({
    required this.id,
    required this.name,
    required this.nameTr,
    required this.nameEn,
    required this.type,
    required this.icon,
    required this.color,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameTr: json['name_tr'] ?? '',
      nameEn: json['name_en'] ?? '',
      type: json['type'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#000000',
    );
  }
}

class DailyStats {
  final DateTime transactionDate;
  final String type;
  final double totalAmount;

  const DailyStats({
    required this.transactionDate,
    required this.type,
    required this.totalAmount,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      transactionDate: DateTime.tryParse(json['transaction_date'] ?? '') ?? DateTime.now(),
      type: json['type'] ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
    );
  }
}
