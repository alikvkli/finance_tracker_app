import 'package:flutter/material.dart';

class TransactionSkeleton extends StatefulWidget {
  final int itemCount;
  final bool isCompact;

  const TransactionSkeleton({
    super.key,
    this.itemCount = 5,
    this.isCompact = false,
  });

  @override
  State<TransactionSkeleton> createState() => _TransactionSkeletonState();
}

class _TransactionSkeletonState extends State<TransactionSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: widget.isCompact
                  ? _buildCompactSkeletonItem(context)
                  : _buildFullSkeletonItem(context),
            );
          },
        );
      },
    );
  }

  Widget _buildFullSkeletonItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category Icon Skeleton
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getShimmerColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content Skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Amount Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title Skeleton
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getShimmerColor(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // Amount Skeleton
                    Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getShimmerColor(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Description Skeleton
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getShimmerColor(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Date Skeleton
                Container(
                  width: 100,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getShimmerColor(context),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSkeletonItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          // Category Icon Skeleton
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getShimmerColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content Skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Amount Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title Skeleton
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _getShimmerColor(context),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    // Amount Skeleton
                    Container(
                      width: 60,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _getShimmerColor(context),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                // Date Skeleton
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getShimmerColor(context),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getShimmerColor(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1);
    final highlightColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);
    
    return Color.lerp(
      baseColor,
      highlightColor,
      _animation.value,
    ) ?? baseColor;
  }
}

// Dashboard için özel compact skeleton
class DashboardTransactionSkeleton extends StatelessWidget {
  const DashboardTransactionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionSkeleton(
      itemCount: 3,
      isCompact: true,
    );
  }
}

// Transactions sayfası için full skeleton
class TransactionsPageSkeleton extends StatelessWidget {
  const TransactionsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionSkeleton(
      itemCount: 8,
      isCompact: false,
    );
  }
}
