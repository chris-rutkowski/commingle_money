// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';

enum DisplayNumeralSystem {
  latin,
  arabicIndic,
  easternArabicIndic
  ;

  static DisplayNumeralSystem fromLocale(Locale locale) {
    return switch (locale.languageCode.toLowerCase()) {
      'ar' => DisplayNumeralSystem.arabicIndic,
      'fa' || 'ur' => DisplayNumeralSystem.easternArabicIndic,
      _ => DisplayNumeralSystem.latin,
    };
  }

  static DisplayNumeralSystem? fromInput(String value) {
    for (final character in value.split('')) {
      if (_arabicIndicDigits.contains(character)) {
        return DisplayNumeralSystem.arabicIndic;
      }

      if (_easternArabicIndicDigits.contains(character)) {
        return DisplayNumeralSystem.easternArabicIndic;
      }

      if (_latinDigits.contains(character)) {
        return DisplayNumeralSystem.latin;
      }
    }

    return null;
  }

  String localizeText(String value) {
    return value.split('').map(localizeCharacter).join();
  }

  String localizeCharacter(String value) {
    return switch (this) {
      DisplayNumeralSystem.latin => value,
      DisplayNumeralSystem.arabicIndic => _localizeDigit(value, _arabicIndicDigits),
      DisplayNumeralSystem.easternArabicIndic => _localizeDigit(value, _easternArabicIndicDigits),
    };
  }

  String _localizeDigit(String value, List<String> digits) {
    final digit = int.tryParse(value);

    if (digit == null) {
      return value;
    }

    return digits[digit];
  }
}

const _latinDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
const _arabicIndicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
const _easternArabicIndicDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
