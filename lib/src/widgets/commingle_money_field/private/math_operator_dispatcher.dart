// ignore_for_file: public_member_api_docs

import '../math_operator.dart';

typedef MathOperatorListener = void Function(MathOperator operator);

final class MathOperatorDispatcher {
  MathOperatorListener? listener;

  void dispatch(MathOperator operator) {
    listener?.call(operator);
  }
}
