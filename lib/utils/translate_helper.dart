import 'package:flutter/material.dart';
import 'package:popup_app/l10n/app_localizations.dart';

String translatePlace(BuildContext context, String original) {
  final map = {
    '잠실': AppLocalizations.of(context)!.place_jamsil,
    '홍대': AppLocalizations.of(context)!.place_hongdae,
    '성수':AppLocalizations.of(context)!.place_sungsu,
    '을지로':AppLocalizations.of(context)!.place_euljiro,
    '기타':AppLocalizations.of(context)!.place_etc,
  };
  return map[original] ?? original;
}