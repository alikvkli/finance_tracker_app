// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get calendar => 'Calendar';

  @override
  String get month => 'Month';

  @override
  String get week => 'Week';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingWelcome => 'Welcome to Finance Tracker';

  @override
  String get onboardingWelcomeDescription =>
      'Manage your finances easily and efficiently';

  @override
  String get onboardingTrack => 'Track Your Expenses';

  @override
  String get onboardingTrackDescription =>
      'Keep track of your daily expenses and income';

  @override
  String get onboardingAnalyze => 'Analyze Your Spending';

  @override
  String get onboardingAnalyzeDescription =>
      'Get insights into your spending patterns';
}
