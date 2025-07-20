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
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('zero HKD', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            money: Money(
              currencyCode: CurrencyCodes.hkd,
              amount: Decimal.zero,
            ),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('always decimal PLN', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            fractionalMode: FractionalMode.always,
            money: Money(
              currencyCode: CurrencyCodes.pln,
              amount: Decimal.fromInt(123),
            ),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('round up AUD', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            fractionalMode: FractionalMode.round,
            money: Money(
              currencyCode: CurrencyCodes.aud,
              amount: Decimal.parse('5623.5'),
            ),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('round down CNY', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            fractionalMode: FractionalMode.round,
            money: Money(
              currencyCode: CurrencyCodes.cny,
              amount: Decimal.parse('72316.49'),
            ),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('accurate 4 digits INR', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            fractionalMode: FractionalMode.accurate,
            money: Money(
              currencyCode: CurrencyCodes.inr,
              amount: Decimal.parse('84321.6225'),
            ),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('accurate 1 digits IRR', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            fractionalMode: FractionalMode.accurate,
            money: Money(
              currencyCode: CurrencyCodes.irr,
              amount: Decimal.parse('7281.1'),
            ),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('accurate 0 digits ZAR', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            fractionalMode: FractionalMode.accurate,
            money: Money(
              currencyCode: CurrencyCodes.zar,
              amount: Decimal.parse('241'),
            ),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('negative without sign SGD', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            displayNegativeSign: false,
            fractionalMode: FractionalMode.accurate,
            money: Money(
              currencyCode: CurrencyCodes.sgd,
              amount: Decimal.parse('-126.1'),
            ),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('compact 99.0 BIF', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            displayNegativeSign: false,
            fractionalMode: FractionalMode.compact,
            money: Money(
              currencyCode: CurrencyCodes.bif,
              amount: Decimal.parse('99'),
            ),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('compact 99.99 BMD', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            displayNegativeSign: false,
            fractionalMode: FractionalMode.compact,
            money: Money(
              currencyCode: CurrencyCodes.bmd,
              amount: Decimal.parse('99.99'),
            ),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('compact 100.59 BND', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            displayNegativeSign: false,
            fractionalMode: FractionalMode.compact,
            money: Money(
              currencyCode: CurrencyCodes.bnd,
              amount: Decimal.parse('100.59'),
            ),
          ),
        ),
      );

      await tester.snapshot();
    });

    testWidgets('theme BOB', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          applyDefaults: false,
          child: Builder(
            builder: (context) {
              return Theme(
                data: Theme.of(context).copyWith(
                  textTheme: const TextTheme(
                    bodyLarge: TextStyle(fontFamily: 'Noto', fontSize: 20),
                    bodyMedium: TextStyle(fontFamily: 'Noto', fontSize: 15),
                  ),
                ),
                child: MoneyLabel(
                  money: Money(
                    currencyCode: CurrencyCodes.bob,
                    amount: Decimal.parse('6432.52'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.snapshot();
    });
  });
}

extension _WidgetTester on WidgetTester {
  Future<void> snapshot() async {
    await binding.setSurfaceSize(const Size(300, 100));
    await pump();

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
  final bool applyDefaults;

  const SnapshotWrapper({
    super.key,
    required this.child,
    this.applyDefaults = true,
  });

  @override
  Widget build(BuildContext context) {
    final innerChild = Directionality(
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
    );

    return AmountFormatSeparators(
      data: AmountFormatSeparatorsData.pl,
      child: applyDefaults
          ? MoneyPresentationDefaults(
              data: const MoneyPresentationDefaultsData(
                primaryTextStyle: TextStyle(fontFamily: 'Noto', fontSize: 30, color: Colors.black),
                secondaryTextStyle: TextStyle(fontFamily: 'Noto', fontSize: 15, color: Colors.black),
                positiveColor: Colors.blue,
                negativeColor: Colors.red,
                zeroColor: Colors.grey,
              ),
              child: innerChild,
            )
          : innerChild,
    );
  }
}
