import 'package:equatable/equatable.dart';

class ConfigResponse extends Equatable {
  final bool success;
  final String message;
  final ConfigData data;

  const ConfigResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ConfigResponse.fromJson(Map<String, dynamic> json) {
    return ConfigResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: ConfigData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, message, data];
}

class ConfigData extends Equatable {
  final NotificationConfig notifications;
  final AdMobConfig admob;
  final UserPreferences userPreferences;
  final String timestamp;

  const ConfigData({
    required this.notifications,
    required this.admob,
    required this.userPreferences,
    required this.timestamp,
  });

  factory ConfigData.fromJson(Map<String, dynamic> json) {
    return ConfigData(
      notifications: NotificationConfig.fromJson(json['notifications'] as Map<String, dynamic>),
      admob: AdMobConfig.fromJson(json['admob'] as Map<String, dynamic>),
      userPreferences: UserPreferences.fromJson(json['user_preferences'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.toJson(),
      'admob': admob.toJson(),
      'user_preferences': userPreferences.toJson(),
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [notifications, admob, userPreferences, timestamp];
}

class NotificationConfig extends Equatable {
  final int unreadCount;

  const NotificationConfig({
    required this.unreadCount,
  });

  factory NotificationConfig.fromJson(Map<String, dynamic> json) {
    return NotificationConfig(
      unreadCount: json['unread_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unread_count': unreadCount,
    };
  }

  @override
  List<Object?> get props => [unreadCount];
}

class AdMobConfig extends Equatable {
  final bool enabled;
  final bool testMode;
  final String appId;
  final String bannerAdUnitId;
  final String interstitialAdUnitId;
  final String rewardedAdUnitId;

  const AdMobConfig({
    required this.enabled,
    required this.testMode,
    required this.appId,
    required this.bannerAdUnitId,
    required this.interstitialAdUnitId,
    required this.rewardedAdUnitId,
  });

  factory AdMobConfig.fromJson(Map<String, dynamic> json) {
    return AdMobConfig(
      enabled: json['enabled'] as bool,
      testMode: json['test_mode'] as bool,
      appId: json['app_id'] as String,
      bannerAdUnitId: json['banner_ad_unit_id'] as String,
      interstitialAdUnitId: json['interstitial_ad_unit_id'] as String,
      rewardedAdUnitId: json['rewarded_ad_unit_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'test_mode': testMode,
      'app_id': appId,
      'banner_ad_unit_id': bannerAdUnitId,
      'interstitial_ad_unit_id': interstitialAdUnitId,
      'rewarded_ad_unit_id': rewardedAdUnitId,
    };
  }

  @override
  List<Object?> get props => [
        enabled,
        testMode,
        appId,
        bannerAdUnitId,
        interstitialAdUnitId,
        rewardedAdUnitId,
      ];
}

class UserPreferences extends Equatable {
  final bool showAds;

  const UserPreferences({
    required this.showAds,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      showAds: json['show_ads'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_ads': showAds,
    };
  }

  @override
  List<Object?> get props => [showAds];
}
