import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../commingle_money.dart';
import '../../private/decimal_components.dart';

final class AnimatedMoneyField extends StatefulWidget {
  final MoneyEditingController controller;
  final FocusNode focusNode;
  final CurrencyCode currencyCode;

  const AnimatedMoneyField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.currencyCode,
  });

  @override
  State<AnimatedMoneyField> createState() => _AnimatedMoneyFieldState();
}

const _sentinel = ' ';

final class _AnimatedMoneyFieldState extends State<AnimatedMoneyField> {
  late final TextEditingController _inputController;
  var forceAmountFractional = false;

  TextEditingValue get _sentinelValue => const TextEditingValue(
    text: _sentinel,
    selection: TextSelection.collapsed(offset: _sentinel.length),
  );

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController.fromValue(_sentinelValue);

    widget.focusNode.addListener(_handleFocusNodeChanged);
  }

  @override
  void dispose() {
    _inputController.dispose();
    widget.focusNode.removeListener(_handleFocusNodeChanged);
    super.dispose();
  }

  void _handleFocusNodeChanged() {
    setState(() {});
  }

  void _onDecimalSignInput() {
    if (forceAmountFractional) {
      return;
    }

    setState(() {
      forceAmountFractional = true;
    });
  }

  void _onBackspace() {
    if (widget.controller.value == null) {
      return;
    }

    if (widget.controller.value!.amount == Decimal.zero) {
      widget.controller.value = null;
      return;
    }

    // clears decimal separator if fractional part is already empty
    final components = DecimalComponents.fromMoney(widget.controller.value!);
    if (components.fractional == 0 && forceAmountFractional) {
      setState(() {
        forceAmountFractional = false;
      });
      return;
    }

    widget.controller.value = widget.controller.value! ~/ 10;
  }

  void _onDigitInput(int digit) {
    final decimalDigit = Decimal.fromInt(digit);
    if (widget.controller.value == null) {
      widget.controller.value = Money(currencyCode: widget.currencyCode, amount: decimalDigit);
      return;
    }

    widget.controller.value = widget.controller.value! * Decimal.ten + decimalDigit;
  }

  TextEditingValue _handleRawInput(TextEditingValue previousValue, TextEditingValue nextValue) {
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
      onTap: () => widget.focusNode.requestFocus(),
      child: Stack(
        children: [
          FittedBox(
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedMoneyLabel(
                      money: widget.controller.value,
                      forceFractional: forceAmountFractional,
                      showCursor: widget.focusNode.hasFocus,
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: _inputController,
              focusNode: widget.focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done, // TODO: configurable and callback
              onSubmitted: (_) {}, // TODO: configurable callback
              enableInteractiveSelection: false,
              showCursor: false,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: [TextInputFormatter.withFunction(_handleRawInput)],
            ),
          ),
        ],
      ),
    );
  }
}
