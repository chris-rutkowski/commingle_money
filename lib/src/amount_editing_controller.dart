import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'amount_format_separators.dart';

part 'utils/format_decimal.dart';
part 'utils/unformat.dart';

/// Controller for amount text field with formatting and parsing capability
final class AmountEditingController extends ValueNotifier<Decimal> {
  /// Separators for parsing and formatting the text field set during initialization.
  final AmountFormatSeparators separators;

  /// Focus Node that should be given to the text field
  final focusNode = FocusNode();

  /// Text Editing Controller that should be given to the text field
  final textController = TextEditingController();

  var _hadFocus = false; // TODO: do we need this

  int? _fractionalDigits;

  set fractionalDigits(int? value) {
    if (_fractionalDigits == value) return;
    _fractionalDigits = value;
  }

  int? get fractionalDigits => _fractionalDigits;

  @override
  set value(Decimal newValue) {
    if (newValue == super.value) return;

    super.value = newValue;

    if (!focusNode.hasFocus) {
      _format();
    }
  }

  /// Creates an [AmountEditingController] with the given [amount] and [fractionalDigits].
  AmountEditingController({this.separators = const AmountFormatSeparators(), Decimal? amount, int? fractionalDigits})
    : _fractionalDigits = fractionalDigits,
      super(amount ?? Decimal.zero) {
    focusNode.addListener(_onFocusNodeChange);

    if (amount != null) {
      // textController.text = options.format(amount, fractionalDigits: fractionalDigits);
    }

    textController.addListener(_onTextControllerChange);
  }

  void _onFocusNodeChange() {
    if (focusNode.hasFocus == _hadFocus) return;
    _hadFocus = focusNode.hasFocus;

    _format();
  }

  void _format() {
    if (focusNode.hasFocus) {
      // textController.text = options.clear(textController.text);
    } else {
      textController.text = _formatDecimal(value, separators: separators);
      // textController.text = options.format(value, fractionalDigits: fractionalDigits);
    }
  }

  void _onTextControllerChange() {
    // final validOperators = [
    //   RegExp.escape(StringMath.plusSign),
    //   RegExp.escape(StringMath.minusSign),
    //   RegExp.escape(StringMath.multiplicationSign),
    //   RegExp.escape(StringMath.divisionSign),
    //   RegExp.escape('*'),
    //   RegExp.escape('-'),
    // ];

    // final processed = controller.text
    //     .replaceAll(RegExp(r'^[\s.,]+|[\s.,]+$'), '')
    //     .replaceAll(RegExp('(${validOperators.join('|')})+\$'), '')
    //     .replaceAll(StringMath.plusSign, '+')
    //     .replaceAll(StringMath.multiplicationSign, '*')
    //     .replaceAll(StringMath.minusSign, '-')
    //     .replaceAll(StringMath.divisionSign, '/');

    // final newValue = options.toDecimal(textController.text);

    // if (value == newValue) return;

    // value = newValue;

    final lol = Decimal.tryParse(_unformat(textController.text, separators: separators));

    if (lol != null && lol != value) {
      value = lol;
    }

    // todo edge case for empty input
  }

  @override
  void dispose() {
    focusNode.dispose();
    textController.dispose();
    super.dispose();
  }
}
