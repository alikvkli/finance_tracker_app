import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/categories_api_model.dart';
import '../services/transaction_service.dart';
import '../../../core/di/injection.dart';

class CategoryState {
  final List<CategoriesApiModel> categories;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  CategoryState copyWith({
    List<CategoriesApiModel>? categories,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasData => categories.isNotEmpty;
  bool get isStale {
    if (lastUpdated == null) return true;
    return DateTime.now().difference(lastUpdated!).inMinutes > 5; // 5 dakika cache
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier(this._transactionService) : super(const CategoryState());

  final TransactionService _transactionService;

  Future<void> loadCategories({bool forceRefresh = false}) async {
    // Eğer veri varsa ve fresh ise, yeniden yükleme
    if (!forceRefresh && state.hasData && !state.isStale) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _transactionService.getCategories();
      state = state.copyWith(
        categories: response.data,
        isLoading: false,
        lastUpdated: DateTime.now(),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearCache() {
    state = const CategoryState();
  }

  void refreshCategories() {
    loadCategories(forceRefresh: true);
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final transactionService = ref.read(transactionServiceProvider);
  return CategoryNotifier(transactionService);
});

// Kategorileri kolayca erişmek için computed provider
final categoriesProvider = Provider<List<CategoriesApiModel>>((ref) {
  final categoryState = ref.watch(categoryProvider);
  return categoryState.categories;
});

// Loading durumunu kontrol etmek için
final categoriesLoadingProvider = Provider<bool>((ref) {
  final categoryState = ref.watch(categoryProvider);
  return categoryState.isLoading;
});

// Error durumunu kontrol etmek için
final categoriesErrorProvider = Provider<String?>((ref) {
  final categoryState = ref.watch(categoryProvider);
  return categoryState.error;
});
