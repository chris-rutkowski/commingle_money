part of '../controllers/amount_editing_controller.dart';

String _unformat(
  String formatted, {
  required AmountFormatSeparatorsData separators,
}) {
  const machineDecimalPoint = '.';

  var processed = formatted.trim().replaceAll(separators.grouping, '');

  if (separators.decimal != machineDecimalPoint) {
    processed = processed.replaceAll(separators.decimal, machineDecimalPoint);
  }

  return processed;
}
