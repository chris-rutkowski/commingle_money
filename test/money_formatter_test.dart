import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyFormatter', () {
    test('positive USD', () {
      final formatter = const MoneyFormatter();
      expect(formatter.format(Money.usd(Decimal.parse('1234.56'))), '\$ 1,234.56');
    });

    test('negative EUR', () {
      final formatter = const MoneyFormatter();
      expect(formatter.format(Money.eur(Decimal.parse('-6126.99'))), '€ -6,126.99');
    });

    test('zero HKD', () {
      final formatter = const MoneyFormatter();
      expect(formatter.format(Money(currencyCode: 'HKD', amount: Decimal.zero)), 'HKD 0');
    });

    test('always decimal PLN', () {
      final formatter = const MoneyFormatter(
        fractionalMode: FractionalMode.always,
      );
      expect(formatter.format(Money(currencyCode: 'PLN', amount: Decimal.fromInt(123))), 'zł 123.00');
    });

    test('round up AUD', () {
      final formatter = const MoneyFormatter(
        fractionalMode: FractionalMode.round,
      );
      expect(formatter.format(Money(currencyCode: CurrencyCodes.aud, amount: Decimal.parse('5623.5'))), 'AUD 5,624');
    });

    test('round down CNY', () {
      final formatter = const MoneyFormatter(
        fractionalMode: FractionalMode.round,
      );
      expect(formatter.format(Money(currencyCode: CurrencyCodes.cny, amount: Decimal.parse('72316.49'))), 'CNY 72,316');
    });

    test('accurate 4 digits INR', () {
      final formatter = const MoneyFormatter(
        fractionalMode: FractionalMode.accurate,
      );
      expect(
        formatter.format(Money(currencyCode: CurrencyCodes.inr, amount: Decimal.parse('84321.6225'))),
        '₹ 84,321.6225',
      );
    });

    test('accurate 4 digits IRR', () {
      final formatter = const MoneyFormatter(
        fractionalMode: FractionalMode.accurate,
      );
      expect(
        formatter.format(Money(currencyCode: CurrencyCodes.irr, amount: Decimal.parse('7281.1'))),
        'IRR 7,281.1',
      );
    });

    test('accurate 0 digits ZAR', () {
      final formatter = const MoneyFormatter(
        fractionalMode: FractionalMode.accurate,
      );
      expect(
        formatter.format(Money(currencyCode: CurrencyCodes.zar, amount: Decimal.parse('241'))),
        'ZAR 241',
      );
    });

    test('negative with sign SGD', () {
      final formatter = const MoneyFormatter(
        fractionalMode: FractionalMode.accurate,
      );
      expect(
        formatter.format(Money(currencyCode: CurrencyCodes.sgd, amount: Decimal.parse('-126.1'))),
        'SGD -126.1',
      );
    });

    test('negative without sign SGD', () {
      final formatter = const MoneyFormatter(
        fractionalMode: FractionalMode.accurate,
        displayNegativeSign: false,
      );
      expect(
        formatter.format(Money(currencyCode: CurrencyCodes.sgd, amount: Decimal.parse('-126.1'))),
        'SGD 126.1',
      );
    });

    test('compact 99.0 BIF', () {
      final formatter = const MoneyFormatter(
        fractionalMode: FractionalMode.compact,
      );
      expect(
        formatter.format(Money(currencyCode: CurrencyCodes.bif, amount: Decimal.parse('99'))),
        'BIF 99',
      );
    });

    test('compact 99.99 BMD', () {
      final formatter = const MoneyFormatter(
        fractionalMode: FractionalMode.compact,
      );
      expect(
        formatter.format(Money(currencyCode: CurrencyCodes.bmd, amount: Decimal.parse('99.99'))),
        'BMD 99.99',
      );
    });
  });
}
