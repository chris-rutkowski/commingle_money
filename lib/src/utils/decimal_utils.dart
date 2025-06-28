// ignore_for_file: public_member_api_docs

import 'package:decimal/decimal.dart';

extension DecimalUtils on Decimal {
  Decimal roundOptional({int? scale}) {
    if (scale == null) {
      return this;
    }

    return round(scale: scale);
  }

  static Decimal fromDouble(double value) => Decimal.parse(value.toString());
}
