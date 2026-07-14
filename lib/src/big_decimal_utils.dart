import 'package:big_decimal/big_decimal.dart';

/// Various [BigDecimal] utilities.
extension BigDecimalUtils on BigDecimal {
  /// Rounds the [BigDecimal] value to the specified [scale] (default 2).
  BigDecimal round2({int? scale}) => round(scale: scale ?? 2);

  /// Rounds to the given [scale] using [RoundingMode.HALF_UP].
  BigDecimal round({int scale = 0}) => withScale(scale, roundingMode: RoundingMode.HALF_UP);

  /// Shifts the decimal point by [places] (positive = multiply by 10^[places]).
  BigDecimal shift(int places) {
    if (places == 0) {
      return this;
    }
    return BigDecimal(intVal: intVal, scale: scale - places);
  }

  /// Truncates toward zero to an integer [BigDecimal].
  BigDecimal truncate() => withScale(0, roundingMode: RoundingMode.DOWN);

  /// Rounds toward +∞ to an integer [BigDecimal].
  BigDecimal ceil() => withScale(0, roundingMode: RoundingMode.CEILING);

  /// Rounds toward -∞ to an integer [BigDecimal].
  BigDecimal floor() => withScale(0, roundingMode: RoundingMode.FLOOR);

  /// Converts this [BigDecimal] to an [int] by truncating any fractional part.
  int truncateToInt() => toInt(roundingMode: RoundingMode.DOWN);

  /// Returns a rounded-up version of this [BigDecimal].
  /// Useful for calculating an upper bound for display purposes,
  /// such as setting a clean maximum value for a chart axis.
  /// e.g. `1234.56` → `1300`
  BigDecimal get upperBound {
    final rounded = ceil();
    final roundedPrecision = rounded.precision;
    final cut = rounded.shift(-roundedPrecision + 2);
    final ceiled = cut.ceil();
    return ceiled.shift(roundedPrecision - 2);
  }

  /// Returns a rounded-down version of this [BigDecimal].
  /// Useful for calculating a lower bound for display purposes,
  /// such as setting a clean minimum value for a chart axis.
  /// e.g. `1234.56` → `1200`
  BigDecimal get lowerBound {
    final rounded = floor();
    final roundedPrecision = rounded.precision;
    final cut = rounded.shift(-roundedPrecision + 2);
    final floored = cut.floor();
    return floored.shift(roundedPrecision - 2);
  }

  /// Plain string without trailing fractional zeros (for editing / math operands).
  String toOperandString() {
    final plain = toPlainString();
    if (!plain.contains('.')) {
      return plain;
    }
    return plain.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  /// Creates a [BigDecimal] from an [int].
  static BigDecimal fromInt(int value) => BigDecimal.fromBigInt(BigInt.from(value));

  /// Converts a [double] to a [BigDecimal].
  ///
  /// Throws [ArgumentError] for NaN or infinite values.
  static BigDecimal fromDouble(double value) {
    if (value.isNaN || value.isInfinite) {
      throw ArgumentError.value(value, 'value', 'Must be a finite number');
    }
    return BigDecimal.parse(value.toString());
  }

  /// Sums a collection of [BigDecimal] values.
  static BigDecimal sum(Iterable<BigDecimal> decimals) {
    return decimals.fold(BigDecimal.zero, (sum, value) => sum + value);
  }

  /// Returns `0.01` - the smallest unit for most currencies.
  static BigDecimal get cent => BigDecimal.parse('0.01');

  /// Returns the larger of two numbers.
  static BigDecimal max(BigDecimal a, BigDecimal b) {
    return a > b ? a : b;
  }

  /// Returns the lesser of two numbers.
  static BigDecimal min(BigDecimal a, BigDecimal b) {
    return a < b ? a : b;
  }
}
