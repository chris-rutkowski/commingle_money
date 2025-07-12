import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../amount_format_separators.dart';
import '../../currency.dart';
import '../../decimal_components.dart';
import '../../money.dart';
import '../../utils/amount_formatter.dart';
import 'money_label_animation.dart';
import 'money_label_defaults.dart';
import 'money_label_fractional_mode.dart';

/// A customisable and optionally animated widget for displaying monetary values.
final class MoneyLabel extends StatelessWidget {
  /// [Money] value to display.
  final Money money;

  /// Controls how fractional digits are rendered.
  /// See [MoneyLabelFractionalMode] for details. Defaults to [MoneyLabelFractionalMode.flexible].
  final MoneyLabelFractionalMode fractionalMode;

  /// Controls the animation of the [money] updates, by default animation is disabled.
  final MoneyLabelAnimation animation;

  /// Whether to show the currency symbol or code, defaults to `true`.
  final bool displayCurrency;

  /// Whether to display a negative sign for negative amounts, defaults to `true`.
  final bool displayNegativeSign;

  /// Controls the grouping (thousands) and decimal separators used for formatting the amount.
  /// If not provided, the widget will attempt to read values from the [AmountFormatSeparators]
  /// inherited widget in the widget tree. If no inherited value is found, it defaults to
  /// `,` as the grouping separator and `.` as the decimal separator.
  final AmountFormatSeparatorsData? separators;

  /// Text style used for the main amount text.
  /// Can be provided here or via [MoneyLabelDefaults].
  /// Alternatively will use the theme's `bodyLarge`.
  final TextStyle? primaryTextStyle;

  /// Text style used for secondary elements such as currency or decimals.
  /// Can be provided here or via [MoneyLabelDefaults].
  /// Alternatively will use the theme's `bodyMedium`.
  final TextStyle? secondaryTextStyle;

  /// Colour to use when the amount is positive.
  /// Can be provided here or via [MoneyLabelDefaults].
  /// Alternatively will use [Colors.green].
  final Color? positiveColor;

  /// Colour to use when the amount is positive.
  /// Can be provided here or via [MoneyLabelDefaults].
  /// Alternatively will use [Colors.red].
  final Color? negativeColor;

  /// Colour to use when the amount is zero.
  /// Can be provided here or via [MoneyLabelDefaults].
  /// Alternatively will use [Colors.grey].
  final Color? zeroColor;

  /// Check README.
  final EdgeInsets? secondaryPadding;

  /// Creates a [MoneyLabel] widget.
  const MoneyLabel({
    super.key,
    required this.money,
    this.fractionalMode = MoneyLabelFractionalMode.flexible,
    this.animation = MoneyLabelAnimation.none,
    this.displayCurrency = true,
    this.displayNegativeSign = true,
    this.separators,
    this.primaryTextStyle,
    this.secondaryTextStyle,
    this.positiveColor,
    this.negativeColor,
    this.zeroColor,
    this.secondaryPadding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSeparators = _resolveEffectiveSeparators(context);
    final effectiveMoney = _resolveEffectiveMoney(money);
    final effectiveColor = _resolveEffectiveColor(context, effectiveMoney);

    final effectivePrimaryStyle = _resolveEffectivePrimaryStyle(context, effectiveColor);
    final effectiveSecondaryStyle = _resolveEffectiveSecondaryStyle(context, effectiveColor);
    final effectiveSecondaryPadding = _resolveEffectiveSecondaryPadding(
      context,
      effectivePrimaryStyle,
      effectiveSecondaryStyle,
    );

    final currency = Currency.fromCode(effectiveMoney.currencyCode);
    final components = fractionalMode == MoneyLabelFractionalMode.accurate
        ? DecimalComponents.fromDecimal(effectiveMoney.amount)
        : effectiveMoney.components;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (displayCurrency)
              Padding(
                padding: effectiveSecondaryPadding,
                child: Text(
                  '${currency?.symbol ?? effectiveMoney.currencyCode} ',
                  style: effectiveSecondaryStyle,
                ),
              ),
            if (animation == MoneyLabelAnimation.none)
              Text(
                AmountFormatter.formattedMain(
                  displayNegativeSign ? components.main : components.main.abs(),
                  effectiveSeparators.grouping,
                ),
                style: effectivePrimaryStyle,
              ),
            if (animation != MoneyLabelAnimation.none)
              AnimatedFlipCounter(
                textStyle: effectivePrimaryStyle,
                curve: animation.curve,
                duration: animation.duration,
                negativeSignDuration: animation.duration,
                value: displayNegativeSign ? components.main : components.main.abs(),
                thousandSeparator: effectiveSeparators.grouping,
              ),
            if (_shouldDisplayFractionalPart(components)) ...[
              Padding(
                padding: effectiveSecondaryPadding,
                child: Text(
                  effectiveSeparators.decimal,
                  style: effectiveSecondaryStyle,
                ),
              ),
              Padding(
                padding: effectiveSecondaryPadding,
                child: animation == MoneyLabelAnimation.none
                    ? Text(
                        (components.fractional.toString()).padLeft(_resolveFractionalDigits(effectiveMoney), '0'),
                        style: effectiveSecondaryStyle,
                      )
                    : AnimatedFlipCounter(
                        wholeDigits: _resolveFractionalDigits(effectiveMoney),
                        textStyle: effectiveSecondaryStyle,
                        curve: animation.curve,
                        duration: animation.duration,
                        value: components.fractional,
                      ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  TextStyle _resolveEffectivePrimaryStyle(BuildContext context, Color color) {
    final base =
        MoneyLabelDefaults.maybeOf(context)?.primaryTextStyle ??
        Theme.of(context).textTheme.bodyLarge ??
        DefaultTextStyle.of(context).style;

    return base.merge(primaryTextStyle).copyWith(color: color);
  }

  TextStyle _resolveEffectiveSecondaryStyle(BuildContext context, Color color) {
    final base =
        MoneyLabelDefaults.maybeOf(context)?.secondaryTextStyle ??
        Theme.of(context).textTheme.bodyMedium ??
        DefaultTextStyle.of(context).style;

    return base.merge(secondaryTextStyle).copyWith(color: color);
  }

  Color _resolveEffectiveColor(BuildContext context, Money money) {
    final defaults = MoneyLabelDefaults.maybeOf(context);

    if (money.amount > Decimal.zero) {
      return positiveColor ?? defaults?.positiveColor ?? Colors.green;
    } else if (money.amount < Decimal.zero) {
      return negativeColor ?? defaults?.negativeColor ?? Colors.red;
    } else {
      return zeroColor ?? defaults?.zeroColor ?? Colors.grey;
    }
  }

  int _resolveFractionalDigits(Money money) {
    return fractionalMode == MoneyLabelFractionalMode.accurate ? 1 : Currency.getPrecision(money.currencyCode);
  }

  AmountFormatSeparatorsData _resolveEffectiveSeparators(BuildContext context) {
    return separators ?? AmountFormatSeparators.maybeOf(context) ?? const AmountFormatSeparatorsData();
  }

  Money _resolveEffectiveMoney(Money money) {
    switch (fractionalMode) {
      case MoneyLabelFractionalMode.flexible:
        return money.roundedToCurrencyPrecision();
      case MoneyLabelFractionalMode.always:
        return money.roundedToCurrencyPrecision();
      case MoneyLabelFractionalMode.round:
        return money.rounded();
      case MoneyLabelFractionalMode.accurate:
        return money;
    }
  }

  EdgeInsets _resolveEffectiveSecondaryPadding(
    BuildContext context,
    TextStyle primaryTextStyle,
    TextStyle secondaryTextStyle,
  ) {
    final defaultValue = secondaryPadding ?? MoneyLabelDefaults.maybeOf(context)?.secondaryPadding;

    if (defaultValue != null) {
      return defaultValue;
    }

    // Wish I could find an easy way to automatically calculate the baseline between two text styles.
    // I tried using alphabetic baselines as well as TextPainter.
    // There were always edge cases especially when MoneyLabel changes are animated.
    final primaryFontSize = primaryTextStyle.fontSize;
    final secondaryFontSize = secondaryTextStyle.fontSize;

    if (primaryFontSize == null || secondaryFontSize == null) {
      return EdgeInsets.zero;
    }

    return EdgeInsets.only(
      top: (primaryFontSize - secondaryFontSize),
    );
  }

  bool _shouldDisplayFractionalPart(DecimalComponents components) {
    switch (fractionalMode) {
      case MoneyLabelFractionalMode.flexible:
        return components.fractional != 0;
      case MoneyLabelFractionalMode.always:
        return true;
      case MoneyLabelFractionalMode.round:
        return false;
      case MoneyLabelFractionalMode.accurate:
        return components.fractional != 0;
    }
  }
}
