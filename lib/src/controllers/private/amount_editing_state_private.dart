// ignore_for_file: public_member_api_docs

import 'package:decimal/decimal.dart';

import '../amount_editing_state.dart';

extension AmountEditingStatePrivate on AmountEditingState {
  static AmountEditingState fromValue(Decimal? value) {
    if (value == null) return AmountEditingState.empty;

    if (value == Decimal.zero) return AmountEditingState.zero;

    return AmountEditingState.value;
  }
}
