// TODO: to drop
// ignore_for_file: public_member_api_docs

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../amount_format_separators.dart';
import '../../currency.dart';
import '../../decimal_components.dart';
import '../../money.dart';
import '../../utils/amount_formatter.dart';
import 'money_label_animation.dart';
import 'money_label_fractional_mode.dart';

final class MoneyLabel extends StatelessWidget {
  final Money money;
  final MoneyLabelFractionalMode fractionalMode;
  // TODO: or listenable<Money> but not both
  final MoneyLabelAnimation? animation;
  final bool displayCurrency;
  final bool displayNegativeSign;
  final AmountFormatSeparators separators;
  final TextStyle? primaryTextStyle;
  final TextStyle? secondaryTextStyle;
  final Color? positiveColor;
  final Color? negativeColor;
  final Color? zeroColor;
  final EdgeInsets? secondaryPadding;

  const MoneyLabel({
    super.key,
    required this.money,
    this.fractionalMode = MoneyLabelFractionalMode.flexible,
    this.animation = const MoneyLabelAnimation(),
    this.displayCurrency = true,
    this.displayNegativeSign = true,
    this.separators = const AmountFormatSeparators(),
    this.primaryTextStyle,
    this.secondaryTextStyle,
    this.positiveColor,
    this.negativeColor,
    this.zeroColor,
    this.secondaryPadding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMoney = resolveEffectiveMoney(money);
    final effectiveColor = resolveEffectiveColor(effectiveMoney);

    final effectivePrimaryStyle = (Theme.of(context).textTheme.headlineMedium ?? DefaultTextStyle.of(context).style)
        .merge(primaryTextStyle)
        .copyWith(color: effectiveColor);
    final effectiveSecondaryStyle = (Theme.of(context).textTheme.bodyMedium ?? DefaultTextStyle.of(context).style)
        .merge(secondaryTextStyle)
        .copyWith(color: effectiveColor);
    final effectiveSecondaryPadding =
        secondaryPadding ?? approximateSecondaryBottomPadding(effectivePrimaryStyle, effectiveSecondaryStyle);

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
            if (animation == null)
              Text(
                AmountFormatter.formattedMain(
                  displayNegativeSign ? components.main.abs() : components.main,
                  separators.grouping,
                ),
                style: effectivePrimaryStyle,
              ),
            if (animation != null)
              AnimatedFlipCounter(
                textStyle: effectivePrimaryStyle,
                curve: animation!.curve,
                duration: animation!.duration,
                negativeSignDuration: animation!.duration,
                value: displayNegativeSign ? components.main.abs() : components.main,
                thousandSeparator: separators.grouping,
              ),
            if (shouldDisplayFractionalPart(components)) ...[
              Padding(
                padding: effectiveSecondaryPadding,
                child: Text(
                  separators.decimal,
                  style: effectiveSecondaryStyle,
                ),
              ),
              Padding(
                padding: effectiveSecondaryPadding,
                child: animation == null
                    ? Text(
                        (components.fractional.toString()).padLeft(resolveFractionalDigits(effectiveMoney), '0'),
                        style: effectiveSecondaryStyle,
                      )
                    : AnimatedFlipCounter(
                        wholeDigits: resolveFractionalDigits(effectiveMoney),
                        textStyle: effectiveSecondaryStyle,
                        curve: animation!.curve,
                        duration: animation!.duration,
                        value: components.fractional,
                      ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // Wish I can find easy way to actually calculate the baseline between two text styles
  EdgeInsets approximateSecondaryBottomPadding(TextStyle primaryTextStyle, TextStyle secondaryTextStyle) {
    final primaryFontSize = primaryTextStyle.fontSize;
    final secondaryFontSize = secondaryTextStyle.fontSize;

    if (primaryFontSize == null || secondaryFontSize == null) {
      return EdgeInsets.zero;
    }

    return EdgeInsets.only(
      top: (primaryFontSize - secondaryFontSize),
    );
  }

  Color? resolveEffectiveColor(Money money) {
    if (money.amount > Decimal.zero) {
      return positiveColor;
    } else if (money.amount < Decimal.zero) {
      return negativeColor;
    } else {
      return zeroColor;
    }
  }

  int resolveFractionalDigits(Money money) {
    return fractionalMode == MoneyLabelFractionalMode.accurate ? 1 : Currency.getPrecision(money.currencyCode);
  }

  Money resolveEffectiveMoney(Money money) {
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

  bool shouldDisplayFractionalPart(DecimalComponents components) {
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
