// TODO: to drop
// ignore_for_file: public_member_api_docs

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../commingle_money.dart';

final class MoneyLabel extends StatefulWidget {
  final Money money;
  // TODO: or listenable<Money> but not both
  // fractionalMode
  // - always - display always e.g. 12.00
  // - round - will round the value -> 12.99 -> 13
  // - flexible - will display fractional part only if needed

  final TextStyle? primaryTextStyle;
  final TextStyle? secondaryTextStyle;
  final Color? positiveColor;
  final Color? negativeColor;
  final Color? zeroColor;
  final EdgeInsets? secondaryPadding;

  const MoneyLabel({
    super.key,
    required this.money,
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
    final effectiveColor = widget.money.amount > Decimal.zero
        ? widget.positiveColor
        : widget.money.amount < Decimal.zero
        ? widget.negativeColor
        : widget.zeroColor;

    final effectivePrimaryStyle = (Theme.of(context).textTheme.headlineMedium ?? DefaultTextStyle.of(context).style)
        .merge(widget.primaryTextStyle)
        .copyWith(color: effectiveColor);
    final effectiveSecondaryStyle = (Theme.of(context).textTheme.bodyMedium ?? DefaultTextStyle.of(context).style)
        .merge(widget.secondaryTextStyle)
        .copyWith(color: effectiveColor);
    final effectiveSecondaryPadding =
        widget.secondaryPadding ?? approximateSecondaryBottomPadding(effectivePrimaryStyle, effectiveSecondaryStyle);

    final currency = Currency.fromCode(widget.money.currencyCode);
    final components = DecimalComponents.fromDecimal(widget.money.amount);

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
              thousandSeparator: 'k',
            ),
            Padding(
              padding: effectiveSecondaryPadding,
              child: Text(
                '.33',
                style: effectiveSecondaryStyle,
              ),
            ),
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
}
