import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../amount_format_separators.dart';
import 'amount_editing_state.dart';
import 'private/amount_editing_state_private.dart';
import 'private/decimal_utils_private.dart';
import 'private/evaluate_math_text.dart';
import 'private/format_decimal.dart';
import 'private/unformat.dart';

/// Controller for plain amount text field with formatting and parsing capability
final class AmountEditingController extends ValueNotifier<Decimal?> {
  /// Separators for parsing and formatting the text field set during initialization.
  final AmountFormatSeparatorsData separators;

  /// Focus Node that should be given to the text field
  final focusNode = FocusNode();

  /// Text Editing Controller that should be given to the text field
  final textController = TextEditingController();

  /// A notifier that reflects the current semantic state of the user's input.
  final ValueNotifier<AmountEditingState> state;

  int? _precision;

  /// Precision used in formatting and parsing the amount.
  int? get precision => _precision;

  /// Current value or [Decimal.zero] if `null`.
  Decimal get valueOrZero => value ?? Decimal.zero;

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
    state.value = AmountEditingStatePrivate.fromValue(rounded);

    if (!focusNode.hasFocus) {
      _format();
    }
  }

  /// Creates an [AmountEditingController] with the given [amount] and [precision].
  AmountEditingController({this.separators = const AmountFormatSeparatorsData(), Decimal? amount, int? precision})
    : state = ValueNotifier(AmountEditingStatePrivate.fromValue(amount)),
      _precision = precision,
      super(amount?.roundOptional(scale: precision)) {
    focusNode.addListener(_onFocusNodeChange);

    _format();
    textController.addListener(_onTextControllerChange);
  }

  /// Creates an [AmountEditingController] using separators from the [AmountFormatSeparators] inherited widget, if available.
  factory AmountEditingController.context({
    required BuildContext context,
    Decimal? amount,
    int? precision,
  }) {
    return AmountEditingController(
      separators: AmountFormatSeparators.maybeOf(context) ?? const AmountFormatSeparatorsData(),
      amount: amount,
      precision: precision,
    );
  }

  void _onFocusNodeChange() {
    _format();
  }

  void _format() {
    if (focusNode.hasFocus) {
      // if user is typing, we don't want to format the text
    } else {
      if (value != null) {
        textController.text = formatDecimal(value!, separators: separators, precision: precision);
      } else {
        textController.text = '';
      }
    }
  }

  void _onTextControllerChange() {
    if (textController.text.trim().isEmpty) {
      value = null;
      return;
    }

    final unformatted = unformat(textController.text, separators: separators);
    final evaluated = evaluateMathText(unformatted)?.roundOptional(scale: precision);

    if (evaluated != null) {
      value = evaluated;
      state.value = AmountEditingStatePrivate.fromValue(evaluated);
    } else {
      state.value = AmountEditingState.error;
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    textController.dispose();
    state.dispose();
    super.dispose();
  }
}
