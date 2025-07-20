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

    group('math', () {
      final usd1 = Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('1'));
      final usd2 = Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('2'));
      final usd3 = Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('3'));
      final usd4 = Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('4'));
      final usd10 = Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('10'));
      final aed4 = Money(currencyCode: CurrencyCodes.aed, amount: Decimal.parse('4'));

      group('adding', () {
        test('normal', () {
          expect(usd3 + usd4 + 2 + 2.5, Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('11.5')));
        });

        test('rounding', () {
          expect(usd3 + 1.375, Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('4.38')));
        });

        test('exceptions', () {
          expect(() => usd4 + aed4, throwsA(anything));
          expect(() => usd4 + 'text', throwsA(anything));
        });
      });

      group('abs', () {
        test('positive', () {
          expect(
            Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('3.25')).abs(),
            Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('3.25')),
          );
        });

        test('negative', () {
          expect(
            Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('-3.25')).abs(),
            Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('3.25')),
          );
        });

        test('zero', () {
          expect(
            Money(currencyCode: CurrencyCodes.usd, amount: Decimal.zero).abs(),
            Money(currencyCode: CurrencyCodes.usd, amount: Decimal.zero),
          );
        });
      });

      group('subtraction', () {
        test('normal', () {
          expect(usd10 - usd1 - 2 - 2.5, Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('4.5')));
        });

        test('rounding', () {
          expect(usd10 - 1.375, Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('8.63')));
        });

        test('exceptions', () {
          expect(() => usd4 - aed4, throwsA(anything));
          expect(() => usd4 - 'text', throwsA(anything));
        });
      });

      group('multiplication', () {
        test('normal', () {
          expect(usd3 * usd2 * 4 * 2.5, Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('60')));
        });

        test('rounding', () {
          expect(usd10 * 1.1234, Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('11.23')));
        });

        test('exceptions', () {
          expect(() => usd4 * aed4, throwsA(anything));
          expect(() => usd4 * 'text', throwsA(anything));
        });
      });

      group('division', () {
        test('normal', () {
          expect(usd10 / usd2, Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('5')));
          expect(usd10 / 4, Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('2.5')));
          expect(usd10 / 2.5, Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('4')));
        });

        test('rounding', () {
          expect(usd10 / 1.1234, Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('8.9')));
        });

        test('exceptions', () {
          expect(() => usd4 / aed4, throwsA(anything));
          expect(() => usd4 / 'text', throwsA(anything));
          expect(() => usd4 / 0, throwsA(anything));
        });
      });
    });
  });
}
