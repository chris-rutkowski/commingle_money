import 'package:big_decimal/big_decimal.dart';
import 'package:equatable/equatable.dart';

import 'big_decimal_utils.dart';
import 'currency.dart';
import 'currency_code.dart';

/// A value object that represents a monetary amount in a specific currency.
final class Money extends Equatable {
  /// The ISO 4217 currency code (e.g. "USD", "EUR", "AED").
  final CurrencyCode currencyCode;

  /// The monetary amount, represented as a [BigDecimal] for high precision.
  final BigDecimal amount;

  /// Creates a [Money] instance with the given [currencyCode] and [amount].
  const Money({
    required this.currencyCode,
    required this.amount,
  });

  /// Creates a [Money] instance with the given [currencyCode] and `0` [amount].
  static Money zero(CurrencyCode currencyCode) => Money(
    currencyCode: currencyCode,
    amount: BigDecimal.zero,
  );

  /// Creates a [Money] instance with the given [amount] in USD.
  static Money usd(BigDecimal amount) => Money(
    currencyCode: CurrencyCodes.usd,
    amount: amount,
  );

  /// Creates a [Money] instance with the given [amount] in EUR.
  static Money eur(BigDecimal amount) => Money(
    currencyCode: CurrencyCodes.eur,
    amount: amount,
  );

  @override
  List<Object?> get props => [currencyCode, amount];

  @override
  String toString() => '$currencyCode $amount';

  /// Creates a copy of this [Money] instance with the given fields replaced.
  ///
  /// If a parameter is not provided, the existing value from this instance is used
  Money copyWith({
    CurrencyCode? currencyCode,
    BigDecimal? amount,
  }) {
    return Money(
      currencyCode: currencyCode ?? this.currencyCode,
      amount: amount ?? this.amount,
    );
  }

  /// Returns a new [Money] instance with the amount rounded to the nearest whole number.
  Money rounded() {
    return Money(
      currencyCode: currencyCode,
      amount: amount.round(),
    );
  }

  /// Returns a new [Money] instance with the absolute value of the amount.
  Money abs() {
    return Money(
      currencyCode: currencyCode,
      amount: amount.abs(),
    );
  }

  /// Returns a new [Money] instance with the amount rounded to the currency's precision.
  /// e.g. `USD 1.249` becomes `USD 1.25`.
  Money roundedToCurrencyPrecision() {
    final precision = Currency.getPrecision(currencyCode);
    return Money(
      currencyCode: currencyCode,
      amount: amount.round(scale: precision),
    );
  }

  /// Returns sum of this [Money] and [other].
  /// [other] can be either a [Money] with the same [currencyCode], or a numeric type ([int], [double], [BigDecimal]).
  Money operator +(dynamic other) {
    return Money(
      currencyCode: currencyCode,
      amount: amount + _getBigDecimal(other, currencyCode),
    ).roundedToCurrencyPrecision();
  }

  /// Returns difference of this [Money] and [other].
  /// [other] can be either a [Money] with the same [currencyCode], or a numeric type ([int], [double], [BigDecimal]).
  Money operator -(dynamic other) {
    return Money(
      currencyCode: currencyCode,
      amount: amount - _getBigDecimal(other, currencyCode),
    ).roundedToCurrencyPrecision();
  }

  /// Returns product of this [Money] and [other].
  /// [other] can be either a [Money] with the same [currencyCode], or a numeric type ([int], [double], [BigDecimal]).
  Money operator *(dynamic other) {
    return Money(
      currencyCode: currencyCode,
      amount: amount * _getBigDecimal(other, currencyCode),
    ).roundedToCurrencyPrecision();
  }

  /// Returns quotient of this [Money] and [other].
  /// [other] can be either a [Money] with the same [currencyCode], or a numeric type ([int], [double], [BigDecimal]).
  Money operator /(dynamic other) {
    final divisor = _getBigDecimal(other, currencyCode);

    if (divisor == BigDecimal.zero) {
      throw ArgumentError('Division by zero is not allowed');
    }

    final precision = Currency.getPrecision(currencyCode);

    return Money(
      currencyCode: currencyCode,
      amount: amount.divide(
        divisor,
        scale: precision,
        roundingMode: RoundingMode.HALF_UP,
      ),
    ).roundedToCurrencyPrecision();
  }

  /// Returns truncated quotient of this [Money] and [other].
  /// [other] can be either a [Money] with the same [currencyCode], or a numeric type ([int], [double], [BigDecimal]).
  Money operator ~/(dynamic other) {
    final divisor = _getBigDecimal(other, currencyCode);

    if (divisor == BigDecimal.zero) {
      throw ArgumentError('Division by zero is not allowed');
    }

    final quotient = amount.divide(
      divisor,
      scale: 0,
      roundingMode: RoundingMode.DOWN,
    );

    return Money(
      currencyCode: currencyCode,
      amount: quotient,
    );
  }
}

BigDecimal _getBigDecimal(dynamic value, CurrencyCode currencyCode) {
  if (value is BigDecimal) {
    return value;
  } else if (value is int) {
    return BigDecimalUtils.fromInt(value);
  } else if (value is double) {
    return BigDecimalUtils.fromDouble(value);
  } else if (value is Money) {
    if (value.currencyCode != currencyCode) {
      throw ArgumentError('Currency mismatch: expected $currencyCode, got ${value.currencyCode}');
    }
    return value.amount;
  } else {
    throw ArgumentError('Invalid type for conversion to BigDecimal: `$value` of type ${value.runtimeType}');
  }
}
