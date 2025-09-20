import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/routing/app_router.dart';
import '../../features/auth/controllers/auth_controller.dart';

class FinancialHeader extends StatelessWidget {
  final String title;
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final Widget? monthBadge;
  final VoidCallback? onNotificationTap;

  const FinancialHeader({
    super.key,
    required this.title,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    this.monthBadge,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row with Title and Action Buttons
          Row(
            children: [
              // App Title
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                  ),
                ),
              ),

              // Action Buttons
              Row(
                children: [
                  // Notification Button
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.notifications);
                    },
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 22,
                    ),
                    tooltip: 'Bildirimler',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(40, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Logout Button
                  Consumer(
                    builder: (context, ref, child) => IconButton(
                      onPressed: () => _showLogoutDialog(context, ref),
                      icon: Icon(
                        Icons.logout_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 22,
                      ),
                      tooltip: 'Çıkış Yap',
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(40, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Financial Overview
          _buildFinancialOverview(context),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(BuildContext context) {
    return Column(
      children: [
        // Net Balance Section
        _buildNetBalanceSection(context),

        const SizedBox(height: 32),

        // Income & Expense Row
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                'Gelir',
                _formatAmount(totalIncome),
                Icons.arrow_upward_rounded,
                const Color(0xFF059669),
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.1),
            ),
            Expanded(
              child: _buildStatItem(
                context,
                'Gider',
                _formatAmount(totalExpense),
                Icons.arrow_downward_rounded,
                const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetBalanceSection(BuildContext context) {
    final isPositive = balance >= 0;
    final color = isPositive
        ? const Color(0xFF059669)
        : const Color(0xFFDC2626);

    return Column(
      children: [
        // Month Badge
        if (monthBadge != null) ...[monthBadge!, const SizedBox(height: 16)],

        // Net Balance Label
        Text(
          'Net Bakiye',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),

        const SizedBox(height: 8),

        // Net Balance Amount with Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _formatAmount(balance),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontSize: 32,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        // Icon and Label Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Amount
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount == 0) return '₺0,00';

    // Negatif değerleri pozitif yap
    final absAmount = amount.abs();

    if (absAmount >= 1000000) {
      return '₺${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      return '₺${(absAmount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₺${absAmount.toStringAsFixed(0)}';
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 20,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red[600],
                  size: 36,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Çıkış Yap',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

              const SizedBox(height: 32),

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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'İptal',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Logout Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.login,
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Çıkış Yap',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
