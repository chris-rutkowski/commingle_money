// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

final class AnimatedAppearanceWrapper extends StatefulWidget {
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
  State<AnimatedAppearanceWrapper> createState() => _AnimatedAppearanceWrapperState();
}

final class _AnimatedAppearanceWrapperState extends State<AnimatedAppearanceWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.visible ? 1 : 0,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedAppearanceWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.visible != widget.visible) {
      controller.animateTo(
        widget.visible ? 1 : 0,
        duration: widget.duration,
        curve: widget.curve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      child: widget.child,
      builder: (context, child) {
        final value = controller.value;

        return IgnorePointer(
          ignoring: value == 0,
          child: ClipRect(
            child: Align(
              alignment: widget.alignment,
              widthFactor: value,
              child: Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.92 + (0.08 * value),
                  alignment: widget.alignment,
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
