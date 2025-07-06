// TODO: to drop
// ignore_for_file: public_member_api_docs

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../commingle_money.dart';

enum MoneyLabelFractionalMode {
  flexible,
  always,
  // round,
  // accurate,
}

final class MoneyLabel extends StatefulWidget {
  final Money money;
  final MoneyLabelFractionalMode fractionalMode;
  // TODO: or listenable<Money> but not both
  // fractionalMode
  // - always - display always e.g. 12.00
  // - round - will round the value -> 12.99 -> 13
  // - flexible - will display fractional part only if needed
  // - accurate - will display as many values as there are in this value

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
    final effectiveColor = resolveEffectiveColor();

    final effectivePrimaryStyle = (Theme.of(context).textTheme.headlineMedium ?? DefaultTextStyle.of(context).style)
        .merge(widget.primaryTextStyle)
        .copyWith(color: effectiveColor);
    final effectiveSecondaryStyle = (Theme.of(context).textTheme.bodyMedium ?? DefaultTextStyle.of(context).style)
        .merge(widget.secondaryTextStyle)
        .copyWith(color: effectiveColor);
    final effectiveSecondaryPadding =
        widget.secondaryPadding ?? approximateSecondaryBottomPadding(effectivePrimaryStyle, effectiveSecondaryStyle);

    final currency = Currency.fromCode(widget.money.currencyCode);
    final components = widget.money.components;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (currency != null)
              Padding(
                padding: effectiveSecondaryPadding,
                child: Text(
                  '${currency.symbol ?? currency.code} ',
                  style: effectiveSecondaryStyle,
                ),
              ),
            AnimatedFlipCounter(
              textStyle: effectivePrimaryStyle,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 200),
              value: components.main,
              thousandSeparator: 'k', // TODO: inject separator
            ),
            if (shouldDisplayFractionalPart(components)) ...[
              Padding(
                padding: effectiveSecondaryPadding,
                child: Text(
                  '.', // TODO: inject separator
                  style: effectiveSecondaryStyle,
                ),
              ),
              Padding(
                padding: effectiveSecondaryPadding,
                child: AnimatedFlipCounter(
                  wholeDigits: Currency.getPrecision(widget.money.currencyCode),
                  textStyle: effectiveSecondaryStyle,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 200),
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

  Color? resolveEffectiveColor() {
    if (widget.money.amount > Decimal.zero) {
      return widget.positiveColor;
    } else if (widget.money.amount < Decimal.zero) {
      return widget.negativeColor;
    } else {
      return widget.zeroColor;
    }
  }

  bool shouldDisplayFractionalPart(DecimalComponents components) {
    switch (widget.fractionalMode) {
      case MoneyLabelFractionalMode.flexible:
        return components.fractional != 0;
      case MoneyLabelFractionalMode.always:
        return true;
      // case MoneyLabelFractionalMode.round:
      //   return components.fractional != Decimal.zero && components.main != Decimal.zero;
      // case MoneyLabelFractionalMode.accurate:
      //   return true; // always display accurate
    }
  }
}
