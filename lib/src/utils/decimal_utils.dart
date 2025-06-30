import 'package:decimal/decimal.dart';

/// Various Decimal utilities
extension DecimalUtils on Decimal {
  /// Converts a double to a Decimal.
  static Decimal fromDouble(double value) => Decimal.parse(value.toString());

  /// Returns `0.01` - the smallest unit for most currencies.
  static Decimal get cent => Decimal.parse('0.01');
}
