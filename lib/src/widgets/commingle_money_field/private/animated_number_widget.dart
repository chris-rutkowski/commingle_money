// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../amount_format_separators.dart';
import '../../../currency.dart';
import '../../../currency_code.dart';
import '../../../private/amount_formatter.dart';
import '../../../private/decimal_components.dart';
import '../../../private/list_extensions.dart';
import 'animated_character.dart';
import 'animated_character_role.dart';
import 'animated_character_widget.dart';
import 'blinking_cursor_widget.dart';
import 'style_type_override.dart';

final class AnimatedNumberWidget extends StatefulWidget {
  final String? text;
  final TextStyle textStyle;
  final CurrencyCode currencyCode;
  final Duration animationDuration;
  final Curve curve;
  final AmountFormatSeparatorsData? separators;
  final bool showCursor;
  final Color? cursorColor;
  final String placeholder;
  final Color? placeholderColor;
  final StyleTypeOverride? styleTypeOverride;

  const AnimatedNumberWidget({
    super.key,
    required this.text,
    required this.textStyle,
    required this.currencyCode,
    required this.animationDuration,
    required this.curve,
    this.separators,
    this.showCursor = false,
    this.cursorColor,
    required this.placeholder,
    required this.placeholderColor,
    this.styleTypeOverride,
  });

  @override
  State<AnimatedNumberWidget> createState() => _AnimatedNumberWidgetState();
}

final class _AnimatedNumberWidgetState extends State<AnimatedNumberWidget> with TickerProviderStateMixin {
  final characters = <AnimatedCharacter>[];
  final retiredCharacters = <AnimatedCharacter>[];
  late final AnimationController cursorController;

  @override
  void initState() {
    super.initState();

    cursorController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    for (final character in characters) {
      character.animationController.dispose();
    }

    for (final character in retiredCharacters) {
      character.animationController.dispose();
    }

    cursorController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: '0', style: widget.textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final children = <Widget>[];
    var leading = 0.0;
    var width = 0.0;
    var cursorLeading = 0.0;

    for (final character in characters) {
      final painter = TextPainter(
        text: TextSpan(text: character.character, style: widget.textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      children.add(
        AnimatedCharacterWidget(
          key: character.key,
          left: leading,
          character: character,
          textStyle: widget.textStyle,
          placeholderColor: widget.placeholderColor,
          styleTypeOverride: widget.styleTypeOverride,
          duration: widget.animationDuration,
          curve: widget.curve,
        ),
      );

      character.retiredLeading = leading;
      leading += painter.width;
      width += painter.width;

      if (!character.role.isPlaceholder) {
        cursorLeading = leading;
      }
    }

    for (final character in retiredCharacters) {
      children.add(
        AnimatedCharacterWidget(
          key: character.key,
          left: character.retiredLeading,
          character: character,
          textStyle: widget.textStyle,
          placeholderColor: widget.placeholderColor,
          styleTypeOverride: widget.styleTypeOverride,
          duration: widget.animationDuration,
          curve: widget.curve,
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
          if (widget.showCursor)
            AnimatedPositioned(
              key: const ValueKey('cursor'),
              duration: widget.animationDuration,
              curve: widget.curve,
              top: 0,
              left: cursorLeading,
              child: BlinkingCursorWidget(
                controller: cursorController,
                textStyle: widget.textStyle,
                color: widget.cursorColor,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final effectiveSeparators = resolveEffectiveSeparators(context);

    managePlaceholder();
    addPendingDigits(animated: false);
    addPendingGroupingSeparator(animated: false, separator: effectiveSeparators.grouping);
    rearrangeGroupingSeparators(separator: effectiveSeparators.grouping);
    manageFractional(animated: false, separator: effectiveSeparators.decimal);
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
  void didUpdateWidget(covariant AnimatedNumberWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final effectiveSeparators = resolveEffectiveSeparators(context);

    managePlaceholder();
    addPendingDigits();
    removeExcessDigits();
    updateExistingDigits();
    addPendingGroupingSeparator(separator: effectiveSeparators.grouping);
    removeExcessGroupingSeparatorsAnimated(separator: effectiveSeparators.grouping);
    rearrangeGroupingSeparators(separator: effectiveSeparators.grouping);
    manageFractional(separator: effectiveSeparators.decimal);

    cursorController.value = 0;
    cursorController.repeat(reverse: true);
  }

  AmountFormatSeparatorsData resolveEffectiveSeparators(BuildContext context) {
    return widget.separators ?? AmountFormatSeparators.of(context);
  }

  void managePlaceholder() {
    final existingPlaceholder = characters.firstWhereOrNull((e) => e.role == .placeholder);

    if (existingPlaceholder != null && existingPlaceholder.character != widget.placeholder) {
      existingPlaceholder.character = widget.placeholder;
    }

    if (widget.text == null && existingPlaceholder == null) {
      characters.add(
        AnimatedCharacter(
          animationController: createAnimationController(animate: false),
          role: .placeholder,
          character: widget.placeholder,
        ),
      );
    } else if (widget.text != null && existingPlaceholder != null) {
      retireCharacter(existingPlaceholder);
    }
  }

  void addPendingDigits({bool animated = true}) {
    if (widget.text == null) {
      return;
    }

    final rawCharacters = getMainDigits();
    final digitsCharactersLength = characters.where((e) => e.role == .digit).length;

    var index = characters.lastIndexWhere((e) => e.role == .digit); // -1 if null, so as intended
    for (var i = digitsCharactersLength; i < rawCharacters.length; i++) {
      characters.insert(
        index + 1,
        AnimatedCharacter(
          animationController: createAnimationController(animate: animated),
          role: .digit,
          character: rawCharacters[i],
        ),
      );
      index++;
    }
  }

  void removeExcessDigits() {
    final keepCount = widget.text == null ? 0 : getMainDigits().length;
    final digitsCharactersIndexes = characters.allIndexesWhere((e) => e.role == .digit);
    final charactersToRetire = digitsCharactersIndexes
        .sublist(keepCount)
        .map((index) => characters[index])
        .toList(growable: false);

    for (final character in charactersToRetire) {
      retireCharacter(character);
    }
  }

  void updateExistingDigits() {
    if (widget.text == null) {
      return;
    }

    final rawCharacters = getMainDigits();
    final digitsCharactersIndexes = characters.allIndexesWhere((e) => e.role == .digit);

    for (var i = 0; i < rawCharacters.length; i++) {
      final index = digitsCharactersIndexes[i];
      if (characters[index].character != rawCharacters[i]) {
        characters[index].character = rawCharacters[i];
      }
    }
  }

  /// adds grouping separators in the beginning of characters list later to be rearranged by [rearrangeGroupingSeparators]
  void addPendingGroupingSeparator({bool animated = true, required String separator}) {
    if (widget.text == null) {
      return;
    }

    final components = DecimalComponents.fromDigits(getMainDigitsAsInt());
    final formatted = AmountFormatter.formattedMain(components.main, separator);
    final needed = formatted.split('').where((e) => e == separator).length;

    final existing = characters.where((e) => e.role == .groupingSeparator).toList();

    for (var i = 0; i < needed - existing.length; i++) {
      characters.insert(
        0,
        AnimatedCharacter(
          animationController: createAnimationController(animate: animated),
          role: .groupingSeparator,
          character: separator,
        ),
      );
    }
  }

  void removeExcessGroupingSeparatorsAnimated({required String separator}) {
    final needed = widget.text == null
        ? 0
        : AmountFormatter.formattedMain(
            DecimalComponents.fromDigits(getMainDigitsAsInt()).main,
            separator,
          ).split('').where((e) => e == separator).length;

    final separators = characters.where((e) => e.role == .groupingSeparator).toList();

    final charactersToRetire = separators.sublist(0, separators.length - needed).toList(growable: false);

    for (final character in charactersToRetire) {
      retireCharacter(character);
    }
  }

  void rearrangeGroupingSeparators({required String separator}) {
    if (widget.text == null) {
      return;
    }

    final components = DecimalComponents.fromDigits(getMainDigitsAsInt());
    final formatted = AmountFormatter.formattedMain(components.main, separator);
    final indexes = formatted.split('').allIndexesOf(separator);

    final separators = characters.where((e) => e.role == .groupingSeparator).toList();
    for (final separator in separators) {
      characters.remove(separator);
    }

    for (var i = 0; i < indexes.length; i++) {
      characters.insert(
        indexes[i],
        separators[i],
      );
    }
  }

  void manageFractional({bool animated = true, required String separator}) {
    final show = widget.text != null && widget.text!.contains('.');

    if (show) {
      if (characters.none((e) => e.role == .decimalSeparator)) {
        characters.add(
          AnimatedCharacter(
            animationController: createAnimationController(animate: animated),
            role: .decimalSeparator,
            character: separator,
          ),
        );
      }

      final rawCharacters = getFractionalDigits();

      addPendingFractionalDigits(rawCharacters: rawCharacters, animated: animated);
      removeExcessFractionalDigits(rawCharacters: rawCharacters, animated: animated);
      updateExistingFractionalDigits(rawCharacters: rawCharacters, animated: animated);
      manageFractionalPlaceholders(rawCharacters: rawCharacters, animated: animated);
    } else {
      characters
          .where((e) => e.role == .decimalSeparator || e.role == .fractionalDigit || e.role == .fractionalPlaceholder)
          .toList(growable: false)
          .forEach(retireCharacter);
    }
  }

  void addPendingFractionalDigits({bool animated = true, required List<String> rawCharacters}) {
    final existingFractionalDigitsCharactersLength = characters.where((e) => e.role == .fractionalDigit).length;

    var index =
        characters.lastIndexWhereOrNull((e) => e.role == .fractionalDigit) ??
        characters.lastIndexWhere((e) => e.role == .decimalSeparator);

    for (var i = existingFractionalDigitsCharactersLength; i < rawCharacters.length; i++) {
      characters.insert(
        index + 1,
        AnimatedCharacter(
          animationController: createAnimationController(animate: animated),
          role: .fractionalDigit,
          character: rawCharacters[i],
        ),
      );

      index++;
    }
  }

  void manageFractionalPlaceholders({bool animated = true, required List<String> rawCharacters}) {
    final precision = Currency.getPrecision(widget.currencyCode);
    final needed = max(precision - rawCharacters.length, 0);

    final indexes = characters.allIndexesWhere((e) => e.role == .fractionalPlaceholder).toList(growable: false);

    for (var i = 0; i < needed - indexes.length; i++) {
      characters.add(
        AnimatedCharacter(
          animationController: createAnimationController(animate: animated),
          role: .fractionalPlaceholder,
          character: '0',
        ),
      );
    }

    final charactersToRetire = indexes
        .take(max(0, indexes.length - needed))
        .map((index) => characters[index])
        .toList(growable: false);

    for (final character in charactersToRetire) {
      retireCharacter(character);
    }
  }

  void removeExcessFractionalDigits({bool animated = true, required List<String> rawCharacters}) {
    final charactersIndexes = characters.allIndexesWhere((e) => e.role == .fractionalDigit);
    final charactersToRetire = charactersIndexes
        .sublist(rawCharacters.length)
        .map((index) => characters[index])
        .toList(growable: false);

    for (final character in charactersToRetire) {
      retireCharacter(character);
    }
  }

  void updateExistingFractionalDigits({bool animated = true, required List<String> rawCharacters}) {
    final indexes = characters.allIndexesWhere((e) => e.role == .fractionalDigit);

    for (var i = 0; i < rawCharacters.length; i++) {
      final index = indexes[i];
      if (characters[index].character != rawCharacters[i]) {
        characters[index].character = rawCharacters[i];
      }
    }
  }

  // <Utilities>

  AnimationController createAnimationController({required bool animate}) {
    final controller = AnimationController(vsync: this, duration: widget.animationDuration);
    animate ? controller.forward() : controller.value = 1;
    return controller;
  }

  List<String> getMainDigits() {
    if (widget.text == null) {
      return [];
    }

    return widget.text!.split('.')[0].split('');
  }

  List<int> getMainDigitsAsInt() => getMainDigits().map(int.parse).toList();

  List<String> getFractionalDigits() {
    if (widget.text == null || !widget.text!.contains('.')) {
      return [];
    }

    return widget.text!.split('.')[1].split('');
  }

  List<int> getFractionalDigitsAsInt() => getFractionalDigits().map(int.parse).toList();

  // </Utilities>
}
