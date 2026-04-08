// ignore_for_file: public_member_api_docs

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../math_operator.dart';
import 'animated_character.dart';
import 'animated_character_widget.dart';
import 'style_type_override.dart';

final class AnimatedOperatorWidget extends StatefulWidget {
  final MathOperator? operator;
  final TextStyle textStyle;
  final Duration animationDuration;
  final Curve curve;
  final Color? placeholderColor;
  final StyleTypeOverride? styleTypeOverride;

  const AnimatedOperatorWidget({
    super.key,
    required this.operator,
    required this.textStyle,
    required this.animationDuration,
    required this.curve,
    required this.placeholderColor,
    this.styleTypeOverride,
  });

  @override
  State<AnimatedOperatorWidget> createState() => _AnimatedOperatorWidgetState();
}

final class _AnimatedOperatorWidgetState extends State<AnimatedOperatorWidget> with TickerProviderStateMixin {
  final characters = <AnimatedCharacter>[];
  final retiredCharacters = <AnimatedCharacter>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final character in characters) {
      character.animationController.dispose();
    }

    for (final character in retiredCharacters) {
      character.animationController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: '0', style: widget.textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final children = <Widget>[];
    var width = 0.0;

    for (final character in characters) {
      final painter = TextPainter(
        text: TextSpan(text: character.character, style: widget.textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      children.add(
        AnimatedCharacterWidget(
          key: character.key,
          left: 0,
          character: character,
          textStyle: widget.textStyle,
          placeholderColor: widget.placeholderColor,
          styleTypeOverride: widget.styleTypeOverride,
          curve: widget.curve,
          duration: widget.animationDuration,
        ),
      );

      width += painter.width;
    }

    for (final character in retiredCharacters) {
      children.add(
        AnimatedCharacterWidget(
          key: character.key,
          left: 0,
          character: character,
          textStyle: widget.textStyle,
          placeholderColor: widget.placeholderColor,
          styleTypeOverride: widget.styleTypeOverride,
          curve: widget.curve,
          duration: widget.animationDuration,
        ),
      );
    }

    return AnimatedContainer(
      duration: widget.animationDuration,
      curve: widget.curve,
      width: width,
      height: painter.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...children,
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    manage(animated: false);
  }

  void retireCharacter(AnimatedCharacter character) {
    characters.remove(character);
    retiredCharacters.add(character);

    character.animationController.reverse().then((value) {
      character.animationController.dispose();
      retiredCharacters.remove(character);
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedOperatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    manage();
  }

  void manage({bool animated = true}) {
    if (widget.operator != null) {
      final string = widget.operator!.stringValue;

      if (characters.firstOrNull?.character != string) {
        characters.toList().forEach(retireCharacter);

        characters.add(
          AnimatedCharacter(
            animationController: createAnimationController(animate: animated),
            role: .operator,
            character: string,
          ),
        );
      }
    } else {
      characters.toList().forEach(retireCharacter);
    }
  }

  // <Utilities>

  AnimationController createAnimationController({required bool animate}) {
    final controller = AnimationController(vsync: this, duration: widget.animationDuration);
    animate ? controller.forward() : controller.value = 1;
    return controller;
  }

  // </Utilities>
}

extension on MathOperator {
  String get stringValue {
    switch (this) {
      case .plus:
        return '+';
      case .minus:
        return '-';
      case .multiply:
        return '×';
      case .divide:
        return '÷';
      case .equal:
        return '=';
    }
  }
}
