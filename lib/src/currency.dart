import 'package:equatable/equatable.dart';

import 'currency_code.dart';

part 'utils/currency_map.dart';

/// Represents a currency, including formatting rules and display metadata.
final class Currency extends Equatable {
  /// The ISO 4217 currency code (e.g. "USD", "EUR", "AED").
  final CurrencyCode code;

  /// The number of decimal places used for this currency.
  final int precision;

  /// An optional emoji flag associated with the currency (e.g. 🇺🇸 for USD).
  final String? emojiFlag;

  /// An optional symbol for the currency (e.g. $ for USD).
  final String? symbol;

  /// The full English name of the currency (e.g. "United States Dollar").
  final String englishName;

  /// Creates a [Currency] object.
  const Currency({
    required this.code,
    required this.precision,
    this.emojiFlag,
    this.symbol,
    required this.englishName,
  });

  /// Returns a [Currency] instance based on the provided ISO 4217 currency code.
  /// Returns `null` if the code is `null` or not recognised.
  static Currency? fromCode(CurrencyCode? code) {
    if (code == null) return null;

    return _currencyMap[code.toUpperCase()];
  }

  @override
  List<Object?> get props => [code];
}
