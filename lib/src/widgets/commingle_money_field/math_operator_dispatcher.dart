import 'commingle_money_field.dart';
import 'math_operator.dart';

/// A callback invoked when a math [operator] is dispatched.
typedef MathOperatorListener = void Function(MathOperator operator);

/// A dispatcher used to notify [CommingleMoneyField] (or other listener) about user's intent to perform an arithmetic operations.
final class MathOperatorDispatcher {
  /// The current listener of this dispatcher, [CommingleMoneyField] assigns itself as the listener automatically.
  MathOperatorListener? listener;

  /// Invoked by the caller to indicate that a math [operator] was triggered by the user.
  ///
  /// This method forwards the event to the registered [listener], allowing
  /// [CommingleMoneyField] (or any other listener) to react accordingly.
  ///
  /// If no [listener] is assigned, the call is ignored.
  void handle(MathOperator operator) {
    listener?.call(operator);
  }
}
