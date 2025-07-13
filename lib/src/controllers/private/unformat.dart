// ignore_for_file: public_member_api_docs

import '../../amount_format_separators.dart';

String unformat(
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
