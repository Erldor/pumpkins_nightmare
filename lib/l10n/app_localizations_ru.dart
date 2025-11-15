// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get max_score => 'Рекорд: ';

  @override
  String get score => 'Очки: ';

  @override
  String get left_text => 'Нажмите на левую сторону, \nчтобы присесть';

  @override
  String get right_text => 'Нажмите на правую сторону, \nчтобы прыгнуть';
}
