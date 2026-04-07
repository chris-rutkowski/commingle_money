import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../commingle_money.dart';
import 'private/awesome_digits_widget.dart';
import 'private/awesome_operator_widget.dart';
import 'private/utils.dart';

// To improve:
// - AnimatedPositionedDirectional for RTL

// ignore_for_file: public_member_api_docs TODO TO document

final class AwesomeMoneyField extends StatefulWidget {
  final Widget? prefix;
  final Widget? suffix;

  /// Operation controller for handling arithmetic operations.
  final AwesomeMoneyFieldMathController? operationController;
  final MoneyEditingController moneyController;
  final FocusNode focusNode;

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
    if (activeButton == button) {
      return;
    }

    setState(() {
      if (button != AwesomeMoneyFieldButton.equal) {
        activeButton = button;
      } else {
        activeButton = null;
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
    setState(() {});
  }

  void _handleControllerChanged() {
    if (widget.moneyController.value?.amount != Decimal.tryParse(operandA)) {
      operandA = widget.moneyController.value?.amount.toString() ?? '';
    }
  }

  void _onDecimalSignInput() {
    if (operandA.contains('.')) {
      return;
    }

    setState(() {
      operandA = '${operandA.isEmpty ? '0' : operandA}.';
    });
  }

  void _onBackspace() {
    setState(() {
      operandA = operandA.isNotEmpty ? operandA.substring(0, operandA.length - 1) : '';
    });
  }

  void _onDigitInput(int digit) {
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

    return;
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
                      showCursor: widget.focusNode.hasFocus,
                    ),
                    AwesomeOperatorWidget(
                      operator: activeButton,
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
