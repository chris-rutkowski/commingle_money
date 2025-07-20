import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'amount_format_separators.dart';
import 'currency.dart';
import 'fractional_mode.dart';
import 'money.dart';
import 'money_presentation_defaults.dart';
import 'private/amount_formatter.dart';
import 'private/decimal_components.dart';
import 'widgets/money_label/money_label.dart';

/// Formatter to convert [Money] objects into formatted strings, with output similar to [MoneyLabel].
final class MoneyFormatter {
  /// Controls how fractional digits are rendered.
  /// See [FractionalMode] for details. Defaults to [FractionalMode.flexible].
  final FractionalMode fractionalMode;

  /// Whether to show the currency symbol or code, defaults to `true`.
  final bool displayCurrency;

  /// Whether to display a negative sign for negative amounts, defaults to `true`.
  final bool displayNegativeSign;

  /// Controls the grouping (thousands) and decimal separators used for formatting the amount.
  final AmountFormatSeparatorsData separators;

  /// Text to display next to currency when the amount is zero.
  /// e.g. Ø will be displayed as USD Ø
  final String? zeroText;

  /// Creates a [MoneyFormatter] instance.
  const MoneyFormatter({
    this.fractionalMode = FractionalMode.flexible,
    this.displayCurrency = true,
    this.displayNegativeSign = true,
    this.separators = const AmountFormatSeparatorsData(),
    this.zeroText,
  });

  /// Creates a [MoneyFormatter] instance with default values coming from [AmountFormatSeparators]
  /// and [MoneyPresentationDefaults] inherited widgets in the widget tree.
  factory MoneyFormatter.fromContext(
    BuildContext context, {
    FractionalMode fractionalMode = FractionalMode.flexible,
    bool displayCurrency = true,
    bool? displayNegativeSign,
    AmountFormatSeparatorsData? separators,
    String? zeroText,
  }) {
    final separators = AmountFormatSeparators.of(context);
    final defaults = MoneyPresentationDefaults.maybeOf(context);

    return MoneyFormatter(
      fractionalMode: fractionalMode,
      displayCurrency: displayCurrency,
      displayNegativeSign: displayNegativeSign ?? defaults?.displayNegativeSign ?? true,
      separators: separators,
      zeroText: zeroText ?? defaults?.zeroText,
    );
  }

  /// Formats the given [money] into a string.
  String format(Money money) {
    final effectiveMoney = _resolveEffectiveMoney(money);

    final currency = Currency.fromCode(effectiveMoney.currencyCode);
    final components = fractionalMode == FractionalMode.accurate
        ? DecimalComponents.fromDecimal(effectiveMoney.amount)
        : DecimalComponents.fromMoney(effectiveMoney);

    final buffer = StringBuffer();
    if (displayCurrency) {
      buffer.write(currency?.symbol ?? effectiveMoney.currencyCode);
      buffer.write(' ');
    }

    if (components.sign == NumberSign.negative && displayNegativeSign) {
      buffer.write('-');
    }

    if (effectiveMoney.amount == Decimal.zero && zeroText != null) {
      buffer.write(zeroText);
    } else {
      buffer.write(
        AmountFormatter.formattedMain(
          components.main,
          separators.grouping,
        ),
      );
    }

    if (_shouldDisplayFractionalPart(components)) {
      buffer.write(separators.decimal);
      buffer.write((components.fractional.toString()).padLeft(_resolveFractionalDigits(effectiveMoney), '0'));
    }

    return buffer.toString();
  }

  Money _resolveEffectiveMoney(Money money) {
    switch (fractionalMode) {
      case FractionalMode.flexible:
        return money.roundedToCurrencyPrecision();
      case FractionalMode.always:
        return money.roundedToCurrencyPrecision();
      case FractionalMode.compact:
        return money.amount.abs() < Decimal.fromInt(100) ? money.roundedToCurrencyPrecision() : money.rounded();
      case FractionalMode.round:
        return money.rounded();
      case FractionalMode.accurate:
        return money;
    }
  }

  bool _shouldDisplayFractionalPart(DecimalComponents components) {
    switch (fractionalMode) {
      case FractionalMode.flexible:
      case FractionalMode.accurate:
      case FractionalMode.compact:
        return components.fractional != 0;
      case FractionalMode.always:
        return true;
      case FractionalMode.round:
        return false;
    }
  }

  int _resolveFractionalDigits(Money money) {
    return fractionalMode == FractionalMode.accurate ? money.amount.scale : Currency.getPrecision(money.currencyCode);
  }
}
