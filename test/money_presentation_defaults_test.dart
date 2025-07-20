import 'package:commingle_money/commingle_money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyPresentationDefaults', () {
    test('equals and notify', () {
      final a = const MoneyPresentationDefaultsData(
        positiveColor: Colors.green,
      );
      final b = const MoneyPresentationDefaultsData(
        positiveColor: Colors.green,
      );

      final c = const MoneyPresentationDefaultsData(
        positiveColor: Colors.blue,
      );

      expect(a, b);
      expect(a, isNot(c));

      final parent = MoneyPresentationDefaults(data: a, child: const SizedBox());
      expect(parent.updateShouldNotify(MoneyPresentationDefaults(data: b, child: const SizedBox())), isFalse);
      expect(parent.updateShouldNotify(MoneyPresentationDefaults(data: c, child: const SizedBox())), isTrue);
    });
  });
}
