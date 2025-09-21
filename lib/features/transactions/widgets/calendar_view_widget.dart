import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/upcoming_reminders_controller.dart';
import '../models/upcoming_reminder_model.dart';
import '../../../shared/widgets/transaction_skeleton.dart';

class CalendarViewWidget extends ConsumerStatefulWidget {
  const CalendarViewWidget({super.key});

  @override
  ConsumerState<CalendarViewWidget> createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends ConsumerState<CalendarViewWidget> {
  late final ValueNotifier<List<UpcomingReminderModel>> _selectedReminders;
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

  List<UpcomingReminderModel> _getRemindersForDay(DateTime day) {
    final reminders = ref.read(upcomingRemindersControllerProvider).reminders;
    final dayString = _formatDateForAPI(day);
    
    return reminders.where((reminder) => reminder.date == dayString).toList();
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(upcomingRemindersControllerProvider.notifier).loadUpcomingReminders();
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

  Widget _buildCalendarView(BuildContext context, List<UpcomingReminderModel> reminders) {
    // Create a map of dates with reminders for calendar markers
    final Map<DateTime, List<UpcomingReminderModel>> remindersMap = {};
    
    for (final reminder in reminders) {
      try {
        final date = DateTime.parse(reminder.date);
        final dayKey = DateTime(date.year, date.month, date.day);
        remindersMap[dayKey] = remindersMap[dayKey] ?? [];
        remindersMap[dayKey]!.add(reminder);
      } catch (e) {
        // Skip invalid dates
      }
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar
          Container(
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
            child: TableCalendar<UpcomingReminderModel>(
              firstDay: DateTime.now(), // Sadece bugünden itibaren
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: (day) => remindersMap[DateTime(day.year, day.month, day.day)] ?? [],
              startingDayOfWeek: StartingDayOfWeek.monday,
              locale: 'tr_TR', // Türkçe lokalizasyon
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                defaultTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                todayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markerSize: 6,
                markerMargin: const EdgeInsets.symmetric(horizontal: 1),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // Format butonunu gizle
                titleCentered: true,
                formatButtonShowsNext: false,
                leftChevronVisible: false, // Sol ok butonunu gizle
                rightChevronVisible: false, // Sağ ok butonunu gizle
                titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ) ?? TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
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
          ValueListenableBuilder<List<UpcomingReminderModel>>(
            valueListenable: _selectedReminders,
            builder: (context, selectedReminders, _) {
              return _buildSelectedDayReminders(context, selectedReminders);
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget _buildSelectedDayReminders(BuildContext context, List<UpcomingReminderModel> reminders) {
    if (reminders.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu tarihte hatırlatma yok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatSelectedDate(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
              color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatSelectedDate(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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
                          fontWeight: FontWeight.w500,
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
              children: reminders.map((reminder) => 
                _buildReminderItem(context, reminder)
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(BuildContext context, UpcomingReminderModel reminder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reminder.reminders.values.map((reminderData) => 
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: reminderData.isIncome 
                    ? Colors.green[50] 
                    : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  reminderData.isIncome ? Icons.trending_up : Icons.trending_down,
                  color: reminderData.isIncome ? Colors.green[600] : Colors.red[600],
                  size: 18,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminderData.category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: reminderData.isIncome 
                          ? Colors.green[100] 
                          : Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        reminderData.recurringType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: reminderData.isIncome ? Colors.green[700] : Colors.red[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Text(
                reminderData.amount,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: reminderData.isIncome ? Colors.green[600] : Colors.red[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ).toList(),
    );
  }

  String _formatSelectedDate() {
    if (_selectedDay == null) return '';
    
    final monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    
    return '${_selectedDay!.day} ${monthNames[_selectedDay!.month - 1]} ${_selectedDay!.year}';
  }
}
