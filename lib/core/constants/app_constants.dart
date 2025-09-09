class AppConstants {
  // App Info
  static const String appName = 'Finance Tracker';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String userLanguageKey = 'user_language';
  static const String userThemeKey = 'user_theme';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Onboarding
  static const int onboardingPageCount = 3;
  
  // Supported Languages
  static const List<String> supportedLanguages = ['tr', 'en'];
  static const String defaultLanguage = 'tr';
}
