import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'amount_editing_controller.dart';
import 'amount_format_separators.dart';
import 'currency.dart';
import 'currency_code.dart';
import 'money.dart';

final class MoneyEditingController extends ChangeNotifier {
  /// Focus Node that should be given to the text field
  FocusNode get focusNode => _amountController.focusNode;

  /// Text Editing Controller that should be given to the text field
  TextEditingController get textController => _amountController.textController;

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

  Money? get value {
    final amount = _amountController.value;
    if (amount == null) return null;

    return Money(
      amount: amount,
      currencyCode: _currencyCode,
    );
  }

  set value(Money? newValue) {
    if (newValue == null) {
      _amountController.value = null;
      return;
    }

    if (newValue.currencyCode != _currencyCode) {
      _currencyCode = newValue.currencyCode;
      _amountController.value = newValue.amount;
    }

    notifyListeners();
  }

  MoneyEditingController({
    required CurrencyCode currencyCode,
    Decimal? amount,
    AmountFormatSeparators separators = const AmountFormatSeparators(),
  }) : _currencyCode = currencyCode,
       _amountController = AmountEditingController(
         amount: amount,
         precision: Currency.fromCode(currencyCode)?.precision,
         separators: separators,
       ) {
    _amountController.addListener(_onAmountChanged);
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
