// ignore_for_file: public_member_api_docs // TEMP

import 'package:flutter/material.dart';

import '../../commingle_money.dart';
import '../private/amount_formatter.dart';
import '../private/decimal_components.dart';

final class AnimatedMoneyLabel extends StatefulWidget {
  final Money money;
  final Duration animationDuration;
  final Curve curve;
  final AmountFormatSeparatorsData? separators;
  final bool forceFractional;

  const AnimatedMoneyLabel({
    super.key,
    required this.money,
    this.animationDuration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOut,
    this.separators,
    this.forceFractional = false,
  });

  @override
  State<AnimatedMoneyLabel> createState() => _AnimatedMoneyLabelState();
}

final class _AnimatedMoneyLabelState extends State<AnimatedMoneyLabel> with TickerProviderStateMixin {
  final characters = <AnimatedCharacter>[];
  final retiredCharacters = <AnimatedCharacter>[];

  @override
  Widget build(BuildContext context) {
    // final characters = widget.money.abs().toString().split('');

    final base =
        // MoneyPresentationDefaults.maybeOf(context)?.primaryTextStyle ??
        Theme.of(context).textTheme.headlineLarge!; // ??
    // DefaultTextStyle.of(context).style;

    final textStyle = base.merge(const TextStyle(fontWeight: FontWeight.bold));

    TextPainter(
      text: TextSpan(text: widget.money.toString(), style: textStyle),
      textDirection: TextDirection.ltr,
    ).layout();

    final children = <Widget>[];

    var leading = 0.0;
    var width = 0.0;

    for (final character in characters) {
      final painter = TextPainter(
        text: TextSpan(text: character.character, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      children.add(
        AnimatedPositioned(
          // TODO: animated positioned directional
          key: character.key,
          duration: widget.animationDuration,
          curve: widget.curve,
          top: 0,
          left: leading,
          child: ListenableBuilder(
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

                // scale: bounce.value,
                child: Opacity(
                  opacity: character.animationController.value,
                  child: Text(
                    character.character,
                    style: textStyle,
                  ),
                ),
              );
            },
          ),
        ),
      );

      character.retiredLeading = leading;
      leading += painter.width;
      width += painter.width;
    }

    for (final character in retiredCharacters) {
      children.add(
        AnimatedPositioned(
          // TODO: animated positioned directional
          key: character.key,
          duration: widget.animationDuration,
          curve: widget.curve,
          top: 0,
          left: character.retiredLeading,
          child: ListenableBuilder(
            listenable: character.animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: character.animationController.value,

                // scale: bounce.value,
                child: Opacity(
                  opacity: character.animationController.value,
                  child: Text(
                    character.character,
                    style: textStyle,
                  ),
                ),
              );
            },
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
        clipBehavior: Clip.none, // for cursor
        children: [
          ...children,
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
    );
  }

  @override
  void initState() {
    super.initState();
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

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final effectiveSeparators = _resolveEffectiveSeparators(context);

    // addPendingDigitsAnimated();
    // addPendingGroupingSeparatorAnimated(needed: desiredGroupingIndexes.length, separator: effectiveSeparators.grouping);
    // removeExcessGroupingSeparatorsAnimated(needed: desiredGroupingIndexes.length);
    // rearrangeGroupingSeparators(indexes: desiredGroupingIndexes);
    // manageFractional(separator: effectiveSeparators.decimal);

    addPendingDigits(animated: false);
    addPendingGroupingSeparator(animated: false, separator: effectiveSeparators.grouping);
    rearrangeGroupingSeparators(separator: effectiveSeparators.grouping);
    manageFractional(animated: false, separator: effectiveSeparators.decimal);

    // final initialCharacters = widget.money.amount.abs().toString().split('');
    // final effectiveSeparators = _resolveEffectiveSeparators(context);

    // for (final character in initialCharacters) {
    //   final animationController = AnimationController(vsync: this, duration: widget.animationDuration, value: 1);
    //   characters.add(
    //     AnimatedCharacter(
    //       role: .digit,
    //       character: character,
    //       animationController: animationController,
    //     ),
    //   );
    // }

    // final components = DecimalComponents.fromMoney(widget.money);

    // final formatted = AmountFormatter.formattedMain(components.main, effectiveSeparators.grouping);
    // final desiredGroupingIndexes = formatted.split('').allIndexesOf(effectiveSeparators.grouping);
    // for (var i = 0; i < desiredGroupingIndexes.length; i++) {
    //   characters.insert(
    //     desiredGroupingIndexes[i],
    //     AnimatedCharacter(
    //       role: .groupingSeparator,
    //       character: effectiveSeparators.grouping,
    //       animationController: AnimationController(vsync: this, duration: widget.animationDuration, value: 1),
    //     ),
    //   );
    // }
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

    for (var i = digitsCharactersLength; i < rawCharacters.length; i++) {
      characters.add(
        AnimatedCharacter(
          role: .digit,
          character: rawCharacters[i],
          animationController: createAnimationController(animate: animated),
        ),
      );
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
    final components = DecimalComponents.fromMoney(widget.money);
    final show = components.fractional != 0 || widget.forceFractional;

    if (show) {
      if (characters.any((e) => e.role == .decimalSeparator)) {
        return;
      }

      characters.add(
        AnimatedCharacter(
          role: .decimalSeparator,
          character: separator,
          animationController: createAnimationController(animate: animated),
        ),
      );
      characters.add(
        AnimatedCharacter(
          role: .decimalDigit,
          character: '0',
          animationController: createAnimationController(animate: animated),
        ),
      );
      characters.add(
        AnimatedCharacter(
          role: .decimalDigit,
          character: '0',
          animationController: createAnimationController(animate: animated),
        ),
      );
    } else {
      characters
          .where((e) => e.role == .decimalSeparator || e.role == .decimalDigit)
          .toList(growable: false)
          .forEach(retireCharacter);
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
  decimalDigit,
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
}

final class PositionedAnimatedCharacter {
  final AnimatedCharacter animatedCharacter;
  final double leading;

  const PositionedAnimatedCharacter({
    required this.animatedCharacter,
    required this.leading,
  });
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
}
