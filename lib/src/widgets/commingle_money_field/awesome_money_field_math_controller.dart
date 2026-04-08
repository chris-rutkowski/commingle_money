import 'awesome_money_field.dart';

/// A math button type.
enum AwesomeMoneyFieldButton {
  /// The plus button.
  plus,

  /// The minus button.
  minus,

  /// The multiply button.
  multiply,

  /// The divide button.
  divide,

  /// The equal button.
  equal,
}

/// A callback invoked when a math [button] is pressed.
typedef AwesomeMoneyFieldMathListener = void Function(AwesomeMoneyFieldButton button);

/// A controller used to notify an [AwesomeMoneyField] about math button presses.
final class AwesomeMoneyFieldMathController {
  /// The current listener for math button presses, [AwesomeMoneyField] assigns itself as the listener automatically.
  AwesomeMoneyFieldMathListener? listener;

  /// Notifies listener ([AwesomeMoneyField]) of [button] press.
  void handle(AwesomeMoneyFieldButton button) {
    listener?.call(button);
  }
}
