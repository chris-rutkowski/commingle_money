import 'package:amount_editing_controller/src/utils/decimal_utils.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'amount_format_separators.dart';
import 'utils/evaluate_math_text.dart';

part 'utils/format_decimal.dart';
part 'utils/unformat.dart';

/// Controller for amount text field with formatting and parsing capability
final class AmountEditingController extends ValueNotifier<Decimal?> {
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
  set value(Decimal? newValue) {
    if (newValue == super.value) return;

    final rounded = newValue?.roundOptional(scale: fractionalDigits);

    super.value = rounded;

    if (!focusNode.hasFocus) {
      _format();
    }
  }

  /// Creates an [AmountEditingController] with the given [amount] and [fractionalDigits].
  AmountEditingController({this.separators = const AmountFormatSeparators(), Decimal? amount, int? fractionalDigits})
    : _fractionalDigits = fractionalDigits,
      super(amount?.roundOptional(scale: fractionalDigits)) {
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
      // if user is typing, we don't want to format the text
    } else {
      if (value != null) {
        textController.text = _formatDecimal(value!, separators: separators, fractionalDigits: fractionalDigits);
      } else {
        textController.text = '';
      }
    }
  }

  void _onTextControllerChange() {
    // TODO: check how often this is called and if some logic is needed and if external controller get side effects

    if (textController.text.trim().isEmpty) {
      value = null;
      return;
    }

    final unformatted = _unformat(textController.text, separators: separators);
    final evaluated = evaluateMathText(unformatted)?.roundOptional(scale: fractionalDigits);

    if (evaluated != null && evaluated != value) {
      value = evaluated;
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    textController.dispose();
    super.dispose();
  }
}
