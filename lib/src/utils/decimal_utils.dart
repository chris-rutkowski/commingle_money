import 'package:decimal/decimal.dart';

/// Various Decimal utilities
extension DecimalUtils on Decimal {
  /// Rounds the [Decimal] value to the specified `scale` or the default of 2.
  Decimal round2({int? scale}) {
    return round(scale: scale ?? 2);
  }

  /// Returns a rounded-up version of this [Decimal]
  /// This is useful for calculating an upper bound for display purposes,
  /// such as setting a clean maximum value for a chart axis.
  /// e.g. `1234.56` → `1300`
  Decimal get upperBound {
    final rounded = ceil();
    final roundedPrecision = rounded.precision;
    final cut = rounded.shift(-roundedPrecision + 2);
    final ceiled = cut.ceil();
    return ceiled.shift(roundedPrecision - 2);
  }

  /// Returns a rounded-down version of this [Decimal]
  /// This is useful for calculating a lower bound for display purposes,
  /// such as setting a clean minimum value for a chart axis.
  /// e.g. `1234.56` → `1200`
  Decimal get lowerBound {
    final rounded = floor();
    final roundedPrecision = rounded.precision;
    final cut = rounded.shift(-roundedPrecision + 2);
    final floored = cut.floor();
    return floored.shift(roundedPrecision - 2);
  }

  /// Converts a [double] to a [Decimal].
  static Decimal fromDouble(double value) => Decimal.parse(value.toString());

  /// Sums a collection of [Decimal] values.
  static Decimal sum(Iterable<Decimal> decimals) {
    return decimals.fold(Decimal.zero, (sum, value) => sum + value);
  }

  /// Returns `0.01` - the smallest unit for most currencies.
  static Decimal get cent => Decimal.parse('0.01');

  /// Returns the larger of two numbers.
  static Decimal max(Decimal a, Decimal b) {
    return a > b ? a : b;
  }

  /// Returns the lesser of two numbers.
  static Decimal min(Decimal a, Decimal b) {
    return a < b ? a : b;
  }
}
