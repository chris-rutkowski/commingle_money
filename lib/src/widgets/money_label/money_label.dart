import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../amount_format_separators.dart';
import '../../currency.dart';
import '../../fractional_mode.dart';
import '../../money.dart';
import '../../money_presentation_defaults.dart';
import '../../private/amount_formatter.dart';
import '../../private/decimal_components.dart';
import 'money_label_animation.dart';

/// A customisable and optionally animated widget for displaying monetary values.
final class MoneyLabel extends StatelessWidget {
  /// [Money] value to display.
  final Money money;

  /// Controls how fractional digits are rendered.
  /// See [FractionalMode] for details. Defaults to [FractionalMode.flexible].
  final FractionalMode fractionalMode;

  /// Controls the animation of the [money] updates, by default animation is disabled.
  final MoneyLabelAnimation animation;

  /// Whether to show the currency symbol or code, defaults to `true`.
  final bool displayCurrency;

  /// Whether to display a negative sign for negative amounts, defaults to `true`.
  final bool? displayNegativeSign;

  /// Controls the grouping (thousands) and decimal separators used for formatting the amount.
  /// If not provided, the widget will attempt to read values from the [AmountFormatSeparators]
  /// inherited widget in the widget tree. If no inherited value is found, it defaults to
  /// `,` as the grouping separator and `.` as the decimal separator.
  final AmountFormatSeparatorsData? separators;

  /// Text style used for the main amount text.
  /// Can be provided here or via [MoneyPresentationDefaults].
  /// Alternatively will use the theme's `bodyLarge`.
  final TextStyle? primaryTextStyle;

  /// Text style used for secondary elements such as currency or decimals.
  /// Can be provided here or via [MoneyPresentationDefaults].
  /// Alternatively will use the theme's `bodyMedium`.
  final TextStyle? secondaryTextStyle;

  /// Colour to use when the amount is positive.
  /// Can be provided here or via [MoneyPresentationDefaults].
  /// Alternatively will use [Colors.green].
  final Color? positiveColor;

  /// Colour to use when the amount is positive.
  /// Can be provided here or via [MoneyPresentationDefaults].
  /// Alternatively will use [Colors.red].
  final Color? negativeColor;

  /// Colour to use when the amount is zero.
  /// Can be provided here or via [MoneyPresentationDefaults].
  /// Alternatively will use [Colors.grey].
  final Color? zeroColor;

  /// Text to display next to currency when the amount is zero.
  /// e.g. Ø will be displayed as USD Ø
  final String? zeroText;

  /// Creates a [MoneyLabel] widget.
  const MoneyLabel({
    super.key,
    required this.money,
    this.fractionalMode = FractionalMode.flexible,
    this.animation = MoneyLabelAnimation.none,
    this.displayCurrency = true,
    this.displayNegativeSign,
    this.separators,
    this.primaryTextStyle,
    this.secondaryTextStyle,
    this.positiveColor,
    this.negativeColor,
    this.zeroColor,
    this.zeroText,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDisplayNegativeSign = _resolveEffectiveDisplayNegativeSign(context);
    final effectiveSeparators = _resolveEffectiveSeparators(context);
    final effectiveMoney = _resolveEffectiveMoney(money);
    final effectiveColor = _resolveEffectiveColor(context, effectiveMoney);
    final effectiveZeroText = _resolveEffectiveZeroText(context);

    final effectivePrimaryStyle = _resolveEffectivePrimaryStyle(context, effectiveColor);
    final effectiveSecondaryStyle = _resolveEffectiveSecondaryStyle(context, effectiveColor);

    final currency = Currency.fromCode(effectiveMoney.currencyCode);
    final components = fractionalMode == FractionalMode.accurate
        ? DecimalComponents.fromDecimal(effectiveMoney.amount)
        : DecimalComponents.fromMoney(effectiveMoney);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (displayCurrency)
          Text(
            '${currency?.symbol ?? effectiveMoney.currencyCode} ',
            style: effectiveSecondaryStyle,
          ),

        if (components.sign == NumberSign.negative && effectiveDisplayNegativeSign)
          Text(
            '-',
            style: effectivePrimaryStyle,
          ),

        _buildPrimaryWidget(
          context,
          effectiveMoney,
          components,
          effectivePrimaryStyle,
          effectiveSeparators,
          effectiveZeroText,
        ),

        if (_shouldDisplayFractionalPart(components)) ...[
          Text(
            effectiveSeparators.decimal,
            style: effectiveSecondaryStyle,
          ),
          animation == MoneyLabelAnimation.none
              ? Text(
                  (components.fractional.toString()).padLeft(_resolveFractionalDigits(effectiveMoney), '0'),
                  style: effectiveSecondaryStyle,
                )
              : Stack(
                  children: [
                    Visibility(
                      visible: false,
                      maintainState: true,
                      maintainSize: true,
                      maintainAnimation: true,
                      child: Text(
                        (components.fractional.toString()).padLeft(_resolveFractionalDigits(effectiveMoney), '0'),
                        style: effectiveSecondaryStyle,
                      ),
                    ),
                    IgnoreBaseline(
                      child: AnimatedFlipCounter(
                        wholeDigits: _resolveFractionalDigits(effectiveMoney),
                        textStyle: effectiveSecondaryStyle,
                        curve: animation.curve,
                        duration: animation.duration,
                        value: components.fractional,
                      ),
                    ),
                  ],
                ),
        ],
      ],
    );
  }

  Widget _buildPrimaryWidget(
    BuildContext context,
    Money money,
    DecimalComponents components,
    TextStyle style,
    AmountFormatSeparatorsData separators,
    String? zeroText,
  ) {
    if (money.amount == Decimal.zero && zeroText != null) {
      return Text(
        zeroText,
        style: style,
      );
    }

    if (animation == MoneyLabelAnimation.none) {
      return Text(
        AmountFormatter.formattedMain(
          components.main,
          separators.grouping,
        ),
        style: style,
      );
    }

    return Stack(
      children: [
        // For baseline
        Visibility(
          visible: false,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,
          child: Text(
            AmountFormatter.formattedMain(
              components.main,
              separators.grouping,
            ),
            style: style,
          ),
        ),
        IgnoreBaseline(
          child: AnimatedFlipCounter(
            textStyle: style,
            curve: animation.curve,
            duration: animation.duration,
            negativeSignDuration: animation.duration,
            value: components.main,
            thousandSeparator: separators.grouping,
          ),
        ),
      ],
    );
  }

  TextStyle _resolveEffectivePrimaryStyle(BuildContext context, Color color) {
    final base =
        MoneyPresentationDefaults.maybeOf(context)?.primaryTextStyle ??
        Theme.of(context).textTheme.bodyLarge ??
        DefaultTextStyle.of(context).style;

    return base.merge(primaryTextStyle).copyWith(color: color);
  }

  TextStyle _resolveEffectiveSecondaryStyle(BuildContext context, Color color) {
    final base =
        MoneyPresentationDefaults.maybeOf(context)?.secondaryTextStyle ??
        Theme.of(context).textTheme.bodyMedium ??
        DefaultTextStyle.of(context).style;

    return base.merge(secondaryTextStyle).copyWith(color: color);
  }

  Color _resolveEffectiveColor(BuildContext context, Money money) {
    final defaults = MoneyPresentationDefaults.maybeOf(context);

    if (money.amount > Decimal.zero) {
      return positiveColor ?? defaults?.positiveColor ?? Colors.green;
    } else if (money.amount < Decimal.zero) {
      return negativeColor ?? defaults?.negativeColor ?? Colors.red;
    } else {
      return zeroColor ?? defaults?.zeroColor ?? Colors.grey;
    }
  }

  int _resolveFractionalDigits(Money money) {
    return fractionalMode == FractionalMode.accurate ? money.amount.scale : Currency.getPrecision(money.currencyCode);
  }

  AmountFormatSeparatorsData _resolveEffectiveSeparators(BuildContext context) {
    return separators ?? AmountFormatSeparators.of(context);
  }

  bool _resolveEffectiveDisplayNegativeSign(BuildContext context) {
    return displayNegativeSign ?? MoneyPresentationDefaults.maybeOf(context)?.displayNegativeSign ?? true;
  }

  String? _resolveEffectiveZeroText(BuildContext context) {
    return zeroText ?? MoneyPresentationDefaults.maybeOf(context)?.zeroText;
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
}
