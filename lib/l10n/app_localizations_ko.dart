// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get popupListTitle => 'Popup Store List';

  @override
  String get hello => '안녕';

  @override
  String get place_jamsil => '잠실';

  @override
  String get place_sungsu => '성수';

  @override
  String get place_gangnam => '강남';

  @override
  String get place_euljiro => '을지로';

  @override
  String get place_hongdae => '홍대';

  @override
  String get place_etc => '기타';

  @override
  String get place_all => '전체';
}
