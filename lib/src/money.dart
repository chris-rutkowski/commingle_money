import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import 'currency_code.dart';

/// A value object that represents a monetary amount in a specific currency.
final class Money extends Equatable {
  /// The ISO 4217 currency code (e.g. "USD", "EUR", "AED").
  final CurrencyCode currency;

  /// The monetary amount, represented as a [Decimal] for high precision.
  final Decimal amount;

  /// Creates a [Money] instance with the given [currency] and [amount].
  const Money({
    required this.currency,
    required this.amount,
  });

  @override
  List<Object?> get props => [currency, amount];

  @override
  String toString() => '$currency $amount';
}
