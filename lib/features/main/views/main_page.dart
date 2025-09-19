import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/views/dashboard_page.dart';
import '../../transactions/views/transactions_page.dart';
import '../../transactions/widgets/add_transaction_modal.dart';
import '../../transactions/widgets/transaction_filters.dart';
import '../../../shared/widgets/bottom_navigation.dart';

class MainPage extends ConsumerStatefulWidget {
  final int initialTab;
  
  const MainPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _tabController = TabController(
      length: 2, // Sadece Dashboard ve Transactions
      vsync: this,
      initialIndex: widget.initialTab,
    );
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Ana sayfalarda geri tuşunu devre dışı bırak
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: TabBarView(
          controller: _tabController,
          children: [
            DashboardPage(onNavigateToTransactions: () => _switchToTransactionsTab()),
            TransactionsPage(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
        floatingActionButton: _currentIndex == 1
            ? FloatingActionButton(
                onPressed: () => _showFilterBottomSheet(context),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 24,
                ),
              )
            : null,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Add transaction button
      _showAddTransactionModal(context);
    } else {
      // Tab navigation
      setState(() {
        _currentIndex = index;
      });
      _tabController.animateTo(index);
    }
  }

  void _switchToTransactionsTab() {
    setState(() {
      _currentIndex = 1;
    });
    _tabController.animateTo(1);
  }

  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionModal(),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      builder: (context) => const TransactionFilters(),
    );
  }
}
