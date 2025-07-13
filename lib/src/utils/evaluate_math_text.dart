// ignore_for_file: public_member_api_docs

import 'package:decimal/decimal.dart';
import 'package:expressions/expressions.dart';

import 'decimal_utils.dart';

Decimal? evaluateMathText(String text) {
  const plusSign = '+'; // standard plus sign
  const minusSign = '‒'; // fancy minus sign
  const multiplicationSign = '×'; // fancy multiplication sign
  const divisionSign = '÷'; // fancy division sign

  final validOperators = [
    RegExp.escape(plusSign),
    RegExp.escape(minusSign),
    RegExp.escape(multiplicationSign),
    RegExp.escape(divisionSign),
    RegExp.escape('*'),
    RegExp.escape('-'),
    RegExp.escape('/'),
  ];

  final processed = text
      .replaceAll(RegExp(r'^[\s.,]+|[\s.,]+$'), '')
      .replaceAll(RegExp('(${validOperators.join('|')})+\$'), '')
      .replaceAll(plusSign, '+')
      .replaceAll(multiplicationSign, '*')
      .replaceAll(minusSign, '-')
      .replaceAll(divisionSign, '/')
      .replaceAll('%', '*0.01')
      // adds `*` before `(` if there is a number before `(`
      .replaceAllMapped(RegExp(r'(\d)\s*\('), (match) => '${match[1]}*(')
      // adds * after `(` if there is a `)` before `(`
      .replaceAllMapped(RegExp(r'\)\s*\('), (_) => ')*(');

  const evaluator = ExpressionEvaluator();

  try {
    final parsed = Expression.parse(processed);
    final result = evaluator.eval(parsed, {});

    if (result is int) {
      return Decimal.fromInt(result);
    }

    if (result is double) {
      return DecimalUtils.fromDouble(result);
    }

    return null;
  } catch (_) {
    return null;
  }
}
