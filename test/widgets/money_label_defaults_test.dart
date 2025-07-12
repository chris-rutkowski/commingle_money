import 'package:commingle_money/commingle_money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyLabelDefaults', () {
    test('equals and notify', () {
      final a = const MoneyLabelDefaultsData(
        positiveColor: Colors.green,
      );
      final b = const MoneyLabelDefaultsData(
        positiveColor: Colors.green,
      );

      final c = const MoneyLabelDefaultsData(
        positiveColor: Colors.blue,
      );

      expect(a, b);
      expect(a, isNot(c));

      final parent = MoneyLabelDefaults(data: a, child: const SizedBox());
      expect(parent.updateShouldNotify(MoneyLabelDefaults(data: b, child: const SizedBox())), isFalse);
      expect(parent.updateShouldNotify(MoneyLabelDefaults(data: c, child: const SizedBox())), isTrue);
    });
  });
}
