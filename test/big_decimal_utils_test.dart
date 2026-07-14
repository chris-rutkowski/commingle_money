import 'package:commingle_money/commingle_money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BigDecimalUtils', () {
    test('round2', () {
      expect(BigDecimal.parse('123.456').round2(), BigDecimal.parse('123.46'));
      expect(BigDecimal.parse('123.454').round2(), BigDecimal.parse('123.45'));
      expect(BigDecimal.parse('0.005').round2(), BigDecimal.parse('0.01'));
      expect(BigDecimal.parse('-1.2345').round2(), BigDecimal.parse('-1.23'));
      expect(BigDecimal.parse('-1.2345').round2(scale: 3), BigDecimal.parse('-1.235'));
      expect(BigDecimal.parse('0.0001').round2(), BigDecimal.parse('0.00'));
      expect(BigDecimal.zero.round2(), BigDecimal.zero);
    });

    test('upperBound', () {
      expect(BigDecimal.parse('1234.56').upperBound, BigDecimal.parse('1300'));
      expect(BigDecimal.parse('999').upperBound, BigDecimal.parse('1000'));
      expect(BigDecimal.parse('0.01234').upperBound, BigDecimal.parse('1'));
      expect(BigDecimal.parse('-4567.89').upperBound, BigDecimal.parse('-4500'));
      expect(BigDecimal.zero.upperBound, BigDecimal.zero);
      expect(BigDecimal.parse('9').upperBound, BigDecimal.parse('9'));
    });

    test('lowerBound', () {
      expect(BigDecimal.parse('1234.56').lowerBound, BigDecimal.parse('1200'));
      expect(BigDecimal.parse('999').lowerBound, BigDecimal.parse('990'));
      expect(BigDecimal.parse('0.01234').lowerBound, BigDecimal.parse('0'));
      expect(BigDecimal.parse('-4567.89').lowerBound, BigDecimal.parse('-4600'));
      expect(BigDecimal.zero.lowerBound, BigDecimal.zero);
      expect(BigDecimal.parse('9').lowerBound, BigDecimal.parse('9'));
    });

    group('additional upper/lower bound', () {
      test('upper bound positive', () {
        expect(BigDecimal.parse('433375.78').upperBound, BigDecimal.parse('440000'));
        expect(BigDecimal.parse('430000.01').upperBound, BigDecimal.parse('440000'));
        expect(BigDecimal.parse('430000.00').upperBound, BigDecimal.parse('430000'));

        expect(BigDecimal.parse('433.37').upperBound, BigDecimal.parse('440'));
        expect(BigDecimal.parse('430.01').upperBound, BigDecimal.parse('440'));
        expect(BigDecimal.parse('430.00').upperBound, BigDecimal.parse('430'));

        expect(BigDecimal.parse('43.37').upperBound, BigDecimal.parse('44'));
        expect(BigDecimal.parse('43.01').upperBound, BigDecimal.parse('44'));
        expect(BigDecimal.parse('43.00').upperBound, BigDecimal.parse('43'));

        expect(BigDecimal.parse('9.99').upperBound, BigDecimal.parse('10'));
        expect(BigDecimal.parse('3.99').upperBound, BigDecimal.parse('4'));
        expect(BigDecimal.parse('0.99').upperBound, BigDecimal.parse('1'));
        expect(BigDecimal.parse('0.39').upperBound, BigDecimal.parse('1'));
        expect(BigDecimal.parse('0.09').upperBound, BigDecimal.parse('1'));
        expect(BigDecimal.parse('0.00').upperBound, BigDecimal.parse('0'));
      });

      test('upper bound negative', () {
        expect(BigDecimal.parse('-433375.78').upperBound, BigDecimal.parse('-430000'));
        expect(BigDecimal.parse('-430000.01').upperBound, BigDecimal.parse('-430000'));
        expect(BigDecimal.parse('-430000.00').upperBound, BigDecimal.parse('-430000'));
        expect(BigDecimal.parse('-429999.99').upperBound, BigDecimal.parse('-420000'));

        expect(BigDecimal.parse('-43.37').upperBound, BigDecimal.parse('-43'));
        expect(BigDecimal.parse('-43.01').upperBound, BigDecimal.parse('-43'));
        expect(BigDecimal.parse('-43.00').upperBound, BigDecimal.parse('-43'));
        expect(BigDecimal.parse('-42.99').upperBound, BigDecimal.parse('-42'));
        expect(BigDecimal.parse('-9.99').upperBound, BigDecimal.parse('-9'));
        expect(BigDecimal.parse('-0.39').upperBound, BigDecimal.parse('0'));
        expect(BigDecimal.parse('-0.09').upperBound, BigDecimal.parse('0'));
      });

      test('lower bound positive', () {
        expect(BigDecimal.parse('433375.78').lowerBound, BigDecimal.parse('430000'));
        expect(BigDecimal.parse('430000.01').lowerBound, BigDecimal.parse('430000'));
        expect(BigDecimal.parse('430000.00').lowerBound, BigDecimal.parse('430000'));

        expect(BigDecimal.parse('433.37').lowerBound, BigDecimal.parse('430'));
        expect(BigDecimal.parse('430.01').lowerBound, BigDecimal.parse('430'));
        expect(BigDecimal.parse('430.00').lowerBound, BigDecimal.parse('430'));

        expect(BigDecimal.parse('43.37').lowerBound, BigDecimal.parse('43'));
        expect(BigDecimal.parse('43.01').lowerBound, BigDecimal.parse('43'));
        expect(BigDecimal.parse('43.00').lowerBound, BigDecimal.parse('43'));

        expect(BigDecimal.parse('9.99').lowerBound, BigDecimal.parse('9'));
        expect(BigDecimal.parse('3.99').lowerBound, BigDecimal.parse('3'));
        expect(BigDecimal.parse('0.99').lowerBound, BigDecimal.parse('0'));
        expect(BigDecimal.parse('0.39').lowerBound, BigDecimal.parse('0'));
        expect(BigDecimal.parse('0.09').lowerBound, BigDecimal.parse('0'));
        expect(BigDecimal.parse('0.00').lowerBound, BigDecimal.parse('0'));
      });

      test('lower bound negative', () {
        expect(BigDecimal.parse('-433375.78').lowerBound, BigDecimal.parse('-440000'));
        expect(BigDecimal.parse('-430000.01').lowerBound, BigDecimal.parse('-440000'));
        expect(BigDecimal.parse('-430000.00').lowerBound, BigDecimal.parse('-430000'));
        expect(BigDecimal.parse('-429999.99').lowerBound, BigDecimal.parse('-430000'));

        expect(BigDecimal.parse('-43.37').lowerBound, BigDecimal.parse('-44'));
        expect(BigDecimal.parse('-43.01').lowerBound, BigDecimal.parse('-44'));
        expect(BigDecimal.parse('-43.00').lowerBound, BigDecimal.parse('-43'));
        expect(BigDecimal.parse('-42.99').lowerBound, BigDecimal.parse('-43'));
        expect(BigDecimal.parse('-9.99').lowerBound, BigDecimal.parse('-10'));
        expect(BigDecimal.parse('-0.39').lowerBound, BigDecimal.parse('-1'));
        expect(BigDecimal.parse('-0.09').lowerBound, BigDecimal.parse('-1'));
      });
    });

    test('truncateToInt', () {
      expect(BigDecimal.parse('42.99').truncateToInt(), 42);
      expect(BigDecimal.parse('-42.99').truncateToInt(), -42);
      expect(BigDecimal.parse('0.0001').truncateToInt(), 0);
      expect(BigDecimal.parse('100').truncateToInt(), 100);
    });

    test('fromDouble', () {
      expect(BigDecimalUtils.fromDouble(123.45), BigDecimal.parse('123.45'));
      expect(BigDecimalUtils.fromDouble(0.0000001), BigDecimal.parse('0.0000001'));
      expect(BigDecimalUtils.fromDouble(1e12), BigDecimal.parse('1000000000000'));
      expect(BigDecimalUtils.fromDouble(-987.654), BigDecimal.parse('-987.654'));
      expect(BigDecimalUtils.fromDouble(0.0), BigDecimal.zero);
      expect(() => BigDecimalUtils.fromDouble(double.infinity), throwsA(anything));
      expect(() => BigDecimalUtils.fromDouble(double.nan), throwsA(anything));
    });

    test('sum', () {
      expect(BigDecimalUtils.sum([BigDecimal.parse('1.00'), BigDecimal.parse('2.50')]), BigDecimal.parse('3.50'));
      expect(BigDecimalUtils.sum([]), BigDecimal.zero);
      expect(
        BigDecimalUtils.sum([BigDecimal.parse('0.01'), BigDecimal.parse('0.02'), BigDecimal.parse('0.03')]),
        BigDecimal.parse('0.06'),
      );
      expect(
        BigDecimalUtils.sum([BigDecimal.parse('1.00'), BigDecimal.parse('-2.50'), BigDecimalUtils.cent]),
        BigDecimal.parse('-1.49'),
      );
      expect(() => BigDecimalUtils.sum([BigDecimal.parse('NaN')]), throwsA(anything));
    });

    test('max', () {
      expect(BigDecimalUtils.max(BigDecimal.parse('5.5'), BigDecimal.parse('2.2')), BigDecimal.parse('5.5'));
      expect(BigDecimalUtils.max(BigDecimal.parse('-1.0'), BigDecimal.parse('-2.0')), BigDecimal.parse('-1.0'));
      expect(BigDecimalUtils.max(BigDecimal.parse('3.1415'), BigDecimal.parse('3.1415')), BigDecimal.parse('3.1415'));
      expect(BigDecimalUtils.max(BigDecimal.zero, BigDecimal.parse('0.0001')), BigDecimal.parse('0.0001'));
    });

    test('min', () {
      expect(BigDecimalUtils.min(BigDecimal.parse('5.5'), BigDecimal.parse('2.2')), BigDecimal.parse('2.2'));
      expect(BigDecimalUtils.min(BigDecimal.parse('-1.0'), BigDecimal.parse('-2.0')), BigDecimal.parse('-2.0'));
      expect(BigDecimalUtils.min(BigDecimal.parse('3.1415'), BigDecimal.parse('3.1415')), BigDecimal.parse('3.1415'));
      expect(BigDecimalUtils.min(BigDecimal.zero, BigDecimal.parse('0.0001')), BigDecimal.zero);
    });
  });
}
