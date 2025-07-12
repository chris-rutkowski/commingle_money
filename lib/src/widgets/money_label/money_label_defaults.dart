import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'money_label.dart';

/// Provides subset of default values for [MoneyLabel] widgets below this widget in the widget tree.
final class MoneyLabelDefaults extends InheritedWidget {

  /// The actual configuration.
  final MoneyLabelDefaultsData data;

  /// Creates a [MoneyLabelDefaults] object.
  const MoneyLabelDefaults({
    super.key,
    required this.data,
    required super.child,
  });

  /// Returns the nearest [MoneyLabelDefaultsData] from the widget tree, or `null` if none found.
  static MoneyLabelDefaultsData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MoneyLabelDefaults>()?.data;
  }

  @override
  bool updateShouldNotify(MoneyLabelDefaults oldWidget) => data != oldWidget.data;
}

/// Holds the default values used by [MoneyLabel] widgets.
final class MoneyLabelDefaultsData extends Equatable {
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

  /// Check README.
  final EdgeInsets? secondaryPadding;

  /// Creates a [MoneyLabelDefaultsData] object.
  const MoneyLabelDefaultsData({
    this.primaryTextStyle,
    this.secondaryTextStyle,
    this.positiveColor,
    this.negativeColor,
    this.zeroColor,
    this.secondaryPadding,
  });

  @override
  List<Object?> get props => [primaryTextStyle];
}
