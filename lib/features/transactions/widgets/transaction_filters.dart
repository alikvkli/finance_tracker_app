import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_controller.dart';
import '../models/categories_api_model.dart';
import '../providers/category_provider.dart';

class TransactionFilters extends ConsumerStatefulWidget {
  const TransactionFilters({super.key});

  @override
  ConsumerState<TransactionFilters> createState() => _TransactionFiltersState();
}

class _TransactionFiltersState extends ConsumerState<TransactionFilters> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _localSearchQuery;
  int? _localSelectedCategoryId;
  bool _isInitialized = false;
  String _selectedCategoryType = 'income'; // 'income', 'expense'

  @override
  void initState() {
    super.initState();
    // Kategorileri yükle (cache'den veya API'den)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).loadCategories();
    });

    // Initialize search controller and date range with current values
    _initializeWithCurrentState();
      }

  void _initializeWithCurrentState() {
    final transactionState = ref.read(transactionControllerProvider);
    _searchController.text = transactionState.searchQuery ?? '';
      setState(() {
        _selectedStartDate = transactionState.selectedStartDate;
        _selectedEndDate = transactionState.selectedEndDate;
        _localSearchQuery = transactionState.searchQuery;
        _localSelectedCategoryId = transactionState.selectedCategoryId;
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionControllerProvider);
    final categories = ref.watch(categoriesProvider);
    final isLoadingCategories = ref.watch(categoriesLoadingProvider);

    // Sync local state with current transaction state only once
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeWithCurrentState();
        }
      });
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
                Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtreler',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'İşlemlerinizi filtreleyerek arayın',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isLoadingCategories
                ? _buildFiltersSkeleton(context)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Section
                        _buildSearchSection(context),
                        const SizedBox(height: 24),

                        // Date Range Section
                        _buildDateRangeSection(context),
                        const SizedBox(height: 24),

                        // Category Section
                        _buildCategorySections(context, transactionState, categories),
                        const SizedBox(height: 32),

                        // Action Buttons
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Skeleton
          _buildSkeletonSection('Arama', [
            _buildSkeletonContainer(height: 48),
          ]),
          const SizedBox(height: 24),
          
          // Date Range Skeleton
          _buildSkeletonSection('Dönem Seçimi', [
            Row(
              children: [
                Expanded(child: _buildSkeletonContainer(height: 56)),
                const SizedBox(width: 12),
                Expanded(child: _buildSkeletonContainer(height: 56)),
              ],
            ),
          ]),
          const SizedBox(height: 24),
          
          // Categories Skeleton
          _buildSkeletonSection('Kategoriler', [
            _buildSkeletonContainer(height: 50),
            const SizedBox(height: 12),
            _buildSkeletonContainer(height: 50),
          ]),
          const SizedBox(height: 32),
          
          // Buttons Skeleton
          Row(
            children: [
              Expanded(child: _buildSkeletonContainer(height: 48, borderRadius: 12)),
              const SizedBox(width: 12),
              Expanded(child: _buildSkeletonContainer(height: 48, borderRadius: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSkeletonContainer(width: 20, height: 20, isCircle: true),
            const SizedBox(width: 8),
            _buildSkeletonContainer(width: 100, height: 16),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSkeletonContainer({
    double? width,
    double? height,
    double? borderRadius,
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height ?? 16,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: isCircle 
            ? BorderRadius.circular((height ?? 16) / 2)
            : BorderRadius.circular(borderRadius ?? 8),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
                        Icons.search,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Arama',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'İşlem açıklaması...',
            suffixIcon: (_localSearchQuery?.isNotEmpty ?? false)
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _localSearchQuery = value.isEmpty ? null : value;
                      });
                    },
                  ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
                  children: [
                    // Clear Button (only show if there are active filters)
                    if (_hasActiveFilters())
                      Expanded(
            child: OutlinedButton.icon(
                          onPressed: () {
                            _searchController.clear();
                _selectCurrentMonth();
                            setState(() {
                              _localSearchQuery = null;
                              _localSelectedCategoryId = null;
                            });
                ref.read(transactionControllerProvider.notifier).clearFilters();
                            Navigator.pop(context);
                          },
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Temizle'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                    if (_hasActiveFilters()) const SizedBox(width: 12),

                    // Apply Button
                    Expanded(
          child: ElevatedButton.icon(
                        onPressed: () {
              print('🔍 Applying filters:');
              print('📅 Date: $_selectedStartDate to $_selectedEndDate');
              print('🔍 Search: $_localSearchQuery');
              print('🏷️ Category: $_localSelectedCategoryId');
              
              // Apply all filters at once to prevent multiple API calls
              ref.read(transactionControllerProvider.notifier).applyFilters(
                startDate: _selectedStartDate,
                endDate: _selectedEndDate,
                searchQuery: _localSearchQuery,
                categoryId: _localSelectedCategoryId,
                clearCategory: _localSelectedCategoryId == null,
              );

                          Navigator.pop(context);
                        },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Uygula'),
                        style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
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
              onPressed: () => _selectPreviousMonth(),
              child: const Text('Geçen Ay'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _selectCurrentMonth(),
              child: const Text('Bu Ay'),
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

  Widget _buildDateSelector(
    String title,
    DateTime selectedDate,
    Function(DateTime) onChanged,
  ) {
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
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

  Widget _buildCategorySections(
    BuildContext context,
    TransactionState transactionState,
    List<CategoriesApiModel> categories,
  ) {
    // Kategorileri type'a göre ayır
    final incomeCategories = categories.where((c) => c.type == 'income').toList();
    final expenseCategories = categories.where((c) => c.type == 'expense').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori Header
        Row(
          children: [
            Icon(
              Icons.apps_rounded,
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
            if (_localSelectedCategoryId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Seçili',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 11,
                        fontWeight: FontWeight.w600,
                  ),
                    ),
                  ],
                ),
              ),
          ],
        ),

          const SizedBox(height: 16),

        // Category Selection
        _buildCategoryDropdown(context, incomeCategories, expenseCategories),
      ],
    );
  }

  Widget _buildCategoryDropdown(
    BuildContext context, 
    List<CategoriesApiModel> incomeCategories, 
    List<CategoriesApiModel> expenseCategories
  ) {
    final allCategories = [...incomeCategories, ...expenseCategories];
    CategoriesApiModel? selectedCategory;
    if (_localSelectedCategoryId != null) {
      try {
        selectedCategory = allCategories.firstWhere(
          (cat) => cat.id == _localSelectedCategoryId,
        );
      } catch (e) {
        selectedCategory = null;
      }
    }

    return GestureDetector(
      onTap: () => _showCategoryPicker(context, incomeCategories, expenseCategories),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _localSelectedCategoryId == null 
                ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.primary,
            width: _localSelectedCategoryId == null ? 1 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
      children: [
            if (_localSelectedCategoryId != null && selectedCategory != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _parseColor(selectedCategory.color),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconData(selectedCategory.icon),
                  color: Colors.white,
          size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
        Text(
                      selectedCategory.nameTr,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      selectedCategory.type == 'income' ? 'Gelir' : 'Gider',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
          ),
        ),
      ],
                ),
              ),
            ] else ...[
              Expanded(
                child: Text(
                  'Kategori seçiniz (tümü)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(
    BuildContext context,
    List<CategoriesApiModel> incomeCategories,
    List<CategoriesApiModel> expenseCategories,
  ) {
    // Seçili kategorinin türünü belirle
    if (_localSelectedCategoryId != null) {
      final allCategories = [...incomeCategories, ...expenseCategories];
      try {
        final selectedCategory = allCategories.firstWhere(
          (cat) => cat.id == _localSelectedCategoryId,
        );
        _selectedCategoryType = selectedCategory.type;
      } catch (e) {
        _selectedCategoryType = 'income';
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.apps_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kategori Seçiniz',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Category Type Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModalTypeButton(
                        context, 
                        setModalState, 
                        'income', 
                        'Gelir', 
                        Icons.trending_up, 
                        const Color(0xFF059669),
                        incomeCategories,
                        expenseCategories,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModalTypeButton(
                        context, 
                        setModalState, 
                        'expense', 
                        'Gider', 
                        Icons.trending_down, 
                        const Color(0xFFDC2626),
                        incomeCategories,
                        expenseCategories,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Categories List based on selected type
              Expanded(
                child: _buildModalFilteredCategoriesList(context, setModalState, incomeCategories, expenseCategories),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalTypeButton(
    BuildContext context,
    StateSetter setModalState,
    String type,
    String label,
    IconData icon,
    Color color,
    List<CategoriesApiModel> incomeCategories,
    List<CategoriesApiModel> expenseCategories,
  ) {
    final isSelected = _selectedCategoryType == type;
    
    return GestureDetector(
              onTap: () {
        setModalState(() {
          _selectedCategoryType = type;
          // Seçili kategori varsa ve yeni türe uygun değilse temizle
          if (_localSelectedCategoryId != null) {
            final allCategories = [...incomeCategories, ...expenseCategories];
            try {
              final selectedCategory = allCategories.firstWhere(
                (cat) => cat.id == _localSelectedCategoryId,
              );
              
              // Eğer seçili kategori yeni türe uygun değilse temizle
              if (selectedCategory.type != type) {
                _localSelectedCategoryId = null;
              }
            } catch (e) {
              _localSelectedCategoryId = null;
            }
                  }
                });
              },
              child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
                  border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
                  children: [
                    Icon(
              icon,
              color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(height: 4),
                    Text(
              label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildModalFilteredCategoriesList(
    BuildContext context,
    StateSetter setModalState,
    List<CategoriesApiModel> incomeCategories,
    List<CategoriesApiModel> expenseCategories,
  ) {
    List<CategoriesApiModel> categoriesToShow = [];
    
    switch (_selectedCategoryType) {
      case 'income':
        categoriesToShow = incomeCategories;
        break;
      case 'expense':
        categoriesToShow = expenseCategories;
        break;
      default:
        categoriesToShow = incomeCategories;
        break;
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // Clear selection option
        _buildModalCategoryOption(
          context,
          setModalState,
          null,
          'Kategori Seçimi Kaldır',
          '${_selectedCategoryType == 'income' ? 'Gelir' : 'Gider'} kategorisi filtresini kaldır',
          Icons.clear_all,
          Theme.of(context).colorScheme.primary,
        ),
        
        const SizedBox(height: 8),
        
        // Categories
        ...categoriesToShow.map((cat) => _buildModalCategoryOption(
          context,
          setModalState,
          cat.id,
          cat.nameTr,
          '${cat.type == 'income' ? 'Gelir' : 'Gider'} kategorisi',
          _getIconData(cat.icon),
          _parseColor(cat.color),
        )),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildModalCategoryOption(
    BuildContext context,
    StateSetter setModalState,
    int? categoryId,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _localSelectedCategoryId == categoryId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          setModalState(() {
            _localSelectedCategoryId = categoryId;
          });
          setState(() {
            _localSelectedCategoryId = categoryId;
          });
          Navigator.pop(context);
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? color : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: isSelected 
            ? Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isSelected 
            ? color.withValues(alpha: 0.1)
            : null,
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.grey;
    }
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