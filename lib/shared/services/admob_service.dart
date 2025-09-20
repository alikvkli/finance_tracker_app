import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/config_response.dart';
import '../../core/di/injection.dart';

@singleton
class AdMobService {
  final Map<String, BannerAd> _bannerAds = {};
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInitialized = false;
  AdMobConfig? _config;
  
  static const String _cooldownKey = 'rewarded_ad_cooldown';
  static const int _cooldownMinutes = 1;

  bool get isInitialized => _isInitialized;
  bool get isRewardedAdReady => _rewardedAd != null;

  Future<bool> isInCooldown() async {
    final prefs = getIt<SharedPreferences>();
    final lastShownTime = prefs.getInt(_cooldownKey);
    
    if (lastShownTime == null) return false;
    
    final lastShown = DateTime.fromMillisecondsSinceEpoch(lastShownTime);
    final now = DateTime.now();
    final difference = now.difference(lastShown);
    
    return difference.inMinutes < _cooldownMinutes;
  }

  Future<Duration?> getRemainingCooldown() async {
    final prefs = getIt<SharedPreferences>();
    final lastShownTime = prefs.getInt(_cooldownKey);
    
    if (lastShownTime == null) return null;
    
    final lastShown = DateTime.fromMillisecondsSinceEpoch(lastShownTime);
    final now = DateTime.now();
    final difference = now.difference(lastShown);
    
    if (difference.inMinutes >= _cooldownMinutes) return null;
    
    final cooldownDuration = Duration(minutes: _cooldownMinutes);
    return cooldownDuration - difference;
  }

  Future<void> _setCooldownTime() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setInt(_cooldownKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> initialize(AdMobConfig config) async {
    if (_isInitialized) return;
    
    _config = config;
    
    await MobileAds.instance.initialize();
    
    if (kDebugMode && config.testMode) {
      // Test cihaz ID'lerini ekle (gerekirse)
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ['TEST_DEVICE_ID'], // Gerçek test cihaz ID'nizi buraya ekleyin
        ),
      );
    }
    
    _isInitialized = true;
  }

  BannerAd? createBannerAd(String screenId) {
    if (!_isInitialized || _config == null) return null;

    // Eğer bu ekran için zaten bir ad varsa onu dispose et
    _bannerAds[screenId]?.dispose();
    
    final bannerAd = BannerAd(
      adUnitId: _getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // Banner ad loaded successfully
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAds.remove(screenId);
        },
        onAdOpened: (ad) {
          // Banner ad opened
        },
        onAdClosed: (ad) {
          // Banner ad closed
        },
      ),
    );

    _bannerAds[screenId] = bannerAd;
    bannerAd.load();
    return bannerAd;
  }

  BannerAd? getBannerAd(String screenId) {
    return _bannerAds[screenId];
  }

  void disposeBannerAd(String screenId) {
    _bannerAds[screenId]?.dispose();
    _bannerAds.remove(screenId);
  }

  Future<void> loadInterstitialAd() async {
    if (!_isInitialized || _config == null) return;

    await InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd?.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      return;
    }

    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        // Interstitial ad showed
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        // Yeni reklam yükle
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
      },
    );

    await _interstitialAd?.show();
  }

  Future<void> loadRewardedAd() async {
    if (!_isInitialized || _config == null) return;

    await RewardedAd.load(
      adUnitId: _getRewardedAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd?.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      return false;
    }

    bool rewardEarned = false;

    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        // Rewarded ad showed
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        // Yeni reklam yükle
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
      },
    );

    await _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        // Ödül kazanıldığında cooldown'u set et
        _setCooldownTime();
      },
    );

    return rewardEarned;
  }

  String _getRewardedAdUnitId() {
    if (_config?.testMode == true) {
      // Test reklam unit ID'leri
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    
    return _config?.rewardedAdUnitId ?? '';
  }

  String _getBannerAdUnitId() {
    if (_config?.testMode == true) {
      // Test reklam unit ID'leri
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    
    return _config?.bannerAdUnitId ?? '';
  }

  String _getInterstitialAdUnitId() {
    if (_config?.testMode == true) {
      // Test reklam unit ID'leri
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    
    return _config?.interstitialAdUnitId ?? '';
  }

  void dispose() {
    for (final ad in _bannerAds.values) {
      ad.dispose();
    }
    _bannerAds.clear();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }
}
