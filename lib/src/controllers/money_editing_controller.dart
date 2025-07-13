import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../amount_format_separators.dart';
import '../currency.dart';
import '../currency_code.dart';
import '../money.dart';
import 'amount_editing_controller.dart';
import 'amount_editing_state.dart';

/// Controller for [Money] text field with formatting and parsing capability
final class MoneyEditingController extends ChangeNotifier {
  /// Focus Node that should be given to the text field
  FocusNode get focusNode => _amountController.focusNode;

  /// Text Editing Controller that should be given to the text field
  TextEditingController get textController => _amountController.textController;

  /// A notifier that reflects the current semantic state of the user's input.
  ValueNotifier<AmountEditingState> get state => _amountController.state;

  final AmountEditingController _amountController;

  CurrencyCode _currencyCode;

  /// The current currency associated with the controller.
  CurrencyCode get currencyCode => _currencyCode;

  /// Sets the currency and rebuilds the Money value.
  set currencyCode(CurrencyCode newCurrencyCode) {
    if (_currencyCode == newCurrencyCode) return;
    _currencyCode = newCurrencyCode;
    _amountController.precision = Currency.fromCode(newCurrencyCode)?.precision;
    notifyListeners();
  }

  /// The current value of the controller as a [Money] object.
  Money? get value {
    final amount = _amountController.value;
    if (amount == null) return null;

    return Money(
      amount: amount,
      currencyCode: _currencyCode,
    );
  }

  /// Programmatically sets the value of the controller.
  set value(Money? newValue) {
    if (newValue == null) {
      _amountController.value = null;
      return;
    }

    _currencyCode = newValue.currencyCode;
    _amountController.value = newValue.amount;
  }

  /// Creates an [MoneyEditingController] instance.
  MoneyEditingController({
    required CurrencyCode currencyCode,
    Decimal? amount,
    AmountFormatSeparatorsData separators = const AmountFormatSeparatorsData(),
  }) : _currencyCode = currencyCode,
       _amountController = AmountEditingController(
         amount: amount,
         precision: Currency.fromCode(currencyCode)?.precision,
         separators: separators,
       ) {
    _amountController.addListener(_onAmountChanged);
  }

  /// Creates a [MoneyEditingController] using separators from the [AmountFormatSeparators] inherited widget, if available.
  factory MoneyEditingController.context({
    required BuildContext context,
    required CurrencyCode currencyCode,
    Decimal? amount,
  }) {
    return MoneyEditingController(
      currencyCode: currencyCode,
      amount: amount,
      separators: AmountFormatSeparators.maybeOf(context) ?? const AmountFormatSeparatorsData(),
    );
  }

  void _onAmountChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
