// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

final class AnimatedAppearanceWrapper extends StatelessWidget {
  final bool visible;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;
  final Widget child;

  const AnimatedAppearanceWrapper({
    super.key,
    required this.visible,
    required this.duration,
    required this.curve,
    required this.alignment,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: visible ? 1 : 0),
      duration: duration,
      curve: curve,
      child: child,
      builder: (context, value, child) {
        return IgnorePointer(
          ignoring: value == 0,
          child: ClipRect(
            child: Align(
              alignment: alignment,
              widthFactor: value,
              child: Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.92 + (0.08 * value),
                  alignment: alignment,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
