import 'dart:math';

import 'package:decimal/decimal.dart';

/// Various Decimal utilities
extension DecimalUtils on Decimal {
  /// Converts a [double] to a [Decimal].
  static Decimal fromDouble(double value) => Decimal.parse(value.toString());

  /// Sums a collection of [Decimal] values.
  static Decimal sum(Iterable<Decimal> decimals) {
    return decimals.fold(Decimal.zero, (sum, value) => sum + value);
  }

  /// Returns `0.01` - the smallest unit for most currencies.
  static Decimal get cent => Decimal.parse('0.01');

  /// Rounds the [Decimal] value to the specified `scale` or the default of 2.
  Decimal round2({int? scale}) {
    return round(scale: scale ?? 2);
  }

  /// Returns the larger of two numbers.
  static Decimal max(Decimal a, Decimal b) {
    return a > b ? a : b;
  }

  /// Returns the lesser of two numbers.
  static Decimal min(Decimal a, Decimal b) {
    return a < b ? a : b;
  }
}
