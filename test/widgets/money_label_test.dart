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
            money: Money(
              currencyCode: CurrencyCodes.usd,
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
            money: Money(
              currencyCode: CurrencyCodes.eur,
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
            animation: const MoneyLabelAnimation(),
            separators: const AmountFormatSeparatorsData(),
            money: Money(
              currencyCode: CurrencyCodes.gbp,
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

    testWidgets('zero HKD', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            separators: const AmountFormatSeparatorsData(),
            money: Money(
              currencyCode: CurrencyCodes.hkd,
              amount: Decimal.zero,
            ),
            secondaryPadding: const EdgeInsets.only(top: 10),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('always decimal PLN', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            separators: const AmountFormatSeparatorsData(),
            fractionalMode: MoneyLabelFractionalMode.always,
            money: Money(
              currencyCode: CurrencyCodes.pln,
              amount: Decimal.fromInt(123),
            ),
            secondaryPadding: const EdgeInsets.only(top: 10),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('round up AUD', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            separators: const AmountFormatSeparatorsData(),
            fractionalMode: MoneyLabelFractionalMode.round,
            money: Money(
              currencyCode: CurrencyCodes.aud,
              amount: Decimal.parse('5623.5'),
            ),
            secondaryPadding: const EdgeInsets.only(top: 10),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('round down CNY', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            separators: const AmountFormatSeparatorsData(),
            fractionalMode: MoneyLabelFractionalMode.round,
            money: Money(
              currencyCode: CurrencyCodes.cny,
              amount: Decimal.parse('72316.49'),
            ),
            secondaryPadding: const EdgeInsets.only(top: 10),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('accurate 4 digits INR', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            separators: const AmountFormatSeparatorsData(),
            fractionalMode: MoneyLabelFractionalMode.accurate,
            money: Money(
              currencyCode: CurrencyCodes.inr,
              amount: Decimal.parse('84321.6225'),
            ),
            secondaryPadding: const EdgeInsets.only(top: 10),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('accurate 1 digits IRR', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            separators: const AmountFormatSeparatorsData(),
            fractionalMode: MoneyLabelFractionalMode.accurate,
            money: Money(
              currencyCode: CurrencyCodes.irr,
              amount: Decimal.parse('7281.1'),
            ),
            secondaryPadding: const EdgeInsets.only(top: 10),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('accurate 0 digits ZAR', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            separators: const AmountFormatSeparatorsData(),
            fractionalMode: MoneyLabelFractionalMode.accurate,
            money: Money(
              currencyCode: CurrencyCodes.zar,
              amount: Decimal.parse('241'),
            ),
            secondaryPadding: const EdgeInsets.only(top: 10),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('negative without sign SGD', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            separators: const AmountFormatSeparatorsData(),
            displayNegativeSign: false,
            fractionalMode: MoneyLabelFractionalMode.accurate,
            money: Money(
              currencyCode: CurrencyCodes.sgd,
              amount: Decimal.parse('-126.1'),
            ),
            secondaryPadding: const EdgeInsets.only(top: 10),
          ),
        ),
      );

      await tester.snapshot();
    });
  });
}

extension _WidgetTester on WidgetTester {
  Future<void> snapshot() async {
    final sanitized = testDescription
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_') // spaces → underscores
        .replaceAll(RegExp(r'[^\w/.,]'), ''); // strip non-filename-safe chars

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
    return AmountFormatSeparators(
      data: AmountFormatSeparatorsData.pl,
      child: MoneyLabelDefaults(
        data: const MoneyLabelDefaultsData(
          primaryTextStyle: TextStyle(fontFamily: 'Noto', fontSize: 30, color: Colors.black),
          secondaryTextStyle: TextStyle(fontFamily: 'Noto', fontSize: 15, color: Colors.black),
          positiveColor: Colors.blue,
          negativeColor: Colors.red,
          zeroColor: Colors.grey,
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
      ),
    );
  }
}
