import 'package:flutter/material.dart';
import '../../core/routing/app_router.dart';
import 'notification_badge.dart';
import '../../core/extensions/amount_formatting_extension.dart';

class FinancialHeader extends StatelessWidget {
  final String title;
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final Widget? monthBadge;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const FinancialHeader({
    super.key,
    required this.title,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    this.monthBadge,
    this.onNotificationTap,
    this.notificationCount = 0,
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
                  // Notification Button with Badge
                  AnimatedNotificationBadge(
                    count: notificationCount,
                    badgeColor: const Color(0xFFFF3B30),
                    showPulse: true,
                    child: IconButton(
                      onPressed: onNotificationTap ?? () {
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
                totalIncome.formatAsTurkishLira(),
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
                totalExpense.formatAsTurkishLira(),
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
              balance.formatAsTurkishLira(),
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


}
