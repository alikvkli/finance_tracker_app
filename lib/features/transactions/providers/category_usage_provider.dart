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

  void decrementUsage(String categoryId) {
    final currentCount = state[categoryId] ?? 0;
    if (currentCount > 0) {
      final newCount = currentCount - 1;
      if (newCount == 0) {
        // Eğer sayı 0'a düşerse, kategoriyi state'den tamamen kaldır
        final newState = Map<String, int>.from(state);
        newState.remove(categoryId);
        state = newState;
      } else {
        // Sayıyı azalt
        state = {
          ...state,
          categoryId: newCount,
        };
      }
      _saveUsageData();
    }
  }

  List<String> getMostUsedCategories({int limit = 6}) {
    // Sadece sayısı 0'dan büyük olan kategorileri al
    final validEntries = state.entries.where((entry) => entry.value > 0).toList();
    
    final sortedEntries = validEntries
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
