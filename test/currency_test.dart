import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Currency', () {
    test('smallestAmount', () {
      expect(Currency.fromCode(CurrencyCodes.usd)!.smallestAmount, Decimal.parse('0.01'));
      expect(Currency.fromCode(CurrencyCodes.sgd)!.smallestAmount, Decimal.parse('0.1'));
      expect(Currency.fromCode(CurrencyCodes.irr)!.smallestAmount, Decimal.parse('1'));
    });

    test('list', () {
      final list = Currency.list();
      expect(list.first.code, CurrencyCodes.aed);
      expect(list.last.code, 'ZMW');
      expect(list.length, 155);
    });

    test('equals', () {
      final usdRich = Currency.fromCode('USD');
      final usdSimple = const Currency(
        code: 'USD',
        precision: 2,
        englishName: 'ignore',
        emojiFlag: 'ignore',
        englishCountryNames: {'ignore'},
      );
      final hkdSimple = const Currency(
        code: 'HKD',
        precision: 2,
        englishName: 'ignore',
        emojiFlag: 'ignore',
        englishCountryNames: {'ignore'},
      );
      expect(usdRich, usdSimple);
      expect(usdRich, isNot(hkdSimple));
    });
  });
}
