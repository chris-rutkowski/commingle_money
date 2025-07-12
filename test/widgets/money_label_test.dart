import 'dart:io';

import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final fontData = File('test/assets/noto_sans.ttf').readAsBytesSync();
    final fontLoader = FontLoader('Noto')..addFont(Future.value(fontData.buffer.asByteData()));
    await fontLoader.load();
  });

  group('MoneyLabel', () {
    testWidgets('positive USD', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            separators: const AmountFormatSeparators(grouping: 'K', decimal: 'D'),
            money: Money(
              currencyCode: 'USD',
              amount: Decimal.parse('1234.56'),
            ),
            secondaryPadding: const EdgeInsets.only(top: 10),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('negative EUR', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            separators: const AmountFormatSeparators(grouping: 'K', decimal: 'D'),
            money: Money(
              currencyCode: 'EUR',
              amount: Decimal.parse('-6126.99'),
            ),
            secondaryPadding: const EdgeInsets.only(top: 10),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('customised GBP', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            separators: const AmountFormatSeparators(grouping: 'K', decimal: 'D'),
            money: Money(
              currencyCode: 'GBP',
              amount: Decimal.parse('1234567.89'),
            ),
            primaryTextStyle: const TextStyle(fontFamily: 'Noto', fontSize: 25),
            secondaryTextStyle: const TextStyle(fontFamily: 'Noto', fontSize: 20),
            positiveColor: Colors.green,
            negativeColor: Colors.orange,
            secondaryPadding: const EdgeInsets.only(top: 5),
          ),
        ),
      );

      await tester.snapshot();
    });
  });
}

extension _Snapshot on WidgetTester {
  Future<void> snapshot() async {
    final sanitized = testDescription
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_') // spaces → underscores
        .replaceAll(RegExp(r'[^\w/]'), ''); // strip non-filename-safe chars

    await expectLater(
      find.byType(SnapshotWrapper),
      matchesGoldenFile('goldens/money_label/$sanitized.png'),
    );
  }
}

final class SnapshotWrapper extends StatelessWidget {
  final Widget child;

  const SnapshotWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MoneyLabelDefaults(
      data: const MoneyLabelDefaultsData(
        primaryTextStyle: TextStyle(fontFamily: 'Noto', fontSize: 30, color: Colors.black),
        secondaryTextStyle: TextStyle(fontFamily: 'Noto', fontSize: 15, color: Colors.black),
        positiveColor: Colors.blue,
        negativeColor: Colors.red,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextHeightBehavior(
          textHeightBehavior: const TextHeightBehavior(),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
