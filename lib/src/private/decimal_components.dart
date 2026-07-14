import 'package:big_decimal/big_decimal.dart';

import '../big_decimal_utils.dart';
import '../currency.dart';
import '../money.dart';

/// Represents the sign of a number.
enum NumberSign {
  /// For value greater than or equal to zero
  positive,

  /// For value less than zero
  negative,
}

/// A simple structure that represents a [BigDecimal] value as integer (`main`)
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

  /// Creates [DecimalComponents] from [BigDecimal].
  factory DecimalComponents.fromDecimal(BigDecimal value) {
    final abs = value.abs();
    final main = abs.truncate().truncateToInt();

    final fractionalRaw = abs - BigDecimalUtils.fromInt(main);
    final fractional = fractionalRaw.shift(value.scale).truncateToInt();
    return DecimalComponents(
      sign: value < BigDecimal.zero ? NumberSign.negative : NumberSign.positive,
      main: main,
      fractional: fractional,
    );
  }

  /// Creates [DecimalComponents] from whole-number [digits].
  factory DecimalComponents.fromDigits(List<int> digits, {NumberSign sign = .positive}) {
    var main = BigDecimal.zero;

    for (final digit in digits) {
      if (digit < 0 || digit > 9) {
        throw ArgumentError.value(digit, 'digits', 'Each digit must be between 0 and 9');
      }

      main = main.shift(1) + BigDecimalUtils.fromInt(digit);
    }

    return DecimalComponents(
      sign: sign,
      main: main.truncateToInt(),
      fractional: 0,
    );
  }

  /// Creates [DecimalComponents] from [Money].
  factory DecimalComponents.fromMoney(Money money) {
    final abs = money.amount.abs();
    final main = abs.truncate();

    final precision = Currency.getPrecision(money.currencyCode);

    return DecimalComponents(
      sign: money.amount < BigDecimal.zero ? NumberSign.negative : NumberSign.positive,
      main: main.truncateToInt(),
      fractional: (abs - main).shift(precision).truncateToInt(),
    );
  }

  /// Creates a copy of this [DecimalComponents] with the given fields replaced.
  DecimalComponents copyWith({
    NumberSign? sign,
    int? main,
    int? fractional,
  }) {
    return DecimalComponents(
      sign: sign ?? this.sign,
      main: main ?? this.main,
      fractional: fractional ?? this.fractional,
    );
  }

  /// Converts this [DecimalComponents] back to a [BigDecimal] value.
  BigDecimal toBigDecimal() {
    final fractionalDigits = fractional == 0 ? 1 : fractional.toString().length;
    final value = BigDecimalUtils.fromInt(main) + BigDecimalUtils.fromInt(fractional).shift(-fractionalDigits);
    return sign == NumberSign.negative ? -value : value;
  }

  @override
  String toString() => 'DecimalComponents: { sign: ${sign.name}, main: $main, fractional: $fractional }';
}
