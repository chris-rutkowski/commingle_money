import 'package:decimal/decimal.dart';

import 'utils/decimal_utils.dart';

/// A simple structure that represents a [Decimal] value as integer (`main`)
/// and fractional (`fractional`) components.
final class DecimalComponents {
  /// The whole number part of the decimal.
  final int main;

  /// The fractional part of the decimal.
  final int fractional;

  /// Creates a [DecimalComponents] instance with the given [main] and [fractional] parts.
  const DecimalComponents({
    required this.main,
    required this.fractional,
  });

  /// Creates [DecimalComponents] from a [Decimal] by separating its whole and fractional parts.
  /// [fractional] is always positive, even if the [value] is negative.
  factory DecimalComponents.fromDecimal(Decimal value) {
    final main = value.truncate().toInt();

    final fractionalRaw = value - Decimal.fromInt(main);
    final fractional = fractionalRaw.shift(value.scale).toInt();
    return DecimalComponents(main: main, fractional: fractional);
  }

  @override
  String toString() => 'DecimalComponents: { main: $main, fractional: $fractional }';
}
