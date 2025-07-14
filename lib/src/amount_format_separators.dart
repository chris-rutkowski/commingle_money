import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'widgets/money_label/money_label.dart';

/// Provides default separators to be used by [MoneyLabel] and other widgets and utilities
/// below this widget in the widget tree.
final class AmountFormatSeparators extends InheritedWidget {
  /// The actual configuration.
  final AmountFormatSeparatorsData data;

  /// Creates a [AmountFormatSeparators] object.
  const AmountFormatSeparators({
    super.key,
    required this.data,
    required super.child,
  });

  /// Returns the [AmountFormatSeparatorsData] from the nearest [AmountFormatSeparators] in the widget tree,
  /// or default [AmountFormatSeparatorsData] if none found.
  /// Safe to use in [State.build] or [State.didChangeDependencies], but not in [State.initState].
  static AmountFormatSeparatorsData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AmountFormatSeparators>()?.data ??
        const AmountFormatSeparatorsData();
  }

  /// Reads (once) the [AmountFormatSeparatorsData] from the nearest [AmountFormatSeparators] in the widget tree,
  /// or default [AmountFormatSeparatorsData] if none found.
  /// Safe to use in [State.initState].
  static AmountFormatSeparatorsData read(BuildContext context) {
    return context.getInheritedWidgetOfExactType<AmountFormatSeparators>()?.data ?? const AmountFormatSeparatorsData();
  }

  @override
  bool updateShouldNotify(AmountFormatSeparators oldWidget) => data != oldWidget.data;
}

/// Separators used for formatting and parsing amounts.
final class AmountFormatSeparatorsData extends Equatable {
  /// The grouping separator, typically used for thousands, often a comma or space.
  final String grouping;

  /// The decimal separator, typically a dot or comma.
  final String decimal;

  /// Creates an instance of [AmountFormatSeparatorsData] with the specified [grouping] and [decimal] separators.
  const AmountFormatSeparatorsData({
    this.grouping = ',',
    this.decimal = '.',
  });

  /// Common format for the `pl_PL` locale where the grouping separator is a space
  /// and the decimal separator is a comma.
  static const AmountFormatSeparatorsData pl = AmountFormatSeparatorsData(
    grouping: ' ',
    decimal: ',',
  );

  @override
  List<Object?> get props => [grouping, decimal];
}
