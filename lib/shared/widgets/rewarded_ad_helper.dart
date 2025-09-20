import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/config_controller.dart';
import '../services/admob_service.dart';
import '../../core/di/injection.dart';
import 'custom_snackbar.dart';

class RewardedAdHelper {
  static final AdMobService _adMobService = getIt<AdMobService>();

  /// Cooldown bypass ile direkt işlem yapma (premium kullanıcılar için)
  static Future<bool> performActionWithoutAd(
    BuildContext context, {
    required Future<void> Function() onActionPerformed,
  }) async {
    try {
      await onActionPerformed();
      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: 'İşlem başarıyla tamamlandı.',
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: 'İşlem sırasında bir hata oluştu.',
        );
      }
      return false;
    }
  }

  static Future<bool> showRewardedAdForAction(
    BuildContext context,
    WidgetRef ref, {
    required String actionTitle,
    required String actionDescription,
    required Future<void> Function() onRewardEarned,
  }) async {
    final configState = ref.read(configControllerProvider);
    
    // Reklamların etkin olup olmadığını kontrol et
    if (configState.config?.userPreferences.showAds != true || 
        configState.config?.admob.enabled != true) {
      // Reklamlar etkin değilse direkt işlemi yap
      await onRewardEarned();
      return true;
    }

    // Cooldown kontrolü
    final isInCooldown = await _adMobService.isInCooldown();
    if (isInCooldown) {
      // Cooldown sırasında direkt işlemi yap (sessizce)
      await onRewardEarned();
      return true;
    }

    // Rewarded ad hazır değilse yükle
    if (!_adMobService.isRewardedAdReady) {
      await _adMobService.loadRewardedAd();
      
      // Hala hazır değilse direkt işlemi yap
      if (!_adMobService.isRewardedAdReady) {
        if (context.mounted) {
          CustomSnackBar.showInfo(
            context,
            message: 'Reklam yüklenemedi, işlem devam ediyor...',
          );
        }
        await onRewardEarned();
        return true;
      }
    }

    // Kullanıcıya rewarded ad göstereceğimizi bildiren dialog
    final shouldShowAd = await _showRewardedAdDialog(
      context,
      actionTitle: actionTitle,
      actionDescription: actionDescription,
      showCooldownInfo: false,
    );

    if (shouldShowAd != true) {
      return false; // Kullanıcı iptal etti
    }

    // Rewarded ad'i göster
    final rewardEarned = await _adMobService.showRewardedAd();
    
    if (rewardEarned) {
      // Ödül kazanıldı, işlemi gerçekleştir
      await onRewardEarned();
      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: 'Tebrikler! İşlem başarıyla tamamlandı.',
        );
      }
      return true;
    } else {
      // Ödül kazanılmadı
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: 'Reklam izlenmedi, işlem iptal edildi.',
        );
      }
      return false;
    }
  }

  static Future<bool?> _showRewardedAdDialog(
    BuildContext context, {
    required String actionTitle,
    required String actionDescription,
    bool showCooldownInfo = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reward Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[400]!, Colors.orange[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                actionTitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                actionDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              // Reward Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.orange[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kısa bir reklam izleyerek bu işlemi ücretsiz gerçekleştirebilirsiniz',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.orange[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'İptal',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Watch Ad Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text(
                        'Reklam İzle',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
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
