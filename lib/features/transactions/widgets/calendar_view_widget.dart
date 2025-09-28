import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/upcoming_reminders_controller.dart';
import '../models/upcoming_reminder_model.dart';
import '../../../shared/widgets/transaction_skeleton.dart';
import '../../../core/extensions/amount_formatting_extension.dart';
import '../providers/category_provider.dart';
import '../models/categories_api_model.dart';

class CalendarViewWidget extends ConsumerStatefulWidget {
  const CalendarViewWidget({super.key});

  @override
  ConsumerState<CalendarViewWidget> createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends ConsumerState<CalendarViewWidget> {
  late final ValueNotifier<List<ReminderData>> _selectedReminders;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now(); // Mevcut ayı göster
    _selectedReminders = ValueNotifier(_getRemindersForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedReminders.dispose();
    super.dispose();
  }

  List<ReminderData> _getRemindersForDay(DateTime day) {
    final upcomingReminders = ref
        .read(upcomingRemindersControllerProvider)
        .reminders;
    final dayString = _formatDateForAPI(day);

    // Find the UpcomingReminderModel for this day
    final dayReminder = upcomingReminders
        .where((reminder) => reminder.date == dayString)
        .firstOrNull;

    return dayReminder?.reminders ?? [];
  }

  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedReminders.value = _getRemindersForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(upcomingRemindersControllerProvider);

    if (state.isLoading) {
      return _buildLoadingSkeleton(context);
    }

    if (state.hasError) {
      return _buildErrorWidget(context, state.error!, ref);
    }

    return _buildCalendarView(context, state.reminders);
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return const TransactionSkeleton(itemCount: 5);
  }

  Widget _buildErrorWidget(BuildContext context, String error, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
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
                  'Bir hata oluştu',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(upcomingRemindersControllerProvider.notifier)
                        .loadUpcomingReminders();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Deneyiniz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView(
    BuildContext context,
    List<UpcomingReminderModel> upcomingReminders,
  ) {
    // Create a map of dates with reminders for calendar markers
    final Map<DateTime, List<ReminderData>> remindersMap = {};

    for (final dayReminder in upcomingReminders) {
      try {
        final date = DateTime.parse(dayReminder.date);
        final dayKey = DateTime(date.year, date.month, date.day);
        remindersMap[dayKey] = dayReminder.reminders;
      } catch (e) {
        // Skip invalid dates
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar<ReminderData>(
                firstDay: DateTime.now(), // Sadece bugünden itibaren
                lastDay: DateTime.now().add(
                  const Duration(days: 15),
                ), // 15 günlük sınır
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: (day) =>
                    remindersMap[DateTime(day.year, day.month, day.day)] ?? [],
                startingDayOfWeek: StartingDayOfWeek.monday,
                locale: 'tr_TR', // Türkçe lokalizasyon
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  defaultTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                  todayTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  selectedDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  markersMaxCount: 3,
                  markerSize: 7,
                  markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false, // Format butonunu gizle
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  leftChevronVisible: true, // Sol ok butonunu göster
                  rightChevronVisible: true, // Sağ ok butonunu göster
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  titleTextStyle:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ) ??
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
              ),
            ),

            const SizedBox(height: 20),

            // Selected Day Reminders
            ValueListenableBuilder<List<ReminderData>>(
              valueListenable: _selectedReminders,
              builder: (context, selectedReminders, _) {
                return _buildSelectedDayReminders(context, selectedReminders);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCalculationBottomSheet(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        child: Icon(Icons.calculate_outlined, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildSelectedDayReminders(
    BuildContext context,
    List<ReminderData> reminders,
  ) {
    if (reminders.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu tarihte hatırlatma yok',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatSelectedDate(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatSelectedDate(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_active,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${reminders.length} hatırlatma',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Reminders List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: reminders
                  .map((reminder) => _buildReminderItem(context, reminder))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(BuildContext context, ReminderData reminder) {
    final isIncome = reminder.isIncome;
    final amountColor = isIncome
        ? const Color(0xFF059669)
        : const Color(0xFFDC2626);
    final iconColor = isIncome
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);

    // Parse amount from string (e.g., "15,000.00 TRY" -> 15000.0)
    final amountString = reminder.amount.replaceAll(RegExp(r'[^\d.,]'), '');
    final amount = double.tryParse(amountString.replaceAll(',', '.')) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Compact Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                isIncome
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: iconColor,
                size: 16,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reminder.recurringType,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              amount.formatAsTurkishLira(),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: amountColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSelectedDate() {
    if (_selectedDay == null) return '';

    final monthNames = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    return '${_selectedDay!.day} ${monthNames[_selectedDay!.month - 1]} ${_selectedDay!.year}';
  }

  void _showCalculationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FinancialCalculatorBottomSheet(),
    );
  }
}

class _FinancialCalculatorBottomSheet extends StatefulWidget {
  const _FinancialCalculatorBottomSheet();

  @override
  State<_FinancialCalculatorBottomSheet> createState() =>
      _FinancialCalculatorBottomSheetState();
}

class _FinancialCalculatorBottomSheetState
    extends State<_FinancialCalculatorBottomSheet>
    with TickerProviderStateMixin {
  final List<FinancialTransactionItem> _financialTransactions = [];
  final TextEditingController _amountInputController = TextEditingController();
  String _selectedTransactionType = 'expense';
  CategoriesApiModel? _selectedCategory;
  late TabController _tabController;

  List<CategoriesApiModel> _getIncomeCategories(WidgetRef ref) {
    final categories = ref.read(categoriesProvider);
    return categories
        .where((cat) => cat.type == 'income' && cat.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<CategoriesApiModel> _getExpenseCategories(WidgetRef ref) {
    final categories = ref.read(categoriesProvider);
    return categories
        .where((cat) => cat.type == 'expense' && cat.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoriesAndSetDefault();
    });
  }

  void _loadCategoriesAndSetDefault() {
    // Kategorileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Bu metod artık gerekli değil, Consumer içinde yapılacak
    });
  }

  @override
  void dispose() {
    _amountInputController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calculate_outlined,
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
                          'Finansal Hesaplama',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gelecek dönem bütçe planlaması',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_financialTransactions.length} işlem',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withValues(alpha: 0.4),
                    Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
                labelStyle: const TextStyle(fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                tabs: [
                  Tab(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.add_circle_outline, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'İşlem Ekle',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.analytics_outlined, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bütçe Özeti',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tab Content
            SizedBox(
              height: 500,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAddTransactionFormTab(),
                  _buildFinancialOverviewTab(),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTransactionFormTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Selection
          Text(
            'İşlem Kategorisi',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildTransactionTypeButton(
                  'expense',
                  'Gider',
                  Icons.trending_down_rounded,
                  const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTransactionTypeButton(
                  'income',
                  'Gelir',
                  Icons.trending_up_rounded,
                  const Color(0xFF059669),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Amount Input
          Text(
            'İşlem Tutarı',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _amountInputController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              _formatAmountInput(value);
            },
            onFieldSubmitted: (value) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              hintText: '0,00',
              suffixText: '₺',
              prefixIcon: Icon(
                Icons.currency_lira,
                color: Theme.of(context).colorScheme.primary,
              ),
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
          ),

          const SizedBox(height: 24),

          // Category Selection
          Text(
            'Kategori',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          Consumer(
            builder: (context, ref, child) {
              // Kategorileri yükle
              ref.read(categoryProvider.notifier).loadCategories();
              final categories = _selectedTransactionType == 'income'
                  ? _getIncomeCategories(ref)
                  : _getExpenseCategories(ref);

              // Type değişiminde kategoriyi güncelle
              if (_selectedCategory == null ||
                  !categories.contains(_selectedCategory)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (categories.isNotEmpty) {
                    setState(() {
                      _selectedCategory = categories.first;
                    });
                  }
                });
              }

              return DropdownButtonFormField<CategoriesApiModel>(
                value:
                    _selectedCategory != null &&
                        categories.contains(_selectedCategory)
                    ? _selectedCategory
                    : categories.isNotEmpty
                    ? categories.first
                    : null,
                decoration: InputDecoration(
                  hintText: 'Kategori seçin',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category.nameTr,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              );
            },
          ),

          const SizedBox(height: 24),

          // Add Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addFinancialTransaction,
              icon: Icon(
                _selectedTransactionType == 'income'
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 20,
              ),
              label: Text(
                '${_selectedTransactionType == 'income' ? 'Gelir' : 'Gider'} İşlemi Ekle',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedTransactionType == 'income'
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverviewTab() {
    final totalIncome = _financialTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = _financialTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards with improved design
          Row(
            children: [
              Expanded(
                child: _buildModernSummaryCard(
                  context,
                  'Gelir',
                  totalIncome,
                  Icons.trending_up_rounded,
                  const Color(0xFF059669),
                  const Color(0xFFF0FDF4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernSummaryCard(
                  context,
                  'Gider',
                  totalExpense,
                  Icons.trending_down_rounded,
                  const Color(0xFFDC2626),
                  const Color(0xFFFEF2F2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Compact Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
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
                        'Net Bakiye',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        balance.formatAsTurkishLira(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: balance >= 0
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Financial Transactions List
          if (_financialTransactions.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Planlanan İşlemler',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_financialTransactions.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _financialTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _financialTransactions[index];
                  return _buildEnhancedFinancialTransactionItem(transaction);
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz planlanmış işlem yok',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'İşlem Ekle sekmesinden yeni işlem planlayabilirsiniz',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionTypeButton(
    String type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedTransactionType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTransactionType = type;
        });
        // Kategori seçimi Consumer içinde yapılacak
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? color
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildModernSummaryCard(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount.formatAsTurkishLira(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFinancialTransactionItem(
    FinancialTransactionItem transaction,
  ) {
    final color = transaction.type == 'income'
        ? const Color(0xFF059669)
        : const Color(0xFFDC2626);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              transaction.type == 'income'
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: color,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              transaction.category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            transaction.amount.formatAsTurkishLira(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () =>
                setState(() => _financialTransactions.remove(transaction)),
            child: Icon(
              Icons.close,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 16,
            ),
          ),
        ],
      ),
    );
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
    String formattedValue = cleanValue.formatNumberWithSeparators();

    // Eğer değer değiştiyse, controller'ı güncelle
    if (formattedValue != value) {
      _amountInputController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }
  }

  void _addFinancialTransaction() {
    // Klavyeyi kapat
    FocusManager.instance.primaryFocus?.unfocus();

    final amountText = _amountInputController.text.trim();
    if (amountText.isEmpty || _selectedCategory == null) return;

    // Formatlanmış değeri temizle ve sayıya çevir
    final cleanValue = amountText.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(cleanValue) ?? 0.0;

    if (amount <= 0) return;

    setState(() {
      _financialTransactions.add(
        FinancialTransactionItem(
          type: _selectedTransactionType,
          category: _selectedCategory!.nameTr,
          amount: amount,
        ),
      );
      _amountInputController.clear();
    });
  }
}

class FinancialTransactionItem {
  final String type;
  final String category;
  final double amount;

  FinancialTransactionItem({
    required this.type,
    required this.category,
    required this.amount,
  });
}
