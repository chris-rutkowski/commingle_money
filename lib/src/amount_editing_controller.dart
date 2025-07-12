import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'amount_format_separators.dart';
import 'utils/decimal_utils_internal.dart';
import 'utils/evaluate_math_text.dart';

part 'utils/format_decimal.dart';
part 'utils/unformat.dart';

/// Controller for amount text field with formatting and parsing capability
final class AmountEditingController extends ValueNotifier<Decimal?> {
  /// Separators for parsing and formatting the text field set during initialization.
  final AmountFormatSeparatorsData separators;

  /// Focus Node that should be given to the text field
  final focusNode = FocusNode();

  /// Text Editing Controller that should be given to the text field
  final textController = TextEditingController();

  int? _precision;

  /// Precision used in formatting and parsing the amount.
  int? get precision => _precision;

  /// Sets the precision for the amount and recalculates the value if necessary.
  set precision(int? newPrecision) {
    if (_precision == newPrecision) return;

    _precision = newPrecision;

    final rounded = value?.roundOptional(scale: newPrecision);
    if (value == rounded) {
      _format();
      return;
    }

    value = rounded;
  }

  @override
  set value(Decimal? newValue) {
    if (newValue == super.value) return;

    final rounded = newValue?.roundOptional(scale: precision);

    super.value = rounded;

    if (!focusNode.hasFocus) {
      _format();
    }
  }

  /// Creates an [AmountEditingController] with the given [amount] and [precision].
  AmountEditingController({this.separators = const AmountFormatSeparatorsData(), Decimal? amount, int? precision})
    : _precision = precision,
      super(amount?.roundOptional(scale: precision)) {
    focusNode.addListener(_onFocusNodeChange);

    _format();
    textController.addListener(_onTextControllerChange);
  }

  void _onFocusNodeChange() {
    _format();
  }

  void _format() {
    if (focusNode.hasFocus) {
      // if user is typing, we don't want to format the text
    } else {
      if (value != null) {
        textController.text = _formatDecimal(value!, separators: separators, precision: precision);
      } else {
        textController.text = '';
      }
    }
  }

  void _onTextControllerChange() {
    print('_onTextControllerChange');
    // TODO: check how often this is called and if some logic is needed and if external controller get side effects

    if (textController.text.trim().isEmpty) {
      value = null;
      return;
    }

    final unformatted = _unformat(textController.text, separators: separators);
    final evaluated = evaluateMathText(unformatted)?.roundOptional(scale: precision);

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
