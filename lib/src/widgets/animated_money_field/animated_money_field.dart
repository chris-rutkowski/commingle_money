import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../commingle_money.dart';

// ignore_for_file: public_member_api_docs TODO TO document

const _sentinel = ' ';
const _sentinelValue = TextEditingValue(
  text: _sentinel,
  selection: TextSelection.collapsed(offset: _sentinel.length),
);

final class AnimatedMoneyField extends StatefulWidget {
  final Widget? prefix;
  final Widget? suffix;

  /// Operation controller for handling arithmetic operations.
  final AwesomeMoneyFieldMathController? operationController;
  final MoneyEditingController moneyController;
  final FocusNode focusNode;

  const AnimatedMoneyField({
    super.key,
    this.prefix,
    this.suffix,
    this.operationController,
    required this.moneyController,
    required this.focusNode,
  });

  @override
  State<AnimatedMoneyField> createState() => _AnimatedMoneyFieldState();
}

final class _AnimatedMoneyFieldState extends State<AnimatedMoneyField> {
  late final TextEditingController inputController;
  AwesomeMoneyFieldButton? activeButton;

  var _stringNumber = '';
  String get stringNumber => _stringNumber;
  set stringNumber(String value) {
    if (value == _stringNumber) {
      return;
    }

    _stringNumber = value;

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
    inputController = TextEditingController.fromValue(_sentinelValue);

    widget.operationController?.listener = onOperationInput;
    widget.focusNode.addListener(_handleFocusNodeChanged);
    widget.moneyController.addListener(_handleControllerChanged);

    stringNumber = widget.moneyController.value?.amount.toString() ?? '';
  }

  void onOperationInput(AwesomeMoneyFieldButton button) {
    if (activeButton == button) {
      return;
    }

    if (button != AwesomeMoneyFieldButton.equal) {
      activeButton = button;
    } else {
      activeButton = null;
    }
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
    if (widget.moneyController.value?.amount != Decimal.tryParse(stringNumber)) {
      stringNumber = widget.moneyController.value?.amount.toString() ?? '';
    }
  }

  void _onDecimalSignInput() {
    if (stringNumber.contains('.')) {
      return;
    }

    setState(() {
      stringNumber = '${stringNumber.isEmpty ? '0' : stringNumber}.';
    });
  }

  void _onBackspace() {
    setState(() {
      stringNumber = stringNumber.isNotEmpty ? stringNumber.substring(0, stringNumber.length - 1) : '';
    });
  }

  void _onDigitInput(int digit) {
    if (stringNumber.contains('.')) {
      final precision = Currency.getPrecision(widget.moneyController.currencyCode);
      if (stringNumber.split('.').last.length >= precision) {
        return;
      }
    }

    setState(() {
      if (stringNumber == '0') {
        stringNumber = '$digit';
      } else {
        stringNumber = '$stringNumber$digit';
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

    return _sentinelValue;
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
                    AnimatedMoneyLabel(
                      stringNumber: stringNumber.isEmpty ? null : stringNumber,
                      currencyCode: widget.moneyController.currencyCode,
                      showCursor: widget.focusNode.hasFocus,
                    ),
                    AnimatedMoneyLabel(
                      stringNumber: '', // '+'
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
