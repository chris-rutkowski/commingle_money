import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../commingle_money.dart';
import 'private/awesome_digits_widget.dart';
import 'private/awesome_operator_widget.dart';
import 'private/utils.dart';

// To improve:
// - AnimatedPositionedDirectional for RTL

/// Money input field with very intuitive user input such as automatic grouping separators, fractional placeholders and reach animations.
/// When provided with [operationController] also supports basic arithmetic operations.
final class AwesomeMoneyField extends StatefulWidget {
  /// Optional [Widget] to display before the field value, hidden during arithmetic operation.
  final Widget? prefix;

  /// Optional [Widget] to display after the field value, hidden during arithmetic operation.
  final Widget? suffix;

  /// Optional [AwesomeMoneyFieldMathController] for providing arithmetic operations requests
  final AwesomeMoneyFieldMathController? operationController;

  /// [MoneyEditingController] for setting and obtaining value of the field as user types.
  final MoneyEditingController moneyController;

  /// [FocusNode] for managing focus of the field.
  final FocusNode focusNode;

  /// Creates an [AwesomeMoneyField] widget.
  const AwesomeMoneyField({
    super.key,
    this.prefix,
    this.suffix,
    this.operationController,
    required this.moneyController,
    required this.focusNode,
  });

  @override
  State<AwesomeMoneyField> createState() => _AwesomeMoneyFieldState();
}

final class _AwesomeMoneyFieldState extends State<AwesomeMoneyField> {
  late final TextEditingController inputController;
  AwesomeMoneyFieldButton? activeButton;

  var _operandA = '';
  String get operandA => _operandA;
  set operandA(String value) {
    if (value == _operandA) {
      return;
    }

    _operandA = value;

    if (value.isEmpty) {
      widget.moneyController.value = null;
    } else {
      widget.moneyController.value = Money(
        currencyCode: widget.moneyController.currencyCode,
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
      widget.moneyController.value = evaluated;
    }
  }

  @override
  void initState() {
    super.initState();
    inputController = TextEditingController.fromValue(sentinelValue);

    widget.operationController?.listener = onOperationInput;
    widget.focusNode.addListener(_handleFocusNodeChanged);
    widget.moneyController.addListener(_handleControllerChanged);

    operandA = widget.moneyController.value?.amount.toString() ?? '';
  }

  void onOperationInput(AwesomeMoneyFieldButton button) {
    if (button != .equal && !widget.focusNode.hasFocus) {
      widget.focusNode.requestFocus();
    }

    if (button == .equal && widget.focusNode.hasFocus) {
      widget.focusNode.unfocus();
    }

    final operatorADecimal = Decimal.tryParse(operandA);

    // ignoring operation if operandA is 0 or null
    if (operatorADecimal == null || operatorADecimal == Decimal.zero) {
      return;
    }

    setState(() {
      if (button == AwesomeMoneyFieldButton.equal) {
        activeButton = null;
        operandB = '';
        operandA = widget.moneyController.value?.amount.toString() ?? '';
      } else if (activeButton != null) {
        activeButton = button;
        operandB = '';
        operandA = widget.moneyController.value?.amount.toString() ?? '';
      } else {
        activeButton = button;
      }
    });
  }

  @override
  void dispose() {
    inputController.dispose();
    widget.focusNode.removeListener(_handleFocusNodeChanged);
    widget.moneyController.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleFocusNodeChanged() {
    setState(() {
      // setState always executed to update cursor and other widgets

      if (!widget.focusNode.hasFocus) {
        activeButton = null;
        operandB = '';
        operandA = widget.moneyController.value?.amount.toString() ?? '';
      }
    });
  }

  void _handleControllerChanged() {
    var reset = false;

    final evaluated = evaluate()?.roundedToCurrencyPrecision();

    if (evaluated != null && widget.moneyController.value != evaluated) {
      reset = true;
    }

    if (evaluated == null && widget.moneyController.value?.amount != Decimal.tryParse(operandA)) {
      reset = true;
    }

    if (reset) {
      setState(() {
        operandA = widget.moneyController.value?.amount.toString() ?? '';
        activeButton = null;
        operandB = '';
      });
    }
  }

  void _onDecimalSignInput() {
    if (activeButton != null) {
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

  void _onBackspace() {
    if (operandB.isNotEmpty) {
      setState(() {
        operandB = operandB.substring(0, operandB.length - 1);
      });

      return;
    }

    if (activeButton != null) {
      setState(() {
        activeButton = null;
      });

      return;
    }

    if (operandA.isNotEmpty) {
      setState(() {
        operandA = operandA.substring(0, operandA.length - 1);
      });
    }
  }

  void _onDigitInput(int digit) {
    if (activeButton != null) {
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
      final precision = Currency.getPrecision(widget.moneyController.currencyCode);
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
      _onBackspace();
    } else if (payload.length == 1) {
      if (payload == '.' || payload == ',') {
        _onDecimalSignInput();
      } else if (int.tryParse(payload) case final parsedDigit?) {
        _onDigitInput(parsedDigit);
      } else {
        debugPrint('Unknown character `$payload`');
      }
    } else {
      // TODO: pasted value - replace the whole value if possible
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
      currencyCode: widget.moneyController.currencyCode,
      amount: operandADecimal,
    );

    switch (activeButton) {
      case .plus:
        return operandAMoney + operandBDecimal;
      case .minus:
        final result = operandAMoney - operandBDecimal;
        return result.amount >= Decimal.zero ? result : operandAMoney * Decimal.zero;
      case .multiply:
        return operandAMoney * operandBDecimal;
      case .divide:
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.focusNode.requestFocus,
      child: Stack(
        children: [
          FittedBox(
            child: ListenableBuilder(
              // TODO: not sure if it needs to listen
              listenable: widget.moneyController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ?widget.prefix,
                    AwesomeDigitsWidget(
                      text: operandA.isEmpty ? null : operandA,
                      currencyCode: widget.moneyController.currencyCode,
                      showCursor: widget.focusNode.hasFocus && activeButton == null,
                      styleOverride: activeButton != null
                          ? operandB.isEmpty
                                ? .normal
                                : .placeholder
                          : null,
                    ),
                    AwesomeOperatorWidget(
                      operator: activeButton,
                      styleOverride: operandB.isEmpty ? .normal : .placeholder,
                    ),
                    AwesomeDigitsWidget(
                      text: operandB.isEmpty ? null : operandB,
                      placeholder: '',
                      currencyCode: widget.moneyController.currencyCode,
                      showCursor: widget.focusNode.hasFocus && activeButton != null,
                      styleOverride: .placeholder,
                    ),
                    AwesomeOperatorWidget(
                      operator: operandB.isEmpty ? null : .equal,
                      styleOverride: operandB.isEmpty ? .placeholder : .normal,
                    ),
                    AwesomeDigitsWidget(
                      text: operandB.isEmpty ? null : widget.moneyController.value?.amount.toString(),
                      placeholder: '',
                      currencyCode: widget.moneyController.currencyCode,
                    ),
                    ?widget.suffix,
                  ],
                );
              },
            ),
          ),
          SizedBox(
            width: 0,
            height: 0,
            child: TextField(
              controller: inputController,
              focusNode: widget.focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done, // TODO: configurable and callback
              enableInteractiveSelection: false,
              showCursor: false,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: [TextInputFormatter.withFunction(handleInput)],
            ),
          ),
        ],
      ),
    );
  }
}
