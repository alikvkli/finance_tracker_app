import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static const List<Locale> supportedLocales = [
    Locale('tr', 'TR'),
    Locale('en', 'US'),
  ];
  
  // Onboarding
  String get onboardingWelcome => _localizedValues[locale.languageCode]!['onboarding_welcome']!;
  String get onboardingWelcomeDescription => _localizedValues[locale.languageCode]!['onboarding_welcome_description']!;
  String get onboardingTrack => _localizedValues[locale.languageCode]!['onboarding_track']!;
  String get onboardingTrackDescription => _localizedValues[locale.languageCode]!['onboarding_track_description']!;
  String get onboardingAnalyze => _localizedValues[locale.languageCode]!['onboarding_analyze']!;
  String get onboardingAnalyzeDescription => _localizedValues[locale.languageCode]!['onboarding_analyze_description']!;
  String get getStarted => _localizedValues[locale.languageCode]!['get_started']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get skip => _localizedValues[locale.languageCode]!['skip']!;
  
  // Common
  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      'app_name': 'Finans Takip',
      'onboarding_welcome': 'Finans Takip Uygulamasına Hoş Geldiniz',
      'onboarding_welcome_description': 'Gelir ve giderlerinizi kolayca takip edin, finansal hedeflerinize ulaşın.',
      'onboarding_track': 'Gelir ve Giderlerinizi Takip Edin',
      'onboarding_track_description': 'Tüm finansal hareketlerinizi kategorilere ayırarak düzenli bir şekilde takip edin.',
      'onboarding_analyze': 'Finansal Analiz Yapın',
      'onboarding_analyze_description': 'Detaylı raporlar ve grafiklerle finansal durumunuzu analiz edin.',
      'get_started': 'Başlayalım',
      'next': 'İleri',
      'skip': 'Geç',
    },
    'en': {
      'app_name': 'Finance Tracker',
      'onboarding_welcome': 'Welcome to Finance Tracker',
      'onboarding_welcome_description': 'Easily track your income and expenses, reach your financial goals.',
      'onboarding_track': 'Track Your Income & Expenses',
      'onboarding_track_description': 'Organize and track all your financial movements by categorizing them.',
      'onboarding_analyze': 'Analyze Your Finances',
      'onboarding_analyze_description': 'Analyze your financial situation with detailed reports and charts.',
      'get_started': 'Get Started',
      'next': 'Next',
      'skip': 'Skip',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['tr', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
