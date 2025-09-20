import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/config_controller.dart';
import '../services/admob_service.dart';
import '../../core/di/injection.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  final String screenId;
  
  const BannerAdWidget({
    super.key,
    required this.screenId,
  });

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  final AdMobService _adMobService = getIt<AdMobService>();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  void _initializeAds() {
    final configState = ref.read(configControllerProvider);
    
    if (configState.config?.userPreferences.showAds == true && 
        configState.config?.admob.enabled == true) {
      
      if (!_adMobService.isInitialized) {
        _adMobService.initialize(configState.config!.admob).then((_) {
          _adMobService.createBannerAd(widget.screenId);
          if (mounted) setState(() {});
        });
      } else {
        _adMobService.createBannerAd(widget.screenId);
        if (mounted) setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configState = ref.watch(configControllerProvider);
    
    // Config yüklenene kadar bekle
    if (configState.isLoading) {
      return const SizedBox.shrink();
    }
    
    // Config yüklendikten sonra ads'ları initialize et
    if (configState.config != null && !_hasInitialized) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAds();
      });
    }
    
    // Reklamların gösterilip gösterilmeyeceğini kontrol et
    if (configState.config?.userPreferences.showAds != true || 
        configState.config?.admob.enabled != true) {
      return const SizedBox.shrink();
    }

    final bannerAd = _adMobService.getBannerAd(widget.screenId);
    
    if (bannerAd == null) {
      return Container(
        width: 320,
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Reklam yükleniyor...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Container(
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AdWidget(ad: bannerAd),
    );
  }

  @override
  void dispose() {
    _adMobService.disposeBannerAd(widget.screenId);
    super.dispose();
  }
}
