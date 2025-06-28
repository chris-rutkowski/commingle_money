part of '../amount_editing_controller.dart';

String _formatDecimal(
  Decimal value, {
  int? fractionalDigits,
  required AmountFormatSeparators separators,
}) {
  // rounds the value if fractionalDigits is provided, otherwise uses the value as is
  final roundedValue = fractionalDigits != null ? value.round(scale: fractionalDigits) : value;

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

  // pad the fraction with zeros if fractionalDigits is provided, otherwise leave it as is
  final paddedFraction = fractionalDigits != null ? fraction.padRight(fractionalDigits, '0') : fraction;

  return '$formattedInteger${separators.decimal}$paddedFraction';
}
