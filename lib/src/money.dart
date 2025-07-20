import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import 'currency.dart';
import 'currency_code.dart';
import 'decimal_utils.dart';

/// A value object that represents a monetary amount in a specific currency.
final class Money extends Equatable {
  /// The ISO 4217 currency code (e.g. "USD", "EUR", "AED").
  final CurrencyCode currencyCode;

  /// The monetary amount, represented as a [Decimal] for high precision.
  final Decimal amount;

  /// Creates a [Money] instance with the given [currencyCode] and [amount].
  const Money({
    required this.currencyCode,
    required this.amount,
  });

  /// Creates a [Money] instance with the given [currencyCode] and `0` [amount].
  static Money zero(CurrencyCode currencyCode) => Money(
    currencyCode: currencyCode,
    amount: Decimal.zero,
  );

  /// Creates a [Money] instance with the given [amount] in USD.
  static Money usd(Decimal amount) => Money(
    currencyCode: CurrencyCodes.usd,
    amount: amount,
  );

  /// Creates a [Money] instance with the given [amount] in EUR.
  static Money eur(Decimal amount) => Money(
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
    Decimal? amount,
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
  /// [other] can be either a [Money] with the same [currencyCode], or a numeric type ([int], [double], [Decimal]).
  Money operator +(dynamic other) {
    return Money(
      currencyCode: currencyCode,
      amount: amount + _getDecimal(other, currencyCode),
    ).roundedToCurrencyPrecision();
  }

  /// Returns difference of this [Money] and [other].
  /// [other] can be either a [Money] with the same [currencyCode], or a numeric type ([int], [double], [Decimal]).
  Money operator -(dynamic other) {
    return Money(
      currencyCode: currencyCode,
      amount: amount - _getDecimal(other, currencyCode),
    ).roundedToCurrencyPrecision();
  }

  /// Returns product of this [Money] and [other].
  /// [other] can be either a [Money] with the same [currencyCode], or a numeric type ([int], [double], [Decimal]).
  Money operator *(dynamic other) {
    return Money(
      currencyCode: currencyCode,
      amount: amount * _getDecimal(other, currencyCode),
    ).roundedToCurrencyPrecision();
  }

  /// Returns quotient of this [Money] and [other].
  /// [other] can be either a [Money] with the same [currencyCode], or a numeric type ([int], [double], [Decimal]).
  Money operator /(dynamic other) {
    final decimalDivisor = _getDecimal(other, currencyCode);

    if (decimalDivisor == Decimal.zero) {
      throw ArgumentError('Division by zero is not allowed');
    }

    final precision = Currency.getPrecision(currencyCode);

    return Money(
      currencyCode: currencyCode,
      amount: (amount / decimalDivisor).toDecimal(scaleOnInfinitePrecision: precision),
    ).roundedToCurrencyPrecision();
  }
}

Decimal _getDecimal(dynamic value, CurrencyCode currencyCode) {
  if (value is Decimal) {
    return value;
  } else if (value is int) {
    return Decimal.fromInt(value);
  } else if (value is double) {
    return DecimalUtils.fromDouble(value);
  } else if (value is Money) {
    if (value.currencyCode != currencyCode) {
      throw ArgumentError('Currency mismatch: expected $currencyCode, got ${value.currencyCode}');
    }
    return value.amount;
  } else {
    throw ArgumentError('Invalid type for conversion to Decimal: `$value` of type ${value.runtimeType}');
  }
}
