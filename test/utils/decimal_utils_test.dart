import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecimalUtils', () {
    test('fromDouble', () {
      expect(DecimalUtils.fromDouble(123.45), Decimal.parse('123.45'));
      expect(DecimalUtils.fromDouble(0.0000001), Decimal.parse('0.0000001'));
      expect(DecimalUtils.fromDouble(1e12), Decimal.parse('1000000000000'));
      expect(DecimalUtils.fromDouble(-987.654), Decimal.parse('-987.654'));
      expect(DecimalUtils.fromDouble(0.0), Decimal.zero);
      expect(() => DecimalUtils.fromDouble(double.infinity), throwsA(anything));
      expect(() => DecimalUtils.fromDouble(double.nan), throwsA(anything));
    });

    test('sum', () {
      expect(DecimalUtils.sum([Decimal.parse('1.00'), Decimal.parse('2.50')]), Decimal.parse('3.50'));
      expect(DecimalUtils.sum([]), Decimal.zero);
      expect(
        DecimalUtils.sum([Decimal.parse('0.01'), Decimal.parse('0.02'), Decimal.parse('0.03')]),
        Decimal.parse('0.06'),
      );
      expect(
        DecimalUtils.sum([Decimal.parse('1.00'), Decimal.parse('-2.50'), DecimalUtils.cent]),
        Decimal.parse('-1.49'),
      );
      expect(() => DecimalUtils.sum([Decimal.parse('NaN')]), throwsA(anything));
    });

    test('round2', () {
      expect(Decimal.parse('123.456').round2(), Decimal.parse('123.46'));
      expect(Decimal.parse('123.454').round2(), Decimal.parse('123.45'));
      expect(Decimal.parse('0.005').round2(), Decimal.parse('0.01'));
      expect(Decimal.parse('-1.2345').round2(), Decimal.parse('-1.23'));
      expect(Decimal.parse('-1.2345').round2(scale: 3), Decimal.parse('-1.235'));
      expect(Decimal.parse('0.0001').round2(), Decimal.parse('0.00'));
      expect(Decimal.zero.round2(), Decimal.zero);
    });
  });
}
