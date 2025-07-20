import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'money_formatter.dart';
import 'widgets/money_label/money_label.dart';

/// Provides subset of default values for [MoneyLabel] and [MoneyFormatter] below this widget in the widget tree.
final class MoneyPresentationDefaults extends InheritedWidget {
  /// The actual configuration.
  final MoneyPresentationDefaultsData data;

  /// Creates a [MoneyPresentationDefaults] object.
  const MoneyPresentationDefaults({
    super.key,
    required this.data,
    required super.child,
  });

  /// Returns the nearest [MoneyPresentationDefaultsData] from the widget tree, or `null` if none found.
  static MoneyPresentationDefaultsData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MoneyPresentationDefaults>()?.data;
  }

  @override
  bool updateShouldNotify(MoneyPresentationDefaults oldWidget) => data != oldWidget.data;
}

/// Holds the default values used by [MoneyLabel] widgets.
final class MoneyPresentationDefaultsData extends Equatable {
  /// Whether to display a negative sign for negative amounts.
  final bool? displayNegativeSign;

  /// Text style used for the main amount text.
  final TextStyle? primaryTextStyle;

  /// Text style used for secondary elements such as currency or decimals.
  final TextStyle? secondaryTextStyle;

  /// Colour to use when the amount is positive.
  final Color? positiveColor;

  /// Colour to use when the amount is negative.
  final Color? negativeColor;

  /// Colour to use when the amount is zero.
  final Color? zeroColor;

  /// Text to display next to currency when the amount is zero.
  /// e.g. Ø will be displayed as USD Ø
  final String? zeroText;

  /// Creates a [MoneyPresentationDefaultsData] object.
  const MoneyPresentationDefaultsData({
    this.displayNegativeSign,
    this.primaryTextStyle,
    this.secondaryTextStyle,
    this.positiveColor,
    this.negativeColor,
    this.zeroColor,
    this.zeroText,
  });

  @override
  List<Object?> get props => [
    primaryTextStyle,
    secondaryTextStyle,
    positiveColor,
    negativeColor,
    zeroColor,
    zeroText,
  ];
}
