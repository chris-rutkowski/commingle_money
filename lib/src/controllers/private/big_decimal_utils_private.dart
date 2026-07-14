// ignore_for_file: public_member_api_docs

import 'package:big_decimal/big_decimal.dart';

import '../../big_decimal_utils.dart';

extension BigDecimalUtilsPrivate on BigDecimal {
  BigDecimal roundOptional({int? scale}) {
    if (scale == null) {
      return this;
    }

    return round(scale: scale);
  }
}
