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

  group('AmountEditingController', () {
    testWidgets('standard', (WidgetTester tester) async {
      final controller = AmountEditingController(precision: 2, amount: Decimal.parse('3532.2312'));

      Decimal? listenerValue;
      controller.addListener(() {
        listenerValue = controller.value;
      });

      void expectState({
        required String text,
        required Decimal? value,
        required bool quiet,
      }) {
        expect(controller.textController.text, text);
        expect(controller.value, value);
        if (quiet) {
          expect(listenerValue, isNull);
        } else {
          expect(listenerValue, value);
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
      expectState(text: '3,532.23', value: Decimal.parse('3532.23'), quiet: true);

      // User modifies
      await tester.type('1234.56');
      expectState(text: '1234.56', value: Decimal.parse('1234.56'), quiet: false);

      // Users dismisses keyboard - value should be formatted
      listenerValue = null;
      await tester.dismissKeyboard(controller);
      expectState(text: '1,234.56', value: Decimal.parse('1234.56'), quiet: true);

      // App changes precision
      controller.precision = 1;
      await tester.pump();
      expectState(text: '1,234.6', value: Decimal.parse('1234.6'), quiet: false);

      // App changes value
      controller.value = Decimal.parse('9876.9');
      await tester.pump();
      expectState(text: '9,876.9', value: Decimal.parse('9876.9'), quiet: false);

      // App changes precision without affecting value, listener shouldn't trigger
      controller.precision = 3;
      await tester.pump();
      expectState(text: '9,876.900', value: Decimal.parse('9876.9'), quiet: true);

      // App changes value as user types
      await tester.type('4');
      expectState(text: '4', value: Decimal.parse('4'), quiet: false);
      controller.value = Decimal.parse('5');
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
      expectState(text: '2(5-1)*3×4/1.5÷3‒1', value: Decimal.parse('20.333'), quiet: false);
      await tester.dismissKeyboard(controller);
      expectState(text: '20.333', value: Decimal.parse('20.333'), quiet: true);

      controller.dispose();
    });

    testWidgets('custom separators', (WidgetTester tester) async {
      final controller = AmountEditingController(
        separators: const AmountFormatSeparatorsData(grouping: 'g', decimal: 'd'),
        precision: 2,
        amount: Decimal.parse('3532.2312'),
      );

      Decimal? listenerValue;
      controller.addListener(() {
        listenerValue = controller.value;
      });

      void expectState({
        required String text,
        required Decimal? value,
        required bool quiet,
      }) {
        expect(controller.textController.text, text);
        expect(controller.value, value);
        if (quiet) {
          expect(listenerValue, isNull);
        } else {
          expect(listenerValue, value);
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
      expectState(text: '3g532d23', value: Decimal.parse('3532.23'), quiet: true);

      // User modifies
      await tester.type('1234d56');
      expectState(text: '1234d56', value: Decimal.parse('1234.56'), quiet: false);
      await tester.type('2g4g59g1gd12');
      expectState(text: '2g4g59g1gd12', value: Decimal.parse('24591.12'), quiet: false);
      await tester.dismissKeyboard(controller);
      expectState(text: '24g591d12', value: Decimal.parse('24591.12'), quiet: true);

      controller.dispose();
    });
  });
}

extension _WidgetTester on WidgetTester {
  Future<void> type(String text) async {
    await enterText(find.byType(TextField), text);
    await pump();
  }

  Future<void> dismissKeyboard(AmountEditingController controller) async {
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
