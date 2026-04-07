// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../../commingle_money.dart';
import '../../../private/amount_formatter.dart';
import '../../../private/decimal_components.dart';
import '../../../private/list_extensions.dart';
import 'blinking_cursor_widget.dart';

// To improve:
// - AnimatedPositionedDirectional for RTL

final class AnimatedMoneyLabel extends StatefulWidget {
  final String? stringNumber;
  final CurrencyCode currencyCode;
  final Duration animationDuration;
  final Curve curve;
  final AmountFormatSeparatorsData? separators;
  final bool showCursor;
  final Color? cursorColor;
  final String placeholder;

  const AnimatedMoneyLabel({
    super.key,
    required this.stringNumber,
    required this.currencyCode,
    this.animationDuration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOut,
    this.separators,
    this.showCursor = false,
    this.cursorColor,
    this.placeholder = '0',
  });

  @override
  State<AnimatedMoneyLabel> createState() => _AnimatedMoneyLabelState();
}

final class _AnimatedMoneyLabelState extends State<AnimatedMoneyLabel> with TickerProviderStateMixin {
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
    // TODO: check if animation was still runing and we do double dispose or something
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
    final base =
        // MoneyPresentationDefaults.maybeOf(context)?.primaryTextStyle ??
        Theme.of(context).textTheme.headlineLarge!; // ??
    // DefaultTextStyle.of(context).style;

    final textStyle = base.merge(const TextStyle(fontWeight: FontWeight.bold));

    final children = <Widget>[];

    var leading = 0.0;
    var width = 0.0;
    var cursorLeading = 0.0;

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
          left: leading,
          child: AnimatedCharacterWidget(character: character, textStyle: textStyle, placeholderColor: Colors.grey),
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
        AnimatedPositioned(
          key: character.key,
          duration: widget.animationDuration,
          curve: widget.curve,
          left: character.retiredLeading,
          child: AnimatedCharacterWidget(character: character, textStyle: textStyle, placeholderColor: Colors.grey),
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
        clipBehavior: Clip.none, // for cursor
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
                textStyle: textStyle,
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

    final effectiveSeparators = _resolveEffectiveSeparators(context);

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
  void didUpdateWidget(covariant AnimatedMoneyLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final effectiveSeparators = _resolveEffectiveSeparators(context);

    // TODO consider that abs or something here

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

    // TODO adjusting decimal separators

    // TODO: Edge case when entering dot after having only 0

    // TODO: Edge case for negative number

    // TODO: edge case when new change happens while previous is still animating maybe
  }

  AmountFormatSeparatorsData _resolveEffectiveSeparators(BuildContext context) {
    return widget.separators ?? AmountFormatSeparators.of(context);
  }

  void managePlaceholder() {
    final existingPlaceholder = characters.firstWhereOrNull((e) => e.role == .placeholder);

    if (existingPlaceholder != null && existingPlaceholder.character != widget.placeholder) {
      existingPlaceholder.character = widget.placeholder;
    }

    if (widget.stringNumber == null && existingPlaceholder == null) {
      characters.add(
        AnimatedCharacter(
          role: .placeholder,
          character: widget.placeholder,
          animationController: createAnimationController(animate: false),
        ),
      );
    } else if (widget.stringNumber != null && existingPlaceholder != null) {
      retireCharacter(existingPlaceholder);
    }
  }

  void addPendingDigits({bool animated = true}) {
    if (widget.stringNumber == null) {
      return;
    }

    final rawCharacters = getMainDigits();
    final digitsCharactersLength = characters.where((e) => e.role == .digit).length;

    var index = characters.lastIndexWhere((e) => e.role == .digit); // -1 if null, so as intended
    for (var i = digitsCharactersLength; i < rawCharacters.length; i++) {
      characters.insert(
        index + 1,
        AnimatedCharacter(
          role: .digit,
          character: rawCharacters[i],
          animationController: createAnimationController(animate: animated),
        ),
      );
      index++;
    }
  }

  void removeExcessDigits() {
    final keepCount = widget.stringNumber == null ? 0 : getMainDigits().length;
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
    if (widget.stringNumber == null) {
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
    if (widget.stringNumber == null) {
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
          role: .groupingSeparator,
          character: separator,
          animationController: createAnimationController(animate: animated),
        ),
      );
    }
  }

  void removeExcessGroupingSeparatorsAnimated({required String separator}) {
    final needed = widget.stringNumber == null
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
    if (widget.stringNumber == null) {
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
    // or if money has that part
    final show = widget.stringNumber != null && widget.stringNumber!.contains('.');

    if (show) {
      if (characters.none((e) => e.role == .decimalSeparator)) {
        characters.add(
          AnimatedCharacter(
            role: .decimalSeparator,
            character: separator,
            animationController: createAnimationController(animate: animated),
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
          role: .fractionalDigit,
          character: rawCharacters[i],
          animationController: createAnimationController(animate: animated),
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
          role: .fractionalPlaceholder,
          character: '0',
          animationController: createAnimationController(animate: animated),
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

    if (animate) {
      controller.forward();
    } else {
      controller.value = 1;
    }

    return controller;
  }

  List<String> getMainDigits() {
    if (widget.stringNumber == null) {
      return [];
    }

    return widget.stringNumber!.split('.')[0].split('');
  }

  List<int> getMainDigitsAsInt() => getMainDigits().map(int.parse).toList();

  List<String> getFractionalDigits() {
    if (widget.stringNumber == null || !widget.stringNumber!.contains('.')) {
      return [];
    }

    return widget.stringNumber!.split('.')[1].split('');
  }

  List<int> getFractionalDigitsAsInt() => getFractionalDigits().map(int.parse).toList();

  // </Utilities>
}

enum AnimatedCharacterRole {
  placeholder,
  digit,
  groupingSeparator,
  decimalSeparator,
  fractionalDigit,
  fractionalPlaceholder,
}

extension on AnimatedCharacterRole {
  bool get isPlaceholder => this == .placeholder || this == .fractionalPlaceholder;
}

final class AnimatedCharacter {
  final Key key;
  final AnimatedCharacterRole role;
  String character;
  double retiredLeading;
  final AnimationController animationController;

  AnimatedCharacter({
    required this.role,
    required this.character,
    this.retiredLeading = 0,
    required this.animationController,
  }) : key = UniqueKey();

  @override
  String toString() {
    return 'AnimatedCharacter($character - $role)';
  }
}

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
