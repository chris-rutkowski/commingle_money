// ignore_for_file: public_member_api_docs

import 'package:decimal/decimal.dart';

extension DecimalUtilsInternal on Decimal {
  Decimal roundOptional({int? scale}) {
    if (scale == null) {
      return this;
    }

    return round(scale: scale);
  }
}
