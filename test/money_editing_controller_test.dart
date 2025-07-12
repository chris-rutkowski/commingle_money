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

  group('MoneyEditingController', () {
    testWidgets('standard', (WidgetTester tester) async {
      final controller = MoneyEditingController(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('1234.56'));

      Money? listenerValue;
      controller.addListener(() {
        listenerValue = controller.value;
      });

      void expectState({
        required String text,
        required Decimal? value,
        CurrencyCode? currency,
        required bool quiet,
      }) {
        expect(controller.textController.text, text);

        final Money? moneyValue;
        if (value == null) {
          moneyValue = null;
        } else {
          moneyValue = Money(amount: value, currencyCode: currency ?? CurrencyCodes.usd);
        }

        expect(controller.value, moneyValue);
        if (quiet) {
          expect(listenerValue, isNull);
        } else {
          expect(listenerValue, moneyValue);
        }

        listenerValue = null;
      }

      await tester.pumpWidget(
        SnapshotWrapper(
          child: TextField(
            controller: controller.textController,
            focusNode: controller.focusNode,
            style: const TextStyle(
              fontFamily: 'Noto',
              fontSize: 24,
            ),
          ),
        ),
      );

      // Initial state
      expectState(text: '1,234.56', value: Decimal.parse('1234.56'), quiet: true);
      expect(controller.currencyCode, CurrencyCodes.usd);

      // User modifies
      await tester.type('6543.21');
      expectState(text: '6543.21', value: Decimal.parse('6543.21'), quiet: false);

      // Users dismisses keyboard - value should be formatted
      await tester.dismissKeyboard(controller);
      expectState(text: '6,543.21', value: Decimal.parse('6543.21'), quiet: true);

      // App changes currency
      controller.currencyCode = CurrencyCodes.bhd;
      await tester.pump();
      expectState(text: '6,543.210', value: Decimal.parse('6543.21'), currency: CurrencyCodes.bhd, quiet: false);
      controller.currencyCode = CurrencyCodes.sgd;
      await tester.pump();
      expectState(text: '6,543.2', value: Decimal.parse('6543.2'), currency: CurrencyCodes.sgd, quiet: false);
      controller.currencyCode = CurrencyCodes.usd;
      await tester.pump();
      expectState(text: '6,543.20', value: Decimal.parse('6543.2'), quiet: false);

      // App changes value as user types
      await tester.type('4');
      expectState(text: '4', value: Decimal.parse('4'), quiet: false);
      controller.value = Money(amount: Decimal.parse('5'), currencyCode: CurrencyCodes.usd);
      await tester.pump();
      expectState(text: '4', value: Decimal.parse('5'), quiet: false);
      await tester.dismissKeyboard(controller);
      expectState(text: '5', value: Decimal.parse('5'), quiet: true);

      // App erases value
      controller.value = null;
      await tester.pump();
      expectState(text: '', value: null, quiet: false);

      // User erases value
      await tester.type('1234.56');
      expectState(text: '1234.56', value: Decimal.parse('1234.56'), quiet: false);
      await tester.type('');
      expectState(text: '', value: null, quiet: false);

      // User types formula
      await tester.type('2(5-1)*3×4/1.5÷3‒1');
      expectState(text: '2(5-1)*3×4/1.5÷3‒1', value: Decimal.parse('20.33'), quiet: false);
      await tester.dismissKeyboard(controller);
      expectState(text: '20.33', value: Decimal.parse('20.33'), quiet: true);

      controller.dispose();
    });
  });
}

extension _WidgetTester on WidgetTester {
  Future<void> type(String text) async {
    await enterText(find.byType(TextField), text);
    await pump();
  }

  Future<void> dismissKeyboard(MoneyEditingController controller) async {
    controller.focusNode.unfocus();
    await pump();
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: AmountFormatSeparators(
          data: AmountFormatSeparatorsData.pl,
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
      ),
    );
  }
}
