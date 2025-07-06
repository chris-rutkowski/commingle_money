import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('zero', () {
      final money = Money.zero('USD');
      expect(money, Money(currencyCode: 'USD', amount: Decimal.zero));
    });

    test('copyWith', () {
      final original = Money(currencyCode: 'USD', amount: Decimal.parse('10.00'));

      final updated = original.copyWith(amount: Decimal.parse('20.00'));
      expect(updated, Money(currencyCode: 'USD', amount: Decimal.fromInt(20)));

      final updated2 = updated.copyWith(currencyCode: 'PLN');
      expect(updated2, Money(currencyCode: 'PLN', amount: Decimal.fromInt(20)));
    });

    test('toString ', () {
      final money = Money(currencyCode: 'USD', amount: Decimal.parse('99.99'));
      expect(money.toString(), 'USD 99.99');
    });

    group('components', () {
      test('USD 123.45', () {
        final money = Money(currencyCode: 'USD', amount: Decimal.parse('123.45'));
        final components = money.components;
        expect(components.main, 123);
        expect(components.fractional, 45);
      });

      test('USD 0.99', () {
        final money = Money(currencyCode: 'USD', amount: Decimal.parse('0.99'));
        final components = money.components;
        expect(components.main, 0);
        expect(components.fractional, 99);
      });

      test('USD -0.99', () {
        final money = Money(currencyCode: 'USD', amount: Decimal.parse('-0.99'));
        final components = money.components;
        expect(components.main, 0);
        expect(components.fractional, 99);
      });

      test('-12.34', () {
        final money = Money(currencyCode: 'USD', amount: Decimal.parse('-12.34'));
        final components = money.components;
        expect(components.main, -12);
        expect(components.fractional, 34);
      });

      test('JPY 1234', () {
        final money = Money(currencyCode: 'JPY', amount: Decimal.parse('1234'));
        final components = money.components;
        expect(components.main, 1234);
        expect(components.fractional, 0);
      });

      test('TND 98.765', () {
        final money = Money(currencyCode: 'TND', amount: Decimal.parse('98.765'));
        final components = money.components;
        expect(components.main, 98);
        expect(components.fractional, 765);
      });
    });
  });
}
