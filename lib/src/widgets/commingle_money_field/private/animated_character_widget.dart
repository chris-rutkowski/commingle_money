// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'animated_character.dart';
import 'animated_character_role.dart';
import 'animated_number_widget.dart';
import 'animated_operator_widget.dart';
import 'style_type_override.dart';

/// Single character widget displayed in [AnimatedNumberWidget] and [AnimatedOperatorWidget]
final class AnimatedCharacterWidget extends StatelessWidget {
  final AnimatedCharacter character;
  final TextStyle textStyle;
  final Color? placeholderColor;
  final StyleTypeOverride? styleTypeOverride;
  final Curve curve;
  final Duration duration;

  const AnimatedCharacterWidget({
    super.key,
    required this.character,
    required this.textStyle,
    required this.placeholderColor,
    this.styleTypeOverride,
    required this.curve,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = textStyle.copyWith(
      color: (styleTypeOverride == .placeholder || (character.role.isPlaceholder && styleTypeOverride != .normal))
          ? _resolveEffectivePlaceholderColor(context)
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

  Color _resolveEffectivePlaceholderColor(BuildContext context) {
    final result = placeholderColor ?? Theme.of(context).inputDecorationTheme.hintStyle?.color;

    if (result != null) {
      return result;
    }

    return Colors.grey;
  }
}
