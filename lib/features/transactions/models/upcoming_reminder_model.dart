class UpcomingReminderModel {
  final String date;
  final String dayName;
  final String dayNameTr;
  final Map<String, ReminderData> reminders;

  const UpcomingReminderModel({
    required this.date,
    required this.dayName,
    required this.dayNameTr,
    required this.reminders,
  });

  factory UpcomingReminderModel.fromJson(Map<String, dynamic> json) {
    final remindersJson = json['reminders'] as Map<String, dynamic>? ?? {};
    
    final reminders = remindersJson.map(
      (key, value) => MapEntry(
        key,
        ReminderData.fromJson(value as Map<String, dynamic>),
      ),
    );

    return UpcomingReminderModel(
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? '',
      dayNameTr: json['day_name_tr'] ?? '',
      reminders: reminders,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day_name': dayName,
      'day_name_tr': dayNameTr,
      'reminders': reminders.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

class ReminderData {
  final int id;
  final String category;
  final String type;
  final String amount;
  final String recurringType;

  const ReminderData({
    required this.id,
    required this.category,
    required this.type,
    required this.amount,
    required this.recurringType,
  });

  factory ReminderData.fromJson(Map<String, dynamic> json) {
    return ReminderData(
      id: json['id'] ?? 0,
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      amount: json['amount'] ?? '',
      recurringType: json['recurring_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'type': type,
      'amount': amount,
      'recurring_type': recurringType,
    };
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}
