import 'package:commingle_money/commingle_money.dart';
import 'package:flutter/material.dart';

enum SeparatorsType {
  fromLocalePlus,
  standard,
  polish,
  verbose,
}

extension SeparatorsTypeResolver on SeparatorsType {
  AmountFormatSeparatorsData resolve(BuildContext context) {
    switch (this) {
      case SeparatorsType.fromLocalePlus:
        return AmountFormatSeparators.read(context); // InheritedWidget created in `main.dart`

      case SeparatorsType.polish:
        return AmountFormatSeparatorsData.pl;

      case SeparatorsType.verbose:
        return const AmountFormatSeparatorsData(grouping: 'g', decimal: 'd');

      case SeparatorsType.standard:
        return const AmountFormatSeparatorsData();
    }
  }
}
