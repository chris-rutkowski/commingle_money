import 'package:big_decimal/big_decimal.dart';
import 'package:commingle_money/commingle_money.dart';
import 'package:commingle_money/src/controllers/private/format_decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BigDecimal semantics', () {
    test('value equality ignores scale (exactlyEquals does not)', () {
      final a = BigDecimal.parse('1.10');
      final b = BigDecimal.parse('1.1');

      expect(a, b);
      expect(a == b, isTrue);
      expect(a.exactlyEquals(b), isFalse);
      expect(a.scale, 2);
      expect(b.scale, 1);
    });

    test('Money and controllers treat differently-scaled amounts as equal', () {
      final scaled = BigDecimal.parse('1.10');
      final plain = BigDecimal.parse('1.1');

      expect(
        Money(currencyCode: CurrencyCodes.usd, amount: scaled),
        Money(currencyCode: CurrencyCodes.usd, amount: plain),
      );

      final controller = AmountEditingController(amount: scaled, precision: 2);
      expect(controller.value, plain);
      controller.value = plain;
      expect(controller.value, scaled);
      controller.dispose();
    });

    test('toPlainString keeps scientific forms exact for formatting', () {
      final large = BigDecimalUtils.fromDouble(1e12);
      expect(large.toPlainString(), anyOf('1000000000000', '1000000000000.0'));
      expect(
        formatDecimal(
          large,
          separators: const AmountFormatSeparatorsData(),
        ),
        '1,000,000,000,000',
      );

      final tiny = BigDecimal.parse('0.0000001');
      expect(tiny.toPlainString(), '0.0000001');
      expect(
        formatDecimal(
          tiny,
          separators: const AmountFormatSeparatorsData(),
        ),
        '0.0000001',
      );
    });

    test('fromDouble rejects infinity and NaN', () {
      expect(() => BigDecimalUtils.fromDouble(double.infinity), throwsArgumentError);
      expect(() => BigDecimalUtils.fromDouble(double.negativeInfinity), throwsArgumentError);
      expect(() => BigDecimalUtils.fromDouble(double.nan), throwsArgumentError);
    });

    test('BigDecimal.parse admits Infinity but Money paths must not use it', () {
      final infinity = BigDecimal.parse(double.infinity.toString());
      expect(infinity, isA<BigDecimalInfinity>());

      expect(
        () => Money(currencyCode: CurrencyCodes.usd, amount: infinity) + 1,
        throwsA(anything),
      );
    });

    test('division uses HALF_UP at currency precision', () {
      final ten = Money(currencyCode: CurrencyCodes.usd, amount: BigDecimal.parse('10'));
      final three = Money(currencyCode: CurrencyCodes.usd, amount: BigDecimal.parse('3'));
      expect(ten / three, Money(currencyCode: CurrencyCodes.usd, amount: BigDecimal.parse('3.33')));

      final one = Money(currencyCode: CurrencyCodes.usd, amount: BigDecimal.parse('1'));
      expect(one / three, Money(currencyCode: CurrencyCodes.usd, amount: BigDecimal.parse('0.33')));

      final bhd = Money(currencyCode: CurrencyCodes.bhd, amount: BigDecimal.parse('1'));
      expect(
        bhd / BigDecimal.parse('3'),
        Money(currencyCode: CurrencyCodes.bhd, amount: BigDecimal.parse('0.333')),
      );
    });

    test('truncating division rounds toward zero', () {
      final ten = Money(currencyCode: CurrencyCodes.usd, amount: BigDecimal.parse('10'));
      expect(ten ~/ 3, Money(currencyCode: CurrencyCodes.usd, amount: BigDecimal.parse('3')));

      final negative = Money(currencyCode: CurrencyCodes.usd, amount: BigDecimal.parse('-10'));
      expect(negative ~/ 3, Money(currencyCode: CurrencyCodes.usd, amount: BigDecimal.parse('-3')));

      expect(ten ~/ BigDecimal.parse('2.5'), Money(currencyCode: CurrencyCodes.usd, amount: BigDecimal.parse('4')));
    });

    test('shift, round, and truncateToInt helpers', () {
      expect(BigDecimal.parse('12.345').shift(2), BigDecimal.parse('1234.5'));
      expect(BigDecimal.parse('12.345').shift(-2), BigDecimal.parse('0.12345'));
      expect(BigDecimal.parse('-12.345').shift(1), BigDecimal.parse('-123.45'));

      expect(BigDecimal.parse('1.235').round(scale: 2), BigDecimal.parse('1.24'));
      expect(BigDecimal.parse('1.234').round(scale: 2), BigDecimal.parse('1.23'));
      expect(BigDecimal.parse('-1.235').round(scale: 2), BigDecimal.parse('-1.24'));

      expect(BigDecimal.parse('42.99').truncateToInt(), 42);
      expect(BigDecimal.parse('-42.99').truncateToInt(), -42);
      expect(BigDecimal.parse('0.9').truncate(), BigDecimal.zero);
      expect(BigDecimal.parse('-0.9').truncate(), BigDecimal.zero);
    });

    test('formatting pads trailing zeros even when scale differs', () {
      final separators = const AmountFormatSeparatorsData();

      expect(
        formatDecimal(BigDecimal.parse('1.1'), precision: 2, separators: separators),
        '1.10',
      );
      expect(
        formatDecimal(BigDecimal.parse('1.10'), precision: 2, separators: separators),
        '1.10',
      );
      expect(
        formatDecimal(BigDecimal.parse('1'), precision: 2, separators: separators),
        '1',
      );
      expect(
        formatDecimal(BigDecimal.parse('1.00'), precision: 2, separators: separators),
        '1',
      );
    });

    test('toOperandString strips trailing fractional zeros', () {
      expect(BigDecimal.parse('1.10').toOperandString(), '1.1');
      expect(BigDecimal.parse('1.00').toOperandString(), '1');
      expect(BigDecimal.parse('10').toOperandString(), '10');
      expect(BigDecimal.parse('0.100').toOperandString(), '0.1');
      expect(BigDecimal.parse('-2.50').toOperandString(), '-2.5');
    });

    test('smallestAmount for common and high precision currencies', () {
      expect(Currency.fromCode(CurrencyCodes.usd)!.smallestAmount, BigDecimal.parse('0.01'));
      expect(Currency.fromCode(CurrencyCodes.bhd)!.smallestAmount, BigDecimal.parse('0.001'));
      expect(Currency.fromCode(CurrencyCodes.irr)!.smallestAmount, BigDecimal.parse('0.01'));
      expect(
        Currency.fromCode(CurrencyCodes.btc)!.smallestAmount,
        BigDecimal.parse('0.00000001'),
      );
      expect(
        Currency.fromCode(CurrencyCodes.btc)!.smallestAmount.scale,
        8,
      );
    });
  });
}
