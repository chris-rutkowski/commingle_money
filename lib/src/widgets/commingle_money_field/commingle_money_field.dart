import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/money_editing_controller.dart';
import '../../currency.dart';
import '../../money.dart';
import 'math_operator.dart';
import 'math_operator_dispatcher.dart';
import 'private/animated_appearance_wrapper.dart';
import 'private/animated_number_widget.dart';
import 'private/animated_operator_widget.dart';
import 'private/sentinel.dart';

// To improve:
// - AnimatedPositionedDirectional and overall RTL support
// - Support cut, copy and paste
// - Support for negative numbers

/// Money input field with very intuitive user input such as automatic grouping separators, fractional placeholders matching currency precision and reach animations.
/// When provided with [mathOperatorDispatcher] also supports basic arithmetic operations.
final class CommingleMoneyField extends StatefulWidget {
  /// Optional [Widget] to display before the field value, hidden during arithmetic operation.
  final Widget? prefix;

  /// Optional [Widget] to display after the field value, hidden during arithmetic operation.
  final Widget? suffix;

  /// Space between the numeric presentation and any visible prefix or suffix.
  final double affixesSpacing;

  /// The style to use for this field.
  /// This style overwrites [TextTheme.headlineLarge] from parent [Theme] or, if not present, the [DefaultTextStyle].
  final TextStyle? textStyle;

  /// Placeholder text to display when the field is empty.
  final String placeholder;

  /// Placeholder color to use when the field is empty or to differentiate arithmetic operation from its result.
  /// If not provided the [ThemeData.inputDecorationTheme]'s [InputDecorationThemeData.hintStyle]'s [TextStyle.color] is used, or Colors.grey if that is not defined.
  final Color? placeholderColor;

  /// Optional [MathOperatorDispatcher] for providing user input for arithmetic operations.
  final MathOperatorDispatcher? mathOperatorDispatcher;

  /// [MoneyEditingController] for setting and obtaining value of the field as user types.
  final MoneyEditingController controller;

  /// Optional [FocusNode] for managing focus of the field.
  final FocusNode? focusNode;

  /// Duration of animations when the value changes.
  final Duration animationDuration;

  /// Curve of animations when the value changes.
  final Curve curve;

  /// The type of action button to use for the keyboard, by default [TextInputAction.done].
  final TextInputAction textInputAction;

  /// Creates an [CommingleMoneyField] widget.
  const CommingleMoneyField({
    super.key,
    this.prefix,
    this.suffix,
    this.affixesSpacing = 0,
    this.textStyle,
    this.placeholder = '0',
    this.placeholderColor,
    this.mathOperatorDispatcher,
    required this.controller,
    this.focusNode,
    this.animationDuration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOut,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<CommingleMoneyField> createState() => _CommingleMoneyFieldState();
}

final class _CommingleMoneyFieldState extends State<CommingleMoneyField> {
  final inputController = TextEditingController.fromValue(sentinelValue);

  final fallbackFocusNode = FocusNode();
  FocusNode get effectiveFocusNode => widget.focusNode ?? fallbackFocusNode;

  MathOperator? activeOperator;

  var _operandA = '';
  String get operandA => _operandA;
  set operandA(String value) {
    if (value == _operandA) {
      return;
    }

    _operandA = value;

    if (value.isEmpty) {
      widget.controller.value = null;
    } else {
      widget.controller.value = Money(
        currencyCode: widget.controller.currencyCode,
        amount: Decimal.parse(value),
      );
    }
  }

  var _operandB = '';
  String get operandB => _operandB;
  set operandB(String value) {
    if (value == _operandB) {
      return;
    }
    _operandB = value;

    final evaluated = evaluate();

    if (evaluated != null) {
      widget.controller.value = evaluated;
    }
  }

  @override
  void initState() {
    super.initState();

    widget.mathOperatorDispatcher?.listener = onOperatorInput;
    effectiveFocusNode.addListener(handleFocusNodeChanged);
    widget.controller.addListener(handleControllerChanged);

    operandA = widget.controller.value?.amount.toString() ?? '';
  }

  @override
  void dispose() {
    widget.mathOperatorDispatcher?.listener = null;
    inputController.dispose();
    effectiveFocusNode.removeListener(handleFocusNodeChanged);
    fallbackFocusNode.dispose();
    widget.controller.removeListener(handleControllerChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CommingleMoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mathOperatorDispatcher != widget.mathOperatorDispatcher) {
      oldWidget.mathOperatorDispatcher?.listener = null;
      widget.mathOperatorDispatcher?.listener = onOperatorInput;
    }

    if (oldWidget.focusNode != widget.focusNode) {
      final oldFocusNode = oldWidget.focusNode ?? fallbackFocusNode;
      oldFocusNode.removeListener(handleFocusNodeChanged);
      effectiveFocusNode.addListener(handleFocusNodeChanged);
    }
  }

  void onOperatorInput(MathOperator operator) {
    if (operator != .equal && !effectiveFocusNode.hasFocus) {
      effectiveFocusNode.requestFocus();
    }

    if (operator == .equal && effectiveFocusNode.hasFocus) {
      effectiveFocusNode.unfocus();
      return;
    }

    final operatorADecimal = Decimal.tryParse(operandA);

    // ignoring operation if operandA is 0 or null
    if (operatorADecimal == null || operatorADecimal == Decimal.zero) {
      return;
    }

    setState(() {
      if (operator == .equal) {
        activeOperator = null;
        operandB = '';
        operandA = widget.controller.value?.amount.toString() ?? '';
      } else if (activeOperator != null) {
        activeOperator = operator;
        operandB = '';
        operandA = widget.controller.value?.amount.toString() ?? '';
      } else {
        activeOperator = operator;
      }
    });
  }

  void handleFocusNodeChanged() {
    setState(() {
      // setState always executed to trigger cursor appearance and other widgets

      if (!effectiveFocusNode.hasFocus) {
        activeOperator = null;
        operandB = '';
        operandA = widget.controller.value?.amount.toString() ?? '';
      }
    });
  }

  void handleControllerChanged() {
    var reset = false;

    final evaluated = evaluate()?.roundedToCurrencyPrecision();

    if (evaluated != null && widget.controller.value != evaluated) {
      reset = true;
    }

    if (evaluated == null && widget.controller.value?.amount != Decimal.tryParse(operandA)) {
      reset = true;
    }

    if (reset) {
      setState(() {
        operandA = widget.controller.value?.amount.toString() ?? '';
        activeOperator = null;
        operandB = '';
      });
    }
  }

  void onDecimalSignInput() {
    if (activeOperator != null) {
      if (!operandB.contains('.')) {
        setState(() {
          operandB = '${operandB.isEmpty ? '0' : operandB}.';
        });
      }

      return;
    }

    if (!operandA.contains('.')) {
      setState(() {
        operandA = '${operandA.isEmpty ? '0' : operandA}.';
      });
    }
  }

  void onBackspace() {
    if (operandB.isNotEmpty) {
      setState(() {
        operandB = operandB.substring(0, operandB.length - 1);
      });

      return;
    }

    if (activeOperator != null) {
      setState(() {
        activeOperator = null;
      });

      return;
    }

    if (operandA.isNotEmpty) {
      setState(() {
        operandA = operandA.substring(0, operandA.length - 1);
      });
    }
  }

  void onDigitInput(int digit) {
    if (activeOperator != null) {
      setState(() {
        if (operandB == '0') {
          operandB = '$digit';
        } else {
          operandB = '$operandB$digit';
        }
      });

      return;
    }

    if (operandA.contains('.')) {
      final precision = Currency.getPrecision(widget.controller.currencyCode);
      if (operandA.split('.').last.length >= precision) {
        return;
      }
    }

    setState(() {
      if (operandA == '0') {
        operandA = '$digit';
      } else {
        operandA = '$operandA$digit';
      }
    });
  }

  TextEditingValue handleInput(TextEditingValue previousValue, TextEditingValue nextValue) {
    final payload = nextValue.text.trim();

    if (payload.isEmpty) {
      onBackspace();
    } else if (payload.length == 1) {
      if (payload == '.' || payload == ',') {
        onDecimalSignInput();
      } else if (int.tryParse(payload) case final parsedDigit?) {
        onDigitInput(parsedDigit);
      } else {
        debugPrint('Unknown character `$payload`');
      }
    } else {
      // placeholder for pasted value
    }

    return sentinelValue;
  }

  Money? evaluate() {
    final operandADecimal = Decimal.tryParse(operandA);
    final operandBDecimal = Decimal.tryParse(operandB);

    if (operandADecimal == null || operandBDecimal == null) {
      return null;
    }

    final operandAMoney = Money(
      currencyCode: widget.controller.currencyCode,
      amount: operandADecimal,
    );

    switch (activeOperator) {
      case .plus:
        return operandAMoney + operandBDecimal;
      case .minus:
        // for going below zero simply sets the value to zero
        final result = operandAMoney - operandBDecimal;
        return result.amount >= Decimal.zero ? result : operandAMoney * Decimal.zero;
      case .multiply:
        return operandAMoney * operandBDecimal;
      case .divide:
        // for invalid operation simply sets the value to zero
        if (operandBDecimal != Decimal.zero) {
          return operandAMoney / operandBDecimal;
        } else {
          return operandAMoney * Decimal.zero;
        }
      case .equal:
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = resolveEffectiveTextStyle(context);
    final showAffixes = activeOperator == null;

    return Stack(
      children: [
        FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.prefix case final prefix?)
                AnimatedAppearanceWrapper(
                  visible: showAffixes,
                  duration: widget.animationDuration,
                  curve: widget.curve,
                  alignment: .centerLeft,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: widget.affixesSpacing,
                    ),
                    child: prefix,
                  ),
                ),

              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: effectiveFocusNode.requestFocus,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedNumberWidget(
                      text: operandA.isEmpty ? null : operandA,
                      textStyle: textStyle,
                      currencyCode: widget.controller.currencyCode,
                      showCursor: effectiveFocusNode.hasFocus && activeOperator == null,
                      animationDuration: widget.animationDuration,
                      curve: widget.curve,
                      placeholder: widget.placeholder,
                      placeholderColor: widget.placeholderColor,
                      styleTypeOverride: effectiveFocusNode.hasFocus
                          ? activeOperator != null
                                ? operandB.isEmpty
                                      ? .normal
                                      : .placeholder
                                : null
                          : .normal,
                    ),
                    AnimatedOperatorWidget(
                      operator: activeOperator,
                      textStyle: textStyle,
                      animationDuration: widget.animationDuration,
                      curve: widget.curve,
                      placeholderColor: widget.placeholderColor,
                      styleTypeOverride: operandB.isEmpty ? .normal : .placeholder,
                    ),
                    AnimatedNumberWidget(
                      text: operandB.isEmpty ? null : operandB,
                      textStyle: textStyle,
                      placeholder: '',
                      placeholderColor: widget.placeholderColor,
                      currencyCode: widget.controller.currencyCode,
                      showCursor: effectiveFocusNode.hasFocus && activeOperator != null,
                      animationDuration: widget.animationDuration,
                      curve: widget.curve,
                      styleTypeOverride: .placeholder,
                    ),
                    AnimatedOperatorWidget(
                      operator: operandB.isEmpty ? null : .equal,
                      textStyle: textStyle,
                      animationDuration: widget.animationDuration,
                      curve: widget.curve,
                      placeholderColor: widget.placeholderColor,
                      styleTypeOverride: operandB.isEmpty ? .placeholder : .normal,
                    ),
                    AnimatedNumberWidget(
                      text: operandB.isEmpty ? null : widget.controller.value?.amount.toString(),
                      textStyle: textStyle,
                      placeholder: '',
                      placeholderColor: widget.placeholderColor,
                      currencyCode: widget.controller.currencyCode,
                      animationDuration: widget.animationDuration,
                      curve: widget.curve,
                    ),
                  ],
                ),
              ),

              if (widget.suffix case final suffix?)
                AnimatedAppearanceWrapper(
                  visible: showAffixes,
                  duration: widget.animationDuration,
                  curve: widget.curve,
                  alignment: .centerRight,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: widget.affixesSpacing,
                    ),
                    child: suffix,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          width: 0,
          height: 0,
          child: TextField(
            controller: inputController,
            focusNode: effectiveFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: widget.textInputAction,
            enableInteractiveSelection: false,
            showCursor: false,
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: [TextInputFormatter.withFunction(handleInput)],
          ),
        ),
      ],
    );
  }

  TextStyle resolveEffectiveTextStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.headlineLarge ?? DefaultTextStyle.of(context).style;

    return base.merge(widget.textStyle);
  }
}
