// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get max_score => 'Record: ';

  @override
  String get score => 'Score: ';

  @override
  String get left_text => 'Press the left side \nto crouch';

  @override
  String get right_text => 'Press the right side \nto jump';
}
