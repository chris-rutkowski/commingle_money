import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecimalComponents.fromDecimal', () {
    test('parses integer-only value', () {
      final components = DecimalComponents.fromDecimal(Decimal.parse('42'));
      expect(components.main, 42);
      expect(components.fractional, 0);
    });

    test('parses decimal with two digits', () {
      final components = DecimalComponents.fromDecimal(Decimal.parse('12.34'));
      expect(components.main, 12);
      expect(components.fractional, 34);
    });

    test('parses decimal with trailing zeros', () {
      final components = DecimalComponents.fromDecimal(Decimal.parse('12.3400'));
      expect(components.main, 12);
      expect(components.fractional, 3400);
    });

    test('parses small fractional value', () {
      final components = DecimalComponents.fromDecimal(Decimal.parse('0.0007'));
      expect(components.main, 0);
      expect(components.fractional, 7);
    });

    test('parses negative value', () {
      final components = DecimalComponents.fromDecimal(Decimal.parse('-987.654'));
      expect(components.main, -987);
      expect(components.fractional, 654); // always positive
    });

    test('parses zero', () {
      final components = DecimalComponents.fromDecimal(Decimal.zero);
      expect(components.main, 0);
      expect(components.fractional, 0);
    });
  });
}
