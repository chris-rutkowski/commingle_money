import 'package:decimal/decimal.dart';
import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';

import 'amount_format_separators.dart';

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
      // if user is typing, we don't want to format the text
    } else {
      if (value != null) {
        textController.text = _formatDecimal(value!, separators: separators);
      } else {
        textController.text = '';
      }
    }
  }

  void _onTextControllerChange() {
    // TODO: check how often this is called and if some logic is needed and if external controller get side effects
    final validOperators = [
      RegExp.escape(StringMath.plusSign),
      RegExp.escape(StringMath.minusSign),
      RegExp.escape(StringMath.multiplicationSign),
      RegExp.escape(StringMath.divisionSign),
      RegExp.escape('*'),
      RegExp.escape('-'),
    ];

    final processed = _unformat(textController.text, separators: separators)
        .replaceAll(RegExp(r'^[\s.,]+|[\s.,]+$'), '')
        .replaceAll(RegExp('(${validOperators.join('|')})+\$'), '')
        .replaceAll(StringMath.plusSign, '+')
        .replaceAll(StringMath.multiplicationSign, '*')
        .replaceAll(StringMath.minusSign, '-')
        .replaceAll(StringMath.divisionSign, '/')
        // adds `*` before `(` if there is a number before `(`
        .replaceAllMapped(RegExp(r'(\d)\s*\('), (match) => '${match[1]}*(')
        // adds * after `(` if there is a `)` before `(`
        .replaceAllMapped(RegExp(r'\)\s*\('), (_) => ')*(');

    if (processed.isEmpty) {
      value = null;
      return;
    }

    final evaluated = _DecimalUtils.tryParseMathExpression(processed);

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

extension StringMath on String {
  static const String plusSign = '+';
  static const String minusSign = '‒';
  static const String multiplicationSign = '×';
  static const String divisionSign = '÷';
}

extension _DecimalUtils on Decimal {
  static Decimal fromDouble(double value) => Decimal.parse(value.toString());

  static Decimal? tryParseMathExpression(String expression) {
    const evaluator = ExpressionEvaluator();

    try {
      final parsed = Expression.parse(expression);
      final result = evaluator.eval(parsed, {});

      if (result is int) {
        return Decimal.fromInt(result);
      }

      if (result is double) {
        return _DecimalUtils.fromDouble(result);
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
