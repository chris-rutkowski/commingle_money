import 'package:commingle_money/commingle_money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AmountFormatSeparators', () {
    test('equals and notify', () {
      final a = const AmountFormatSeparatorsData();
      final b = const AmountFormatSeparatorsData();
      final c = AmountFormatSeparatorsData.pl;

      expect(a, b);
      expect(a, isNot(c));

      final parent = AmountFormatSeparators(data: a, child: const SizedBox());
      expect(parent.updateShouldNotify(AmountFormatSeparators(data: b, child: const SizedBox())), isFalse);
      expect(parent.updateShouldNotify(AmountFormatSeparators(data: c, child: const SizedBox())), isTrue);
    });
  });
}
