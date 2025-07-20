import 'package:decimal/decimal.dart';

import '../currency.dart';
import '../decimal_utils.dart';
import '../money.dart';


/// Represents the sign of a number.
enum NumberSign {
  /// For value greater than or equal to zero
  positive,

  /// For value less than zero
  negative,
}

/// A simple structure that represents a [Decimal] value as integer (`main`)
/// and fractional (`fractional`) components.
final class DecimalComponents {
  /// Whether the value is negative.
  final NumberSign sign;

  /// The whole number part of the decimal.
  final int main;

  /// The fractional part of the decimal.
  final int fractional;

  /// Creates a [DecimalComponents] instance with the given [main] and [fractional] parts.
  const DecimalComponents({
    required this.sign,
    required this.main,
    required this.fractional,
  });

  /// Creates [DecimalComponents] from [Decimal].
  factory DecimalComponents.fromDecimal(Decimal value) {
    final abs = value.abs();
    final main = abs.truncate().toInt();

    final fractionalRaw = abs - Decimal.fromInt(main);
    final fractional = fractionalRaw.shift(value.scale).toInt();
    return DecimalComponents(
      sign: value < Decimal.zero ? NumberSign.negative : NumberSign.positive,
      main: main,
      fractional: fractional,
    );
  }

  /// Creates [DecimalComponents] from [Money].
  factory DecimalComponents.fromMoney(Money money) {
    final abs = money.amount.abs();
    final main = abs.truncate();

    final precision = Currency.getPrecision(money.currencyCode);

    return DecimalComponents(
      sign: money.amount < Decimal.zero ? NumberSign.negative : NumberSign.positive,
      main: main.toInt(),
      fractional: (abs - main).shift(precision).toInt(),
    );
  }

  @override
  String toString() => 'DecimalComponents: { sign: ${sign.name}, main: $main, fractional: $fractional }';
}
