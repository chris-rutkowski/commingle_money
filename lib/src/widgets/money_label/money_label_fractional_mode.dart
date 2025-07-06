import 'money_label.dart';

/// Defines how the fractional part (decimals) value should be displayed within [MoneyLabel]
/// in a UI label or text widget.
enum MoneyLabelFractionalMode {
  /// Displays the fractional part only if it's non-zero.
  ///
  /// For example:
  /// - `12.00` → `12`
  /// - `12.50` → `12.50`
  flexible,

  /// Always displays the fractional part up to the currency's precision,
  /// even if it's zero.
  ///
  /// For example:
  /// - `12.00` → `12.00`
  /// - `12.50` → `12.50`
  always,

  /// Rounds the amount to the nearest whole number and displays it without decimals.
  ///
  /// For example:
  /// - `12.99` → `13`
  /// - `12.01` → `12`
  round,

  /// Displays the full precision regardless of the currency's typical precision.
  ///
  /// For example:
  /// - `12.3456` → `12.3456`
  /// - `12.0` → `12`
  accurate,
}
