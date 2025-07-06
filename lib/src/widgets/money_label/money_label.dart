// TODO: to drop
// ignore_for_file: public_member_api_docs

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../commingle_money.dart';
import '../../utils/amount_formatter.dart';
import 'money_label_animation.dart';

// TODO: convert to stateless widget after tests

final class MoneyLabel extends StatefulWidget {
  final Money money;
  final MoneyLabelFractionalMode fractionalMode;
  // TODO: or listenable<Money> but not both
  final MoneyLabelAnimation? animation;
  final bool displayCurrency;
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
    this.separators = const AmountFormatSeparators(),
    this.primaryTextStyle,
    this.secondaryTextStyle,
    this.positiveColor,
    this.negativeColor,
    this.zeroColor,
    this.secondaryPadding,
  });

  @override
  State<MoneyLabel> createState() => _MoneyLabelState();
}

final class _MoneyLabelState extends State<MoneyLabel> {
  @override
  Widget build(BuildContext context) {
    final effectiveMoney = resolveEffectiveMoney(widget.money);
    final effectiveColor = resolveEffectiveColor(effectiveMoney);

    final effectivePrimaryStyle = (Theme.of(context).textTheme.headlineMedium ?? DefaultTextStyle.of(context).style)
        .merge(widget.primaryTextStyle)
        .copyWith(color: effectiveColor);
    final effectiveSecondaryStyle = (Theme.of(context).textTheme.bodyMedium ?? DefaultTextStyle.of(context).style)
        .merge(widget.secondaryTextStyle)
        .copyWith(color: effectiveColor);
    final effectiveSecondaryPadding =
        widget.secondaryPadding ?? approximateSecondaryBottomPadding(effectivePrimaryStyle, effectiveSecondaryStyle);

    final currency = Currency.fromCode(effectiveMoney.currencyCode);
    final components = widget.fractionalMode == MoneyLabelFractionalMode.accurate
        ? DecimalComponents.fromDecimal(effectiveMoney.amount)
        : effectiveMoney.components;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.displayCurrency)
              Padding(
                padding: effectiveSecondaryPadding,
                child: Text(
                  '${currency?.symbol ?? effectiveMoney.currencyCode} ',
                  style: effectiveSecondaryStyle,
                ),
              ),
            if (widget.animation == null)
              Text(
                AmountFormatter.formattedMain(components.main, widget.separators.grouping),
                style: effectivePrimaryStyle,
              ),
            if (widget.animation != null)
              AnimatedFlipCounter(
                textStyle: effectivePrimaryStyle,
                curve: widget.animation!.curve,
                duration: widget.animation!.duration,
                negativeSignDuration: widget.animation!.duration,
                value: components.main,
                thousandSeparator: widget.separators.grouping,
              ),
            if (shouldDisplayFractionalPart(components)) ...[
              Padding(
                padding: effectiveSecondaryPadding,
                child: Text(
                  widget.separators.decimal,
                  style: effectiveSecondaryStyle,
                ),
              ),
              Padding(
                padding: effectiveSecondaryPadding,
                child: widget.animation == null
                    ? Text(
                        (components.fractional.toString()).padLeft(resolveFractionalDigits(effectiveMoney), '0'),
                        style: effectiveSecondaryStyle,
                      )
                    : AnimatedFlipCounter(
                        wholeDigits: resolveFractionalDigits(effectiveMoney),
                        textStyle: effectiveSecondaryStyle,
                        curve: widget.animation!.curve,
                        duration: widget.animation!.duration,
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
  // I tried relying on Row alphanumeric baseline alignment, but it has issue when AnimatedFlipCounter runs an animation.
  // I tried to use TextPainter with ascenders, descenders, line heights until I gave up to find a bullet proof solution.
  // Accepting pull requests!
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
      return widget.positiveColor;
    } else if (money.amount < Decimal.zero) {
      return widget.negativeColor;
    } else {
      return widget.zeroColor;
    }
  }

  int resolveFractionalDigits(Money money) {
    return widget.fractionalMode == MoneyLabelFractionalMode.accurate ? 1 : Currency.getPrecision(money.currencyCode);
  }

  Money resolveEffectiveMoney(Money money) {
    switch (widget.fractionalMode) {
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
    switch (widget.fractionalMode) {
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
