// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'animated_character.dart';
import 'awesome_style_override.dart';

final class AnimatedCharacterWidget extends StatelessWidget {
  final AnimatedCharacter character;
  final TextStyle textStyle;
  final Color placeholderColor;
  final AwesomeStyleOverride? styleOverride;
  final Curve curve;
  final Duration duration;

  const AnimatedCharacterWidget({
    super.key,
    required this.character,
    required this.textStyle,
    required this.placeholderColor,
    this.styleOverride,
    required this.curve,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = textStyle.copyWith(
      color: (styleOverride == .placeholder || (character.role.isPlaceholder && styleOverride != .normal))
          ? placeholderColor
          : null,
    );

    return ListenableBuilder(
      listenable: character.animationController,
      builder: (context, child) {
        final scale = character.animationController.isForwardOrCompleted
            ? Tween(
                    begin: 0.75,
                    end: 1.0,
                  )
                  .animate(
                    CurvedAnimation(
                      parent: character.animationController,
                      curve: Curves.easeOutBack,
                    ),
                  )
                  .value
            : character.animationController.value;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: character.animationController.value,
            child: AnimatedDefaultTextStyle(
              duration: duration,
              curve: curve,
              style: effectiveStyle,
              child: Text(character.character),
            ),
          ),
        );
      },
    );
  }
}
