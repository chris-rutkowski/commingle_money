part of '../controllers/amount_editing_controller.dart';

String _formatDecimal(
  Decimal value, {
  int? precision,
  required AmountFormatSeparatorsData separators,
}) {
  // rounds the value if `precision` is provided, otherwise uses the value as is
  final roundedValue = precision != null ? value.round(scale: precision) : value;

  final parts = roundedValue.toString().split('.');

  final integer = parts[0];
  final fraction = parts.length > 1 ? parts[1] : null;

  final formattedInteger = integer.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}${separators.grouping}',
  );

  // if there is no fraction, returns only the formatted integer
  if (fraction == null || Decimal.parse('0.$fraction') == Decimal.zero) {
    return formattedInteger;
  }

  // pad the fraction with zeros if `precision` is provided, otherwise leave it as is
  final paddedFraction = precision != null ? fraction.padRight(precision, '0') : fraction;

  return '$formattedInteger${separators.decimal}$paddedFraction';
}
