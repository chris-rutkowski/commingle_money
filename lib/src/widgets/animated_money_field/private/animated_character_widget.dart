
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'animated_character.dart';

final class AnimatedCharacterWidget extends StatelessWidget {
  final AnimatedCharacter character;
  final TextStyle textStyle;
  final Color placeholderColor;

  const AnimatedCharacterWidget({
    super.key,
    required this.character,
    required this.textStyle,
    required this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = textStyle.copyWith(
      color: character.role.isPlaceholder ? placeholderColor : null,
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
            child: Text(
              character.character,
              style: effectiveStyle,
            ),
          ),
        );
      },
    );
  }
}
