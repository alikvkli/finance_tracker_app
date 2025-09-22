import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../models/categories_api_model.dart';
import '../models/add_transaction_request.dart';
import '../controllers/transaction_controller.dart';
import '../providers/category_provider.dart';
import '../providers/category_usage_provider.dart';
import '../../home/controllers/dashboard_controller.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/rewarded_ad_helper.dart';
import '../../../core/extensions/category_icon_extension.dart';

class EditTransactionModal extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const EditTransactionModal({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionModal> createState() =>
      _EditTransactionModalState();
}

class _EditTransactionModalState extends ConsumerState<EditTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'income';
  CategoriesApiModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String _recurringType = 'daily';
  DateTime? _recurringEndDate;

  bool _isSubmitting = false;
  bool _isFormValid = false;
  bool _hasUserInteracted = false;
  bool _hasTypeChanged = false;

  @override
  void initState() {
    super.initState();
    _initializeWithTransactionData();

    // Kategorileri yükle (cache'den veya API'den)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).loadCategories();
      _validateForm(forButtonState: true); // İlk button state'ini set et
    });
  }

  void _initializeWithTransactionData() {
    final transaction = widget.transaction;

    _selectedType = transaction.type;

    // Amount'u doğru formatta göster
    final amountValue = transaction.amountAsDouble;
    final formattedAmount = _formatAmountForDisplay(amountValue);
    _amountController.text = formattedAmount;

    _descriptionController.text = transaction.description ?? '';
    _selectedDate = transaction.transactionDate;
    _isRecurring = transaction.isRecurring;
    _recurringType = transaction.recurringType ?? 'daily';
    _recurringEndDate = transaction.recurringEndDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm({bool forButtonState = false}) {
    // Button state için her zaman validation yap, error mesajları için sadece user interaction sonrası
    if (!_hasUserInteracted && !forButtonState) return;

    final hasAmount = _amountController.text.trim().isNotEmpty;
    final hasCategory = _selectedCategory != null;
    final recurringValid = !_isRecurring || _recurringEndDate != null;

    final isValid = hasAmount && hasCategory && recurringValid;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  Future<void> _submitTransaction() async {
    // Submit'e basıldığında kullanıcının etkileşimde bulunduğunu işaretle
    if (!_hasUserInteracted) {
      setState(() {
        _hasUserInteracted = true;
      });
    }

    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      CustomSnackBar.showError(context, message: 'Lütfen bir kategori seçiniz');
      return;
    }

    // Rewarded ad ile işlemi gerçekleştir
    final success = await RewardedAdHelper.showRewardedAdForAction(
      context,
      ref,
      actionTitle: 'İşlemi Düzenle',
      actionDescription: 'İşlemi düzenlemek için kısa bir reklam izlemeniz gerekiyor.',
      onRewardEarned: () async {
        await _performTransactionUpdate();
      },
    );

    if (!success && context.mounted) {
      CustomSnackBar.showError(
        context,
        message: 'İşlem iptal edildi',
      );
    }
  }

  Future<void> _performTransactionUpdate() async {

    // Tekrarlayan işlem validation
    if (_isRecurring) {
      if (_recurringEndDate == null) {
        CustomSnackBar.showError(
          context,
          message: 'Tekrarlayan işlem için lütfen bitiş tarihi seçiniz',
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Miktarı temizle (binlik ayırıcıları kaldır)
      final cleanAmount = _amountController.text
          .trim()
          .replaceAll('.', '')
          .replaceAll(',', '.');

      final request = AddTransactionRequest(
        categoryId: _selectedCategory!.id,
        type: _selectedType,
        amount: cleanAmount,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        transactionDate: _formatDate(_selectedDate),
        currency: 'TRY',
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : null,
        recurringEndDate: _isRecurring && _recurringEndDate != null
            ? _formatDate(_recurringEndDate!)
            : null,
      );

      // Update transaction
      await ref
          .read(transactionControllerProvider.notifier)
          .updateTransaction(widget.transaction.id, request);

      // Kategori kullanımını artır (sadece kategori değiştiyse)
      if (widget.transaction.category.id != _selectedCategory!.id) {
        ref.read(categoryUsageProvider.notifier).incrementUsage(_selectedCategory!.id.toString());
      }

      // Hem dashboard hem de transactions listesini yenile
      await ref
          .read(transactionControllerProvider.notifier)
          .refreshTransactions();
      await ref.read(dashboardControllerProvider.notifier).refreshDashboard();

      // Kategorileri yenile (yeni kategori eklenmiş olabilir)
      ref.read(categoryProvider.notifier).refreshCategories();

      if (mounted) {
        Navigator.pop(context);
        CustomSnackBar.showSuccess(
          context,
          message: 'İşlem başarıyla güncellendi',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, message: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void _formatAmountInput(String value) {
    // Sadece rakam ve virgül karakterlerine izin ver (nokta sadece binlik ayırıcı olarak kullanılacak)
    final cleanValue = value.replaceAll(RegExp(r'[^\d,]'), '');

    // Virgül kontrolü - sadece bir tane olabilir
    final commaCount = cleanValue.split(',').length - 1;
    if (commaCount > 1) {
      return; // Geçersiz format, değişiklik yapma
    }

    // Virgülden sonra maksimum 2 rakam
    if (cleanValue.contains(',')) {
      final parts = cleanValue.split(',');
      if (parts.length == 2 && parts[1].length > 2) {
        return; // Virgülden sonra 2'den fazla rakam
      }
    }

    // Formatlanmış değeri hesapla
    String formattedValue = _formatNumberWithSeparators(cleanValue);

    // Eğer değer değiştiyse, controller'ı güncelle
    if (formattedValue != value) {
      _amountController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }
  }

  String _formatNumberWithSeparators(String value) {
    if (value.isEmpty) return value;

    // Virgül varsa, ondalık kısmını ayır
    String integerPart = value;
    String decimalPart = '';

    if (value.contains(',')) {
      final parts = value.split(',');
      integerPart = parts[0];
      decimalPart = parts.length > 1 ? parts[1] : '';
    }

    // Tam sayı kısmını binlik ayırıcılarla formatla
    if (integerPart.isNotEmpty) {
      final number = int.tryParse(integerPart);
      if (number != null) {
        integerPart = _addThousandSeparators(number.toString());
      }
    }

    // Ondalık kısmını ekle
    if (decimalPart.isNotEmpty) {
      return '$integerPart,$decimalPart';
    }

    return integerPart;
  }

  String _addThousandSeparators(String number) {
    if (number.isEmpty) return number;

    // Regex ile binlik ayırıcı ekle
    return number.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );
  }

  String _formatAmountForDisplay(double amount) {
    // Ondalık kısmı var mı kontrol et
    if (amount == amount.floor()) {
      // Tam sayı ise ondalık gösterme
      final integerPart = amount.floor().toString();
      return _addThousandSeparators(integerPart);
    } else {
      // Ondalık varsa göster
      final parts = amount.toString().split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '';

      // Ondalık kısmını 2 haneli yap
      final formattedDecimal = decimalPart.padRight(2, '0').substring(0, 2);

      return '${_addThousandSeparators(integerPart)},$formattedDecimal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final isLoading = ref.watch(categoriesLoadingProvider);
    final error = ref.watch(categoriesErrorProvider);

    return Container(
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
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İşlemi Düzenle',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        Text(
                          'İşlem bilgilerini güncelleyin',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: isLoading
                  ? _buildLoadingSkeleton()
                  : error != null
                  ? _buildErrorWidget(error)
                  : _buildForm(categories),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Type Skeleton
          _buildSkeletonSection('İşlem Türü', [
            Row(
              children: [
                Expanded(child: _buildSkeletonButton()),
                const SizedBox(width: 12),
                Expanded(child: _buildSkeletonButton()),
              ],
            ),
          ]),
          const SizedBox(height: 20),

          // Category Skeleton
          _buildSkeletonSection('Kategori Seçiniz', [
            _buildSkeletonContainer(height: 56),
          ]),
          const SizedBox(height: 20),

          // Amount Skeleton
          _buildSkeletonSection('Tutar', [_buildSkeletonContainer(height: 56)]),
          const SizedBox(height: 20),

          // Description Skeleton
          _buildSkeletonSection('Açıklama (İsteğe Bağlı)', [
            _buildSkeletonContainer(height: 80),
          ]),
          const SizedBox(height: 20),

          // Date Skeleton
          _buildSkeletonSection('Tarih', [_buildSkeletonContainer(height: 56)]),
          const SizedBox(height: 20),

          // Submit Button Skeleton
          _buildSkeletonContainer(height: 56, isButton: true),
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
            _buildSkeletonContainer(width: 120, height: 16),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildSkeletonContainer({
    double? width,
    double? height,
    bool isButton = false,
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height ?? 16,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: isCircle
            ? BorderRadius.circular((height ?? 16) / 2)
            : BorderRadius.circular(isButton ? 16 : 8),
      ),
      child: isButton
          ? Center(child: _buildSkeletonContainer(width: 100, height: 16))
          : null,
    );
  }

  Widget _buildSkeletonButton() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSkeletonContainer(width: 24, height: 24, isCircle: true),
          const SizedBox(height: 8),
          _buildSkeletonContainer(width: 60, height: 12),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Kategoriler Yüklenemedi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(categoryProvider.notifier)
                    .loadCategories(forceRefresh: true);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Deneyiniz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(List<CategoriesApiModel> categories) {
    // Set selected category to current transaction's category if not already set
    // Only do this if the type hasn't been changed by the user
    if (_selectedCategory == null && categories.isNotEmpty && !_hasTypeChanged) {
      try {
        _selectedCategory = categories.firstWhere(
          (category) => category.id == widget.transaction.category.id,
        );
      } catch (e) {
        // Category not found, keep as null
      }
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type
              _buildTypeSelector(),
              const SizedBox(height: 20),

              // Category Selector
              _buildCategorySelector(categories),
              const SizedBox(height: 20),

              // Amount
              _buildAmountField(),
              const SizedBox(height: 20),

              // Description
              _buildDescriptionField(),
              const SizedBox(height: 20),

              // Date
              _buildDateSelector(),
              const SizedBox(height: 20),

              // Recurring Options
              _buildRecurringOptions(),
              const SizedBox(height: 20),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İşlem Türü',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                'income',
                'Gelir',
                Colors.green,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeButton(
                'expense',
                'Gider',
                Colors.red,
                Icons.trending_down,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(
    String type,
    String label,
    Color color,
    IconData icon,
  ) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedCategory = null; // Reset category when type changes
          _hasTypeChanged = true; // Mark that type has been changed
        });
        _validateForm(
          forButtonState: true,
        ); // Button state'i için validation yap ama error mesajları gösterme
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? color
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? color
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? color
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(List<CategoriesApiModel> categories) {
    final filteredCategories = categories
        .where((cat) => cat.type == _selectedType)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.apps_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Kategori Seçiniz',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Custom kategori selector
        GestureDetector(
          onTap: () => _showCategoryPicker(filteredCategories),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedCategory == null
                    ? Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.primary,
                width: _selectedCategory == null ? 1 : 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (_selectedCategory != null) ...[
                  Icon(
                    _selectedCategory!.icon.getCategoryIcon(),
                    color: _parseColor(_selectedCategory!.color),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCategory!.nameTr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Text(
                      'Kategori seçiniz',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
        if (_hasUserInteracted && _selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(
              'Lütfen bir kategori seçiniz',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  void _showCategoryPicker(List<CategoriesApiModel> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final mostUsedCategoryIds = ref.read(categoryUsageProvider.notifier).getMostUsedCategories(limit: 6);
          
          // Kategorileri sık kullanılan ve diğerleri olarak ayır
          final frequentCategories = categories.where((cat) => mostUsedCategoryIds.contains(cat.id.toString())).toList();
          final otherCategories = categories.where((cat) => !mostUsedCategoryIds.contains(cat.id.toString())).toList();
          
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedType == 'income' ? 'Geliri hangi kategoriye' : 'Harcamayı hangi kategoriye',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(),
                            ),
                            Text(
                              'değiştirmek istersiniz?',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16), // 24'ten 16'ya düşürüldü
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sık Kullanılan Kategoriler
                        if (frequentCategories.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16, // 18'den 16'ya düşürüldü
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6), // 8'den 6'ya düşürüldü
                              Text(
                                'Sık Kullanılanlar',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13, // Font boyutu küçültüldü
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12), // 16'dan 12'ye düşürüldü
                          _buildCategoryGrid(frequentCategories),
                          const SizedBox(height: 16), // 24'ten 16'ya düşürüldü
                        ],
                        
                        // Diğer Kategoriler
                        if (otherCategories.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.category_rounded,
                                size: 16, // 18'den 16'ya düşürüldü
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 6), // 8'den 6'ya düşürüldü
                              Text(
                                'Tüm Kategoriler',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13, // Font boyutu küçültüldü
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12), // 16'dan 12'ye düşürüldü
                          _buildCategoryGrid(otherCategories),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid(List<CategoriesApiModel> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 3'ten 4'e çıkarıldı
        childAspectRatio: 0.75, // Daha kompakt
        crossAxisSpacing: 12, // 16'dan 12'ye düşürüldü
        mainAxisSpacing: 12, // 16'dan 12'ye düşürüldü
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category;
              _hasUserInteracted = true;
            });
            _validateForm();
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36, // 48'den 36'ya düşürüldü
                  height: 36, // 48'den 36'ya düşürüldü
                  decoration: BoxDecoration(
                    color: _parseColor(category.color),
                    borderRadius: BorderRadius.circular(10), // 12'den 10'a düşürüldü
                    boxShadow: [
                      BoxShadow(
                        color: _parseColor(
                          category.color,
                        ).withValues(alpha: 0.3),
                        blurRadius: 6, // 8'den 6'ya düşürüldü
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    category.icon.getCategoryIcon(),
                    color: Colors.white,
                    size: 20, // 24'ten 20'ye düşürüldü
                  ),
                ),
                const SizedBox(height: 8), // 12'den 8'e düşürüldü
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4, // 8'den 4'e düşürüldü
                  ),
                  child: Text(
                    category.nameTr,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                          fontSize: 11, // Font boyutu küçültüldü
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.money_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Tutar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            _formatAmountInput(value);
            if (!_hasUserInteracted) {
              setState(() {
                _hasUserInteracted = true;
              });
            }
            _validateForm();
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            hintText: '0,00',
            suffixText: '₺',
            prefixIcon: Icon(
              Icons.currency_lira,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (!_hasUserInteracted)
              return null; // Kullanıcı etkileşimde bulunmadıysa validation yapma

            if (value == null || value.isEmpty) {
              return 'Lütfen tutar giriniz';
            }
            // Formatlanmış değeri temizle ve kontrol et
            final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
            if (double.tryParse(cleanValue) == null) {
              return 'Lütfen geçerli bir tutar giriniz';
            }
            if (double.parse(cleanValue) <= 0) {
              return 'Tutar sıfırdan büyük olmalıdır';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Açıklama (İsteğe Bağlı)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) {
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            hintText: 'İşlem açıklaması...',
            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarih',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value ?? false;
                  if (!_isRecurring) {
                    _recurringEndDate = null;
                  }
                  _hasUserInteracted = true;
                });
                _validateForm();
              },
            ),
            Text(
              'Tekrarlayan İşlem',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
          ],
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 16),
          Text(
            'Tekrarlama Sıklığı',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _recurringType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Günlük')),
              DropdownMenuItem(value: 'weekly', child: Text('Haftalık')),
              DropdownMenuItem(value: 'monthly', child: Text('Aylık')),
              DropdownMenuItem(value: 'yearly', child: Text('Yıllık')),
            ],
            onChanged: (value) {
              setState(() {
                _recurringType = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Bitiş Tarihi',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tekrarlayan işlemin hangi tarihe kadar devam edeceğini belirtiniz. Böylece işlem bitim tarihine kadar akıllı bildirimler alarak hatırlatıcılar alırsınız.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    _recurringEndDate ??
                    DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (date != null) {
                setState(() {
                  _recurringEndDate = date;
                  _hasUserInteracted = true;
                });
                _validateForm();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _recurringEndDate != null
                        ? '${_recurringEndDate!.day.toString().padLeft(2, '0')}/'
                              '${_recurringEndDate!.month.toString().padLeft(2, '0')}/'
                              '${_recurringEndDate!.year}'
                        : 'Bitiş tarihi seçiniz',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: _recurringEndDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _isFormValid
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !_isFormValid
            ? Theme.of(context).colorScheme.surfaceVariant
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFormValid
            ? [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: (_isSubmitting || !_isFormValid) ? null : _submitTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white, // Always white as per user request
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Güncelle', style: TextStyle(fontSize: 16)),
                ],
              ),
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

}
