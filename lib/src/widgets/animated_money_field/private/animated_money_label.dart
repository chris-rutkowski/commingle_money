// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../commingle_money.dart';
import '../../../private/amount_formatter.dart';
import '../../../private/decimal_components.dart';

// To improve:
// - AnimatedPositionedDirectional for RTL

final class AnimatedMoneyLabel extends StatefulWidget {
  final Money money;
  final Duration animationDuration;
  final Curve curve;
  final AmountFormatSeparatorsData? separators;
  final bool forceFractional;
  final bool showCursor;
  final Color? cursorColor;

  const AnimatedMoneyLabel({
    super.key,
    required this.money,
    this.animationDuration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOut,
    this.separators,
    this.forceFractional = false,
    this.showCursor = false,
    this.cursorColor,
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
    // final characters = widget.money.abs().toString().split('');

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
          top: 0,
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
          top: 0,
          left: character.retiredLeading,
          child: AnimatedCharacterWidget(character: character, textStyle: textStyle, placeholderColor: Colors.grey),
        ),
      );
    }

    return FittedBox(
      child: AnimatedContainer(
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
                child: BlinkingCursor(
                  controller: cursorController,
                  textStyle: textStyle,
                  color: widget.cursorColor,
                ),
              ),
          ],

          // [
          //   // Text(widget.money.toString()),
          //   AnimatedPositioned(
          //     duration: widget.animationDuration,
          //     curve: widget.curve,
          //     top: 0,
          //     left: 20,
          //     child: Text(
          //       'a',
          //       style: textStyle,
          //     ),
          //   ),
          // ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final effectiveSeparators = _resolveEffectiveSeparators(context);

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

    // if (oldWidget.money.currencyCode != widget.money.currencyCode) {
    //   print('not animating due to different currency code');
    //   // recreate tokens
    //   return;
    // }

    // TODO consider that abs or something here

    // if ((oldCharacters.length - newCharacters.length).abs() == 1) {

    // final newCharacters = widget.money.amount.abs().toString().split('');

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

  void addPendingDigits({bool animated = true}) {
    final components = DecimalComponents.fromMoney(widget.money);
    final rawCharacters = components.main.toString().split('');

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
    final components = DecimalComponents.fromMoney(widget.money);
    final rawCharacters = components.main.toString().split('');

    final digitsCharactersIndexes = characters.allIndexesWhere((e) => e.role == .digit);
    final charactersToRetire = digitsCharactersIndexes
        .sublist(rawCharacters.length)
        .map((index) => characters[index])
        .toList(growable: false);

    for (final character in charactersToRetire) {
      retireCharacter(character);
    }
  }

  void updateExistingDigits() {
    final components = DecimalComponents.fromMoney(widget.money);
    final rawCharacters = components.main.toString().split('');

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
    final components = DecimalComponents.fromMoney(widget.money);
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
    final components = DecimalComponents.fromMoney(widget.money);
    final formatted = AmountFormatter.formattedMain(components.main, separator);
    final needed = formatted.split('').where((e) => e == separator).length;

    final separators = characters.where((e) => e.role == .groupingSeparator).toList();

    final charactersToRetire = separators.sublist(0, separators.length - needed).toList(growable: false);

    for (final character in charactersToRetire) {
      retireCharacter(character);
    }
  }

  void rearrangeGroupingSeparators({required String separator}) {
    final components = DecimalComponents.fromMoney(widget.money);
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
    final components = DecimalComponents.fromDecimal(widget.money.amount);
    final show = components.fractional != 0 || widget.forceFractional;

    if (show) {
      final rawCharacters = components.fractional != 0 ? components.fractional.toString().split('') : <String>[];

      // if (!characters.any((e) => e.role == .decimalDigit)) {
      //   return;
      // }

      if (characters.none((e) => e.role == .decimalSeparator)) {
        characters.add(
          AnimatedCharacter(
            role: .decimalSeparator,
            character: separator,
            animationController: createAnimationController(animate: animated),
          ),
        );
      }

      Currency.getPrecision(widget.money.currencyCode);

      addPendingFractionalDigits(rawCharacters: rawCharacters, animated: animated);
      removeExcessFractionalDigits(rawCharacters: rawCharacters, animated: animated);
      updateExistingFractionalDigits(rawCharacters: rawCharacters, animated: animated);
      manageFractionalPlaceholders(rawCharacters: rawCharacters, animated: animated);

      // if (characters.any((e) => e.role == .fractionalDigit)) {
      //   return;
      // }

      // characters.add(
      //   AnimatedCharacter(
      //     role: .fractionalDigit,
      //     character: '0',
      //     animationController: createAnimationController(animate: animated),
      //   ),
      // );
      // characters.add(
      //   AnimatedCharacter(
      //     role: .fractionalDigit,
      //     character: '0',
      //     animationController: createAnimationController(animate: animated),
      //   ),
      // );
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
    final precision = Currency.getPrecision(widget.money.currencyCode);
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

    for (var i = 0; i < indexes.length - needed; i++) {
      retireCharacter(characters[indexes[i]]);
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

  AnimationController createAnimationController({required bool animate}) {
    final controller = AnimationController(vsync: this, duration: widget.animationDuration);
    if (animate) {
      controller.forward();
    } else {
      controller.value = 1;
    }

    return controller;
  }
}

enum AnimatedCharacterRole {
  digit,
  groupingSeparator,
  decimalSeparator,
  fractionalDigit,
  fractionalPlaceholder,
}

extension on AnimatedCharacterRole {
  bool get isPlaceholder => this == .fractionalPlaceholder;
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

class AnimatedCharacterWidget extends StatelessWidget {
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
      color: character.role == .fractionalPlaceholder ? placeholderColor : null,
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

extension _ListExtensions<T> on List<T> {
  List<int> allIndexesOf(T value) {
    final result = <int>[];
    for (var i = 0; i < length; i++) {
      if (this[i] == value) {
        result.add(i);
      }
    }

    return result;
  }

  List<int> allIndexesWhere(bool Function(T element) test) {
    final result = <int>[];
    for (var i = 0; i < length; i++) {
      if (test(this[i])) {
        result.add(i);
      }
    }

    return result;
  }

  int? lastIndexWhereOrNull(bool Function(T element) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) {
        return i;
      }
    }

    return null;
  }

  bool none(bool Function(T element) test) => !any(test);
}

final class BlinkingCursor extends StatelessWidget {
  final AnimationController controller;
  final TextStyle textStyle;
  final Color? color;

  const BlinkingCursor({
    super.key,
    required this.controller,
    required this.textStyle,
    this.color,
  });

  /// Implementation as per documentation of [TextField.cursorColor]
  Color _resolveEffectiveColor(BuildContext context) {
    final result = color ?? DefaultSelectionStyle.of(context).cursorColor;

    if (result != null) {
      return result;
    }

    if (Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS) {
      return CupertinoTheme.of(context).primaryColor;
    }

    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final weight = 2.0;

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
