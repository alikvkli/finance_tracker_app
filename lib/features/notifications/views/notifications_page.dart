import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/transaction_skeleton.dart';
import '../../transactions/widgets/add_transaction_modal.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationControllerProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationControllerProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: notificationState.isLoading
            ? _buildLoadingSkeleton(context)
            : Column(
                children: [
                  // Simple Header
                  _buildNotificationHeader(context, notificationState),
                  
                  // Content
                  Expanded(
                    child: _buildContent(context, notificationState),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNotificationHeader(BuildContext context, NotificationState state) {
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
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 22,
            ),
            tooltip: 'Geri',
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(40, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Title with Badge
          Expanded(
            child: Row(
              children: [
                Text(
                  'Bildirimler',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                  ),
                ),
                if (state.unreadCount > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Mark All Read Button
          if (state.unreadCount > 0)
            TextButton(
              onPressed: state.isMarkingAllAsRead ? null : () async {
                await ref.read(notificationControllerProvider.notifier).markAllAsRead();
                if (context.mounted) {
                  CustomSnackBar.showSuccess(
                    context,
                    message: 'Tüm bildirimler okundu olarak işaretlendi',
                  );
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: state.isMarkingAllAsRead
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      ],
                    )
                  : Text(
                      'Tümünü Oku',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, NotificationState state) {
    if (state.error != null) {
      return _buildErrorWidget(context, state.error!);
    }

    if (state.notifications.isEmpty) {
      return _buildEmptyWidget(context);
    }

    return _buildNotificationList(context, state);
  }

  Widget _buildNotificationList(BuildContext context, NotificationState state) {
    // Calculate total item count (notifications + loading indicator)
    final totalItemCount = state.notifications.length + 
        (state.hasMorePages && state.isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(notificationControllerProvider.notifier).refreshNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: totalItemCount,
        itemBuilder: (context, index) {
          // Show loading indicator at the end if loading more
          if (index == state.notifications.length && state.hasMorePages && state.isLoadingMore) {
            return _buildLoadingMoreIndicator(context);
          }

          // Trigger load more when near the end
          if (index == state.notifications.length - 3 && 
              state.hasMorePages && 
              !state.isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(notificationControllerProvider.notifier).loadMoreNotifications();
            });
          }

          final notification = state.notifications[index];
          return _NotificationCard(
            notification: notification,
            isMarkingAsRead: state.markingAsRead.contains(notification.id),
            isDeleting: state.deletingNotifications.contains(notification.id),
            onMarkAsRead: () async {
              await ref.read(notificationControllerProvider.notifier)
                  .markAsRead(notification.id);
            },
            onAutoFillTap: () {
              _handleNotificationAction(context, notification, onTransactionCreated: () async {
                // İşlem oluşturulduktan sonra bildirimi okundu olarak işaretle
                await ref.read(notificationControllerProvider.notifier)
                    .markAsRead(notification.id);
              });
            },
            onLongPress: () {
              _showDeleteConfirmationDialog(context, notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Daha fazla bildirim yükleniyor...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
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
              'Bir hata oluştu',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
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
                ref.read(notificationControllerProvider.notifier).refreshNotifications();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Deneyiniz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern empty illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Henüz bildirim yok',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                'Henüz herhangi bir bildirim bulunamadı. Hatırlatıcılarınız ve sistem bildirimleri burada görünecek.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Column(
      children: [
        // Simple Header Skeleton
        _buildSimpleHeaderSkeleton(context),
        
        // Content Skeleton
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: const TransactionSkeleton(itemCount: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleHeaderSkeleton(BuildContext context) {
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
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        builder: (context, value, child) {
          // Create repeating animation
          final repeatingValue = (value * 2) % 1.0;
          return Row(
            children: [
              // Back Button Skeleton
              _buildAnimatedSkeletonContainer(
                width: 40, 
                height: 40, 
                isCircle: true,
                animationValue: repeatingValue,
              ),
              const SizedBox(width: 8),
              
              // Title Skeleton
              _buildAnimatedSkeletonContainer(
                width: 100, 
                height: 24,
                animationValue: repeatingValue,
              ),
              
              const Spacer(),
              
              // Action Button Skeleton
              _buildAnimatedSkeletonContainer(
                width: 80, 
                height: 32, 
                borderRadius: 8,
                animationValue: repeatingValue,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedSkeletonContainer({
    double? width,
    double? height,
    double? borderRadius,
    bool isCircle = false,
    required double animationValue,
  }) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3);
    final highlightColor = Theme.of(context).colorScheme.surface;
    
    return Container(
      width: width,
      height: height ?? 16,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            shimmerColor,
            highlightColor,
            shimmerColor,
          ],
          stops: [
            animationValue - 0.3,
            animationValue,
            animationValue + 0.3,
          ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
        ),
        borderRadius: isCircle 
            ? BorderRadius.circular((height ?? 16) / 2)
            : BorderRadius.circular(borderRadius ?? 8),
      ),
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

  void _showDeleteConfirmationDialog(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red[600],
                size: 32,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'Bildirimi Sil',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Bu bildirimi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Delete Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await ref.read(notificationControllerProvider.notifier)
                          .deleteNotification(notification.id);
                      if (context.mounted) {
                        CustomSnackBar.showSuccess(
                          context,
                          message: 'Bildirim başarıyla silindi',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sil',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationAction(
    BuildContext context, 
    NotificationModel notification, {
    VoidCallback? onTransactionCreated,
  }) {
    if (notification.autoFill != null) {
      // Extract due date from notification data
      String? dueDate;
      if (notification.data != null) {
        dueDate = notification.data!['due_date'] as String?;
      }
      
      // Show AddTransactionModal with auto-fill data
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => AddTransactionModal(
          autoFillData: notification.autoFill,
          dueDateOverride: dueDate,
          hideRecurringOptions: true,   // ✅ Recurring options'ı gizle
          lockTypeAndCategory: true,    // ✅ Type ve category'yi kilitle
          onTransactionCreated: onTransactionCreated, // ✅ Callback
        ),
      );
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isMarkingAsRead;
  final bool isDeleting;
  final VoidCallback onMarkAsRead;
  final VoidCallback onAutoFillTap;
  final VoidCallback onLongPress;

  const _NotificationCard({
    required this.notification,
    required this.isMarkingAsRead,
    required this.isDeleting,
    required this.onMarkAsRead,
    required this.onAutoFillTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notification.isRead
                  ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onLongPress: (isMarkingAsRead || isDeleting) ? null : onLongPress,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        // Notification Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: notification.isTransactionReminder
                                ? Colors.blue[50]
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            notification.isTransactionReminder
                                ? Icons.schedule_rounded
                                : Icons.info_outline,
                            color: notification.isTransactionReminder
                                ? Colors.blue[600]
                                : Colors.orange[600],
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Title and Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatNotificationTime(notification.sentAt ?? notification.createdAt),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Mark as Read Icon Button
                        if (!notification.isRead)
                          IconButton(
                            onPressed: (isMarkingAsRead || isDeleting) ? null : onMarkAsRead,
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                              minimumSize: const Size(32, 32),
                              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            tooltip: 'Okundu olarak işaretle',
                            icon: Icon(
                              Icons.done_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 18,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Message
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),

                    // Auto-fill Action (only for unread notifications)
                    if (notification.autoFill != null && !notification.isRead) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: (isMarkingAsRead || isDeleting) ? null : onAutoFillTap,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Otomatik işlem oluştur',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Loading Overlay for Mark as Read
        if (isMarkingAsRead)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'İşlem tamamlanıyor...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Loading Overlay for Delete
        if (isDeleting)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.red.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Siliniyor...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatNotificationTime(DateTime? dateTime) {
    if (dateTime == null) return 'Bilinmiyor';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      final monthNames = [
        'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
        'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
      ];
      return '${dateTime.day} ${monthNames[dateTime.month - 1]}';
    }
  }
}
