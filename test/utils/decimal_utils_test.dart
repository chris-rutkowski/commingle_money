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
  });
}
