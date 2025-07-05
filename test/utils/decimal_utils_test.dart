import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecimalUtils', () {
    test('round2', () {
      expect(Decimal.parse('123.456').round2(), Decimal.parse('123.46'));
      expect(Decimal.parse('123.454').round2(), Decimal.parse('123.45'));
      expect(Decimal.parse('0.005').round2(), Decimal.parse('0.01'));
      expect(Decimal.parse('-1.2345').round2(), Decimal.parse('-1.23'));
      expect(Decimal.parse('-1.2345').round2(scale: 3), Decimal.parse('-1.235'));
      expect(Decimal.parse('0.0001').round2(), Decimal.parse('0.00'));
      expect(Decimal.zero.round2(), Decimal.zero);
    });

    test('upperBound', () {
      expect(Decimal.parse('1234.56').upperBound, Decimal.parse('1300'));
      expect(Decimal.parse('999').upperBound, Decimal.parse('1000'));
      expect(Decimal.parse('0.01234').upperBound, Decimal.parse('1'));
      expect(Decimal.parse('-4567.89').upperBound, Decimal.parse('-4500'));
      expect(Decimal.zero.upperBound, Decimal.zero);
      expect(Decimal.parse('9').upperBound, Decimal.parse('9'));
    });

    test('lowerBound', () {
      expect(Decimal.parse('1234.56').lowerBound, Decimal.parse('1200'));
      expect(Decimal.parse('999').lowerBound, Decimal.parse('990'));
      expect(Decimal.parse('0.01234').lowerBound, Decimal.parse('0'));
      expect(Decimal.parse('-4567.89').lowerBound, Decimal.parse('-4600'));
      expect(Decimal.zero.lowerBound, Decimal.zero);
      expect(Decimal.parse('9').lowerBound, Decimal.parse('9'));
    });

    group('additional upper/lower bound', () {
      test('upper bound positive', () {
        expect(Decimal.parse('433375.78').upperBound, Decimal.parse('440000'));
        expect(Decimal.parse('430000.01').upperBound, Decimal.parse('440000'));
        expect(Decimal.parse('430000.00').upperBound, Decimal.parse('430000'));

        expect(Decimal.parse('433.37').upperBound, Decimal.parse('440'));
        expect(Decimal.parse('430.01').upperBound, Decimal.parse('440'));
        expect(Decimal.parse('430.00').upperBound, Decimal.parse('430'));

        expect(Decimal.parse('43.37').upperBound, Decimal.parse('44'));
        expect(Decimal.parse('43.01').upperBound, Decimal.parse('44'));
        expect(Decimal.parse('43.00').upperBound, Decimal.parse('43'));

        expect(Decimal.parse('9.99').upperBound, Decimal.parse('10'));
        expect(Decimal.parse('3.99').upperBound, Decimal.parse('4'));
        expect(Decimal.parse('0.99').upperBound, Decimal.parse('1'));
        expect(Decimal.parse('0.39').upperBound, Decimal.parse('1'));
        expect(Decimal.parse('0.09').upperBound, Decimal.parse('1'));
        expect(Decimal.parse('0.00').upperBound, Decimal.parse('0'));
      });

      test('upper bound negative', () {
        expect(Decimal.parse('-433375.78').upperBound, Decimal.parse('-430000'));
        expect(Decimal.parse('-430000.01').upperBound, Decimal.parse('-430000'));
        expect(Decimal.parse('-430000.00').upperBound, Decimal.parse('-430000'));
        expect(Decimal.parse('-429999.99').upperBound, Decimal.parse('-420000'));

        expect(Decimal.parse('-43.37').upperBound, Decimal.parse('-43'));
        expect(Decimal.parse('-43.01').upperBound, Decimal.parse('-43'));
        expect(Decimal.parse('-43.00').upperBound, Decimal.parse('-43'));
        expect(Decimal.parse('-42.99').upperBound, Decimal.parse('-42'));
        expect(Decimal.parse('-9.99').upperBound, Decimal.parse('-9'));
        expect(Decimal.parse('-0.39').upperBound, Decimal.parse('0'));
        expect(Decimal.parse('-0.09').upperBound, Decimal.parse('0'));
      });

      test('lower bound positive', () {
        expect(Decimal.parse('433375.78').lowerBound, Decimal.parse('430000'));
        expect(Decimal.parse('430000.01').lowerBound, Decimal.parse('430000'));
        expect(Decimal.parse('430000.00').lowerBound, Decimal.parse('430000'));

        expect(Decimal.parse('433.37').lowerBound, Decimal.parse('430'));
        expect(Decimal.parse('430.01').lowerBound, Decimal.parse('430'));
        expect(Decimal.parse('430.00').lowerBound, Decimal.parse('430'));

        expect(Decimal.parse('43.37').lowerBound, Decimal.parse('43'));
        expect(Decimal.parse('43.01').lowerBound, Decimal.parse('43'));
        expect(Decimal.parse('43.00').lowerBound, Decimal.parse('43'));

        expect(Decimal.parse('9.99').lowerBound, Decimal.parse('9'));
        expect(Decimal.parse('3.99').lowerBound, Decimal.parse('3'));
        expect(Decimal.parse('0.99').lowerBound, Decimal.parse('0'));
        expect(Decimal.parse('0.39').lowerBound, Decimal.parse('0'));
        expect(Decimal.parse('0.09').lowerBound, Decimal.parse('0'));
        expect(Decimal.parse('0.00').lowerBound, Decimal.parse('0'));
      });

      test('lower bound negative', () {
        expect(Decimal.parse('-433375.78').lowerBound, Decimal.parse('-440000'));
        expect(Decimal.parse('-430000.01').lowerBound, Decimal.parse('-440000'));
        expect(Decimal.parse('-430000.00').lowerBound, Decimal.parse('-430000'));
        expect(Decimal.parse('-429999.99').lowerBound, Decimal.parse('-430000'));

        expect(Decimal.parse('-43.37').lowerBound, Decimal.parse('-44'));
        expect(Decimal.parse('-43.01').lowerBound, Decimal.parse('-44'));
        expect(Decimal.parse('-43.00').lowerBound, Decimal.parse('-43'));
        expect(Decimal.parse('-42.99').lowerBound, Decimal.parse('-43'));
        expect(Decimal.parse('-9.99').lowerBound, Decimal.parse('-10'));
        expect(Decimal.parse('-0.39').lowerBound, Decimal.parse('-1'));
        expect(Decimal.parse('-0.09').lowerBound, Decimal.parse('-1'));
      });
    });

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

    test('max', () {
      expect(DecimalUtils.max(Decimal.parse('5.5'), Decimal.parse('2.2')), Decimal.parse('5.5'));
      expect(DecimalUtils.max(Decimal.parse('-1.0'), Decimal.parse('-2.0')), Decimal.parse('-1.0'));
      expect(DecimalUtils.max(Decimal.parse('3.1415'), Decimal.parse('3.1415')), Decimal.parse('3.1415'));
      expect(DecimalUtils.max(Decimal.zero, Decimal.parse('0.0001')), Decimal.parse('0.0001'));
    });

    test('min', () {
      expect(DecimalUtils.min(Decimal.parse('5.5'), Decimal.parse('2.2')), Decimal.parse('2.2'));
      expect(DecimalUtils.min(Decimal.parse('-1.0'), Decimal.parse('-2.0')), Decimal.parse('-2.0'));
      expect(DecimalUtils.min(Decimal.parse('3.1415'), Decimal.parse('3.1415')), Decimal.parse('3.1415'));
      expect(DecimalUtils.min(Decimal.zero, Decimal.parse('0.0001')), Decimal.zero);
    });
  });
}
