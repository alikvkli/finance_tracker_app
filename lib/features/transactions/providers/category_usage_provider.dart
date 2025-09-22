import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryUsageProvider extends StateNotifier<Map<String, int>> {
  CategoryUsageProvider() : super({}) {
    _loadUsageData();
  }

  static const String _usageKey = 'category_usage_count';

  Future<void> _loadUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usageData = prefs.getString(_usageKey);
      if (usageData != null) {
        final Map<String, dynamic> decoded = json.decode(usageData);
        state = decoded.map((key, value) => MapEntry(key, value as int));
      }
    } catch (e) {
      // Hata durumunda boş map kullan
      state = {};
    }
  }

  Future<void> _saveUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usageKey, json.encode(state));
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  void incrementUsage(String categoryId) {
    state = {
      ...state,
      categoryId: (state[categoryId] ?? 0) + 1,
    };
    _saveUsageData();
  }

  List<String> getMostUsedCategories({int limit = 6}) {
    final sortedEntries = state.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEntries
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  bool isFrequentlyUsed(String categoryId) {
    return getMostUsedCategories().contains(categoryId);
  }
}

final categoryUsageProvider = StateNotifierProvider<CategoryUsageProvider, Map<String, int>>(
  (ref) => CategoryUsageProvider(),
);
