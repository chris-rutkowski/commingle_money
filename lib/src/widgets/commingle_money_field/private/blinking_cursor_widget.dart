// ignore_for_file: public_member_api_docs

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final class BlinkingCursorWidget extends StatelessWidget {
  final AnimationController controller;
  final TextStyle textStyle;
  final Color? color;
  final double weight;

  const BlinkingCursorWidget({
    super.key,
    required this.controller,
    required this.textStyle,
    this.color,
    this.weight = 2.0,
  });

  /// Implementation as per documentation of [TextField.cursorColor]
  Color _resolveEffectiveColor(BuildContext context) {
    final result = color ?? DefaultSelectionStyle.of(context).cursorColor;

    if (result != null) {
      return result;
    }

    if (Theme.of(context).platform == .iOS || Theme.of(context).platform == .macOS) {
      return CupertinoTheme.of(context).primaryColor;
    }

    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: '0', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    return FadeTransition(
      opacity:
          TweenSequence<double>([
            TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
            TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 10),
            TweenSequenceItem(tween: ConstantTween(0), weight: 20),
          ]).animate(
            CurvedAnimation(parent: controller, curve: Curves.linear),
          ),
      child: Transform.translate(
        offset: Offset(-weight / 2, 0),
        child: Container(
          width: weight,
          height: painter.height,
          color: _resolveEffectiveColor(context),
        ),
      ),
    );
  }
}
