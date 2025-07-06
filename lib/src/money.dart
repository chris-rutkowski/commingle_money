import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import 'currency.dart';
import 'currency_code.dart';
import 'decimal_components.dart';
import 'utils/decimal_utils.dart';

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
    amount: Decimal.zero,
    currencyCode: currencyCode,
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

  /// Returns the [DecimalComponents] of this [Money] instance.
  DecimalComponents get components {
    final main = amount.truncate();

    final precision = Currency.getPrecision(currencyCode);

    return DecimalComponents(
      main: main.toInt(),
      fractional: (amount - main).shift(precision).abs().toInt(),
    );
  }

  /// Returns a new [Money] instance with the amount rounded to the nearest whole number.
  Money rounded() {
    return Money(
      currencyCode: currencyCode,
      amount: amount.round(),
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
}
