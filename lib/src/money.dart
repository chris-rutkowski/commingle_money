import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import 'currency_code.dart';

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
  static Money zero(CurrencyCode currencyCode) => Money(amount: Decimal.zero, currencyCode: currencyCode);

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
}
