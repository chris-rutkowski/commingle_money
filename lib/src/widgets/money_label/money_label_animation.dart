import 'package:flutter/material.dart';

import '../../../commingle_money.dart';

/// Defines animation parameters for transitioning between values in a [MoneyLabel].
final class MoneyLabelAnimation {
  /// The duration of the animation.
  final Duration duration;

  /// The animation curve to apply.
  final Curve curve;

  /// Creates a [MoneyLabelAnimation] with the given [duration] and [curve].
  const MoneyLabelAnimation({
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOut,
  });
}
