import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';
import '../models/config_response.dart';

@singleton
class AdMobService {
  final Map<String, BannerAd> _bannerAds = {};
  InterstitialAd? _interstitialAd;
  bool _isInitialized = false;
  AdMobConfig? _config;

  bool get isInitialized => _isInitialized;

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
    _interstitialAd = null;
  }
}
