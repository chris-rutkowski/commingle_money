import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../commingle_money.dart';

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

  TextEditingValue _handleRawInput(TextEditingValue previousValue, TextEditingValue nextValue) {
    final payload = nextValue.text.trim();

    if (payload.isEmpty) {
      // backspace
      if (widget.controller.value == null) {
        return _sentinelValue;
      }

      if (widget.controller.value!.amount == Decimal.zero) {
        widget.controller.value = null;
        return _sentinelValue;
      }

      widget.controller.value = widget.controller.value! ~/ 10;
    } else if (payload.length == 1) {
      if (payload == '.' || payload == ',') {
        debugPrint('decimal sign');
      } else if (int.tryParse(payload) case final parsedDigit?) {
        final decimalDigit = Decimal.fromInt(parsedDigit);
        if (widget.controller.value == null) {
          widget.controller.value = Money(currencyCode: widget.currencyCode, amount: decimalDigit);
        } else {
          widget.controller.value = widget.controller.value! * Decimal.ten + decimalDigit;
        }
      } else {
        debugPrint('Unknown character `$payload`');
      }
      // if number than number, otherwise decimal separator
    } else {
      // paste value - replace the whole value if possible
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

                      // forceFractional: true,
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
