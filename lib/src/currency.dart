import 'package:equatable/equatable.dart';

import 'currency_code.dart';

part 'utils/currency_map.dart';

/// Represents a currency, including formatting rules and display metadata.
final class Currency extends Equatable {
  /// The ISO 4217 currency code (e.g. "USD", "EUR", "AED").
  final CurrencyCode code;

  /// The number of decimal places used for this currency.
  final int precision;

  /// An optional emoji associated with the currency (e.g. 🇺🇸 for USD).
  final String? emoji;

  /// An optional symbol for the currency (e.g. $ for USD).
  final String? symbol;

  /// The full English name of the currency (e.g. "United States Dollar").
  final String englishName;

  /// Creates a [Currency] object.
  const Currency({
    required this.code,
    required this.precision,
    this.emoji,
    this.symbol,
    required this.englishName,
  });

  /// Returns a [Currency] instance based on the provided ISO 4217 currency code.
  static Currency? fromCode(CurrencyCode code) => _currencyMap[code];

  @override
  List<Object?> get props => [code];
}
