import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_controller.dart';
import '../models/categories_api_model.dart';
import '../../../core/di/injection.dart';

class TransactionFilters extends ConsumerStatefulWidget {
  const TransactionFilters({super.key});

  @override
  ConsumerState<TransactionFilters> createState() => _TransactionFiltersState();
}

class _TransactionFiltersState extends ConsumerState<TransactionFilters> {
  final TextEditingController _searchController = TextEditingController();
  List<CategoriesApiModel> _categories = [];
  bool _isLoadingCategories = false;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _localSearchQuery;
  int? _localSelectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    // Initialize search controller and date range with current values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transactionState = ref.read(transactionControllerProvider);
      if (transactionState.searchQuery != null) {
        _searchController.text = transactionState.searchQuery!;
      }
      setState(() {
        _selectedStartDate = transactionState.selectedStartDate;
        _selectedEndDate = transactionState.selectedEndDate;
        _localSearchQuery = transactionState.searchQuery;
        _localSelectedCategoryId = transactionState.selectedCategoryId;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final transactionService = ref.read(transactionServiceProvider);
      final response = await transactionService.getCategories();
      setState(() {
        _categories = response.data;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionControllerProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'İşlem ara...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _localSearchQuery = null;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      // Don't apply filter immediately, just update local state
                      // Filter will be applied when "Filtreleri Uygula" is pressed
                      setState(() {
                        _localSearchQuery = value.isEmpty ? null : value;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Date Range Filter
                _buildDateRangeSection(context),
                
                const SizedBox(height: 20),
                
                // Category Filter Header
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kategoriler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Category Filter
                if (_isLoadingCategories)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildCategorySections(context, transactionState),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    // Clear Button (only show if there are active filters)
                    if (_hasActiveFilters())
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _searchController.clear();
                            _selectCurrentMonth(); // Reset local state to current month
                            setState(() {
                              _localSearchQuery = null;
                              _localSelectedCategoryId = null;
                            });
                            ref.read(transactionControllerProvider.notifier).clearFilters(); // This now resets date range too
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Temizle',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    
                    if (_hasActiveFilters()) const SizedBox(width: 12),
                    
                    // Apply Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Apply all filter changes
                          if (_selectedStartDate != null && _selectedEndDate != null) {
                            ref.read(transactionControllerProvider.notifier).updateDateRange(_selectedStartDate!, _selectedEndDate!);
                          }
                          
                          // Apply search query
                          ref.read(transactionControllerProvider.notifier).updateSearchQuery(_localSearchQuery);
                          
                          // Apply category filter
                          if (_localSelectedCategoryId != null) {
                            ref.read(transactionControllerProvider.notifier).updateCategoryFilter(_localSelectedCategoryId!);
                          } else {
                            ref.read(transactionControllerProvider.notifier).clearCategoryFilter();
                          }
                          
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Filtreleri Uygula',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Range Header
        Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Dönem Seçimi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _selectCurrentMonth(),
              child: const Text('Bu Ay'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _selectPreviousMonth(),
              child: const Text('Önceki Ay'),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Date Range Buttons
        if (_selectedStartDate != null && _selectedEndDate != null)
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  'Başlangıç',
                  _selectedStartDate!,
                  (date) => setState(() => _selectedStartDate = date),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateSelector(
                  'Bitiş',
                  _selectedEndDate!,
                  (date) => setState(() => _selectedEndDate = date),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDateSelector(String title, DateTime selectedDate, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _selectCurrentMonth() {
    final now = DateTime.now();
    setState(() {
      _selectedStartDate = DateTime(now.year, now.month, 1);
      _selectedEndDate = DateTime(now.year, now.month + 1, 0);
    });
  }

  void _selectPreviousMonth() {
    final now = DateTime.now();
    final previousMonth = now.month == 1 ? 12 : now.month - 1;
    final previousYear = now.month == 1 ? now.year - 1 : now.year;
    
    setState(() {
      _selectedStartDate = DateTime(previousYear, previousMonth, 1);
      _selectedEndDate = DateTime(previousYear, previousMonth + 1, 0);
    });
  }

  bool _hasActiveFilters() {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0);
    
    return _localSearchQuery != null || 
           _localSelectedCategoryId != null ||
           (_selectedStartDate != null && _selectedStartDate != currentMonthStart) ||
           (_selectedEndDate != null && _selectedEndDate != currentMonthEnd);
  }

  Widget _buildCategorySections(BuildContext context, TransactionState transactionState) {
    // Kategorileri type'a göre ayır
    final incomeCategories = _categories.where((c) => c.type == 'income').toList();
    final expenseCategories = _categories.where((c) => c.type == 'expense').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gelir Kategorileri
        if (incomeCategories.isNotEmpty) ...[
          _buildCategorySectionHeader(context, 'Gelir Kategorileri', Icons.trending_up, Colors.green),
          const SizedBox(height: 8),
          _buildCategoryList(context, incomeCategories, transactionState),
          const SizedBox(height: 16),
        ],
        
        // Gider Kategorileri
        if (expenseCategories.isNotEmpty) ...[
          _buildCategorySectionHeader(context, 'Gider Kategorileri', Icons.trending_down, Colors.red),
          const SizedBox(height: 8),
          _buildCategoryList(context, expenseCategories, transactionState),
        ],
      ],
    );
  }


  Widget _buildCategorySectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context, List<CategoriesApiModel> categories, TransactionState transactionState) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _localSelectedCategoryId == category.id;
          final categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                // Don't apply filter immediately, just update local state
                // Filter will be applied when "Filtreleri Uygula" is pressed
                setState(() {
                  if (_localSelectedCategoryId == category.id) {
                    _localSelectedCategoryId = null; // Deselect if already selected
                  } else {
                    _localSelectedCategoryId = category.id; // Select new category
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? categoryColor.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? categoryColor
                        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconData(category.icon),
                      size: 18,
                      color: isSelected
                          ? categoryColor
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.nameTr,
                      style: TextStyle(
                        color: isSelected
                            ? categoryColor
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'salary':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'trending_up':
        return Icons.trending_up;
      case 'work':
        return Icons.work_outline;
      case 'more':
        return Icons.more_horiz;
      case 'receipt':
        return Icons.receipt;
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'movie':
        return Icons.movie;
      case 'credit_card':
        return Icons.credit_card;
      case 'account_balance':
        return Icons.account_balance;
      case 'checkroom':
        return Icons.checkroom;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'fastfood':
        return Icons.fastfood;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'flash_on':
        return Icons.flash_on;
      case 'water_drop':
        return Icons.water_drop;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'wifi':
        return Icons.wifi;
      case 'phone':
        return Icons.phone;
      case 'currency_bitcoin':
        return Icons.currency_bitcoin;
      case 'receipt_long':
        return Icons.receipt_long;
      default:
        return Icons.category;
    }
  }
}
