// ignore_for_file: public_member_api_docs

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../math_operator.dart';
import 'animated_character.dart';
import 'animated_character_widget.dart';
import 'style_type_override.dart';

final class AwesomeOperatorWidget extends StatefulWidget {
  final MathOperator? operator;
  final Duration animationDuration;
  final Curve curve;
  final StyleTypeOverride? styleTypeOverride;

  const AwesomeOperatorWidget({
    super.key,
    required this.operator,
    required this.animationDuration,
    required this.curve,
    this.styleTypeOverride,
  });

  @override
  State<AwesomeOperatorWidget> createState() => _AwesomeOperatorWidgetState();
}

final class _AwesomeOperatorWidgetState extends State<AwesomeOperatorWidget> with TickerProviderStateMixin {
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
    final base =
        // MoneyPresentationDefaults.maybeOf(context)?.primaryTextStyle ??
        Theme.of(context).textTheme.headlineLarge!; // ??
    // DefaultTextStyle.of(context).style;

    final textStyle = base.merge(const TextStyle(fontWeight: FontWeight.bold));

    final children = <Widget>[];

    var width = 0.0;

    for (final character in characters) {
      final painter = TextPainter(
        text: TextSpan(text: character.character, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      children.add(
        AnimatedPositioned(
          key: character.key,
          duration: widget.animationDuration,
          curve: widget.curve,
          left: 0,
          child: AnimatedCharacterWidget(
            character: character,
            textStyle: textStyle,
            placeholderColor: Colors.grey,
            styleTypeOverride: widget.styleTypeOverride,
            curve: widget.curve,
            duration: widget.animationDuration,
          ),
        ),
      );

      width += painter.width;
    }

    for (final character in retiredCharacters) {
      children.add(
        AnimatedPositioned(
          key: character.key,
          duration: widget.animationDuration,
          curve: widget.curve,
          left: 0,
          child: AnimatedCharacterWidget(
            character: character,
            textStyle: textStyle,
            placeholderColor: Colors.grey,
            styleTypeOverride: widget.styleTypeOverride,
            curve: widget.curve,
            duration: widget.animationDuration,
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: widget.animationDuration,
      curve: widget.curve,
      width: width,
      height: 40,
      color: Colors.yellow.withAlpha(50),
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
  void didUpdateWidget(covariant AwesomeOperatorWidget oldWidget) {
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
