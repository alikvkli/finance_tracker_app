import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/logout_helper.dart';
import '../../transactions/controllers/statistics_controller.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../transactions/widgets/statistics_tab_widget.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  bool _isDeleting = false;
  late TabController _tabController;

  String? _userEmail;
  String? _userName;
  String? _userSurname;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // Start with Statistics tab (index 1)
    _tabController.addListener(_onTabChanged);
    _loadUserData();
    
    // Load statistics after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatistics();
    });
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild to update tab icon colors
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final storageService = ref.read(storageServiceProvider);
    _userEmail = storageService.getUserEmail();
    _userName = storageService.getUserName();
    _userSurname = storageService.getUserSurname();

    // Trigger rebuild to show loaded data
    if (mounted) {
      setState(() {});
    }
  }

  void _loadStatistics() {
    final transactionState = ref.read(transactionControllerProvider);
    ref.read(statisticsControllerProvider.notifier).loadStatistics(
      startDate: transactionState.selectedStartDate,
      endDate: transactionState.selectedEndDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Geri tuşunu devre dışı bırak
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildProfileHeader(context),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, child) {
                    return TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.transparent, // Hide default label colors
                  unselectedLabelColor: Colors.transparent, // Hide default unselected colors
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 18,
                            color: _tabController.index == 0 
                              ? Colors.white 
                              : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hesap',
                            style: TextStyle(
                              color: _tabController.index == 0 
                                ? Colors.white 
                                : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 18,
                            color: _tabController.index == 1 
                              ? Colors.white 
                              : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'İstatistikler',
                            style: TextStyle(
                              color: _tabController.index == 1 
                                ? Colors.white 
                                : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                    );
                  },
                ),
              ),

              // Tab Content
              Expanded(
                child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, child) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProfileContent(context),
                        const StatisticsTabWidget(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row - Title and Logout
          Row(
            children: [
              Text(
                'Profil',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 28,
                ),
              ),

              const Spacer(),

              IconButton(
                onPressed: () => _showLogoutDialog(context),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(44, 44),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.errorContainer.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                tooltip: 'Çıkış Yap',
                icon: Icon(
                  Icons.logout_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Profile Info
          Row(
            children: [
              // Simple Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),

              const SizedBox(width: 20),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName != null && _userSurname != null
                          ? '$_userName $_userSurname'
                          : 'Merhaba',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _userEmail ?? 'E-posta bilgisi yok',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Support Section
          _buildSupportSection(context),
          
          const SizedBox(height: 24),
          
          // Danger Zone
          _buildDangerZone(context),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Support Section Title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Destek',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
        ),

        // Support Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.support_agent,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Destek ve Geri Bildirim',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Önerileriniz, görüşleriniz ve sorularınız için bize ulaşabilirsiniz.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // Email button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _sendSupportEmail(),
                  icon: Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  label: Text(
                    'ali.kavakli4598@gmail.com',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sendSupportEmail() async {
    const email = 'ali.kavakli4598@gmail.com';
    const subject = 'Finans Takip Uygulaması - Destek';
    const body = 'Merhaba,\n\nUygulama hakkında görüş ve önerilerim:\n\n';
    
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // E-posta uygulaması açılamadı, adresi clipboard'a kopyala
        await Clipboard.setData(const ClipboardData(text: 'ali.kavakli4598@gmail.com'));
        
        if (mounted) {
          _showEmailFallbackDialog(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('E-posta uygulaması açılamadı'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _showEmailFallbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.copy_all,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'E-posta Adresi Kopyalandı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'E-posta uygulaması açılamadı. E-posta adresi panoya kopyalandı.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Email address container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ali.kavakli4598@gmail.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nasıl gönderebilirsiniz:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. E-posta uygulamanızı manuel olarak açın\n2. Yeni e-posta oluşturun\n3. Alıcı alanına yapıştırın\n4. Konu: "Finans Takip Uygulaması - Destek"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Anladım'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simple Section Title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Hesap Yönetimi',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
        ),

        // Warning Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning header
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dikkat!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Warning content
              Text(
                'Hesabınızı sildiğinizde aşağıdaki veriler kalıcı olarak silinir:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Data list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWarningItem(context, '• Tüm işlem verileriniz'),
                  _buildWarningItem(context, '• İstatistik verileriniz'),
                  _buildWarningItem(context, '• Kişisel bilgileriniz'),
                  _buildWarningItem(context, '• Uygulama tercihleriniz'),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Final warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu işlem geri alınamaz. Emin olmadan devam etmeyin.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Simple Delete Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isDeleting
                ? null
                : () => _showDeleteAccountDialog(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _isDeleting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.error,
                      ),
                    ),
                  )
                : Icon(
                    Icons.delete_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
            label: Text(
              _isDeleting ? 'Hesap Siliniyor...' : 'Hesabı Sil',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 12,
          height: 1.2,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simple Icon
                Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Hesabı Sil',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz silinecektir.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Password Input
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifrenizi Giriniz',
                    hintText: 'Mevcut şifreniz',
                    prefixIcon: Icon(
                      Icons.lock_outline,
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

                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _passwordController.clear();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'İptal',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Delete Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isDeleting
                            ? null
                            : () => _deleteAccount(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isDeleting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Siliniyor...',
                                    style: TextStyle(),
                                  ),
                                ],
                              )
                            : const Text('Hesabı Sil'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    if (_passwordController.text.trim().isEmpty) {
      CustomSnackBar.showError(context, message: 'Lütfen şifrenizi giriniz');
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final storageService = ref.read(storageServiceProvider);
      final token = storageService.getAuthToken();

      if (token == null) {
        throw Exception('Oturum bulunamadı');
      }

      await authService.deleteAccount(_passwordController.text.trim(), token);

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog

        // Clear local storage
        final storageService = ref.read(storageServiceProvider);
        await storageService.clearAuthToken();

        // Navigate to onboarding and clear all data
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRouter.onboarding, (route) => false);

        CustomSnackBar.showSuccess(
          context,
          message: 'Hesabınız başarıyla silindi',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, message: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        _passwordController.clear();
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple Icon
            Icon(
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 48,
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'Çıkış Yap',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Logout Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await LogoutHelper.logout(context, ref);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Çıkış Yap'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
