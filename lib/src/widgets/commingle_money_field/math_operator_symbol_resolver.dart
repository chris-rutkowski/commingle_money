import 'commingle_money_field.dart';
import 'math_operator.dart';

/// Resolves the display symbol for a given [MathOperator].
typedef MathOperatorSymbolResolver = String Function(MathOperator operator);

/// Default display symbol mapping used by [CommingleMoneyField].
String defaultMathOperatorSymbolResolver(MathOperator operator) {
  switch (operator) {
    case .plus:
      return '+';
    case .minus:
      return '−';
    case .multiply:
      return '×';
    case .divide:
      return '÷';
    case .equal:
      return '=';
  }
}
