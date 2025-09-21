// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get calendar => 'Takvim';

  @override
  String get month => 'Ay';

  @override
  String get week => 'Hafta';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get tomorrow => 'Yarın';

  @override
  String get skip => 'Geç';

  @override
  String get next => 'İleri';

  @override
  String get getStarted => 'Başlayın';

  @override
  String get onboardingWelcome => 'Finance Tracker\'a Hoş Geldiniz';

  @override
  String get onboardingWelcomeDescription =>
      'Finanslarınızı kolay ve verimli bir şekilde yönetin';

  @override
  String get onboardingTrack => 'Harcamalarınızı Takip Edin';

  @override
  String get onboardingTrackDescription =>
      'Günlük harcamalarınızı ve gelirlerinizi takip edin';

  @override
  String get onboardingAnalyze => 'Harcamalarınızı Analiz Edin';

  @override
  String get onboardingAnalyzeDescription =>
      'Harcama alışkanlıklarınız hakkında içgörüler elde edin';
}
