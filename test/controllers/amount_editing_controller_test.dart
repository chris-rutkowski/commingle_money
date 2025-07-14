import 'dart:io';

import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/widget_tester_ext.dart';

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
        required AmountEditingState state,
      }) {
        expect(controller.textController.text, text);

        expect(controller.value, value);
        expect(controller.valueOrZero, value ?? Decimal.zero);

        if (quiet) {
          expect(listenerValue, isNull);
        } else {
          expect(listenerValue, value);
        }
        listenerValue = null;

        expect(controller.state.value, state);
      }

      await tester.pumpWidget(
        _Wrapper(
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
      expectState(text: '3,532.23', value: Decimal.parse('3532.23'), quiet: true, state: AmountEditingState.value);

      // User modifies
      await tester.type('1234.56');
      expectState(text: '1234.56', value: Decimal.parse('1234.56'), quiet: false, state: AmountEditingState.value);

      // Users dismisses keyboard - value should be formatted
      await tester.dismissKeyboard(controller);
      expectState(text: '1,234.56', value: Decimal.parse('1234.56'), quiet: true, state: AmountEditingState.value);

      // App changes precision
      controller.precision = 1;
      await tester.pump();
      expectState(text: '1,234.6', value: Decimal.parse('1234.6'), quiet: false, state: AmountEditingState.value);

      // App changes value
      controller.value = Decimal.parse('9876.9');
      await tester.pump();
      expectState(text: '9,876.9', value: Decimal.parse('9876.9'), quiet: false, state: AmountEditingState.value);

      // App changes precision without affecting value, listener shouldn't trigger
      controller.precision = 3;
      await tester.pump();
      expectState(text: '9,876.900', value: Decimal.parse('9876.9'), quiet: true, state: AmountEditingState.value);

      // App changes value as user types
      await tester.type('4');
      expectState(text: '4', value: Decimal.parse('4'), quiet: false, state: AmountEditingState.value);
      controller.value = Decimal.parse('5');
      await tester.pump();
      expectState(text: '4', value: Decimal.parse('5'), quiet: false, state: AmountEditingState.value);
      await tester.dismissKeyboard(controller);
      expectState(text: '5', value: Decimal.parse('5'), quiet: true, state: AmountEditingState.value);

      // App erases value
      controller.value = null;
      await tester.pump();
      expectState(text: '', value: null, quiet: false, state: AmountEditingState.empty);

      // User erases value
      await tester.type('1234.56');
      expectState(text: '1234.56', value: Decimal.parse('1234.56'), quiet: false, state: AmountEditingState.value);
      await tester.type('');
      expectState(text: '', value: null, quiet: false, state: AmountEditingState.empty);

      // User types formula
      await tester.type('2(5-1)*3×4/1.5÷3‒1');
      expectState(
        text: '2(5-1)*3×4/1.5÷3‒1',
        value: Decimal.parse('20.333'),
        quiet: false,
        state: AmountEditingState.value,
      );
      await tester.dismissKeyboard(controller);
      expectState(text: '20.333', value: Decimal.parse('20.333'), quiet: true, state: AmountEditingState.value);

      // User divides by zero
      await tester.type('2/0');
      expectState(
        text: '2/0',
        value: Decimal.parse('20.333'), // previous legal value
        quiet: true,
        state: AmountEditingState.error,
      );
      await tester.dismissKeyboard(controller);
      expectState(text: '20.333', value: Decimal.parse('20.333'), quiet: true, state: AmountEditingState.value);

      // User enters invalid formula
      await tester.type('2)');
      expectState(
        text: '2)',
        value: Decimal.parse('20.333'), // previous legal value
        quiet: true,
        state: AmountEditingState.error,
      );
      await tester.dismissKeyboard(controller);
      expectState(text: '20.333', value: Decimal.parse('20.333'), quiet: true, state: AmountEditingState.value);

      // User types zero
      await tester.type('0');
      expectState(
        text: '0',
        value: Decimal.zero,
        quiet: false,
        state: AmountEditingState.zero,
      );

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
        _Wrapper(
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
  Future<void> dismissKeyboard(AmountEditingController controller) async {
    controller.focusNode.unfocus();
    await pump();
  }
}

final class _Wrapper extends StatelessWidget {
  final Widget child;

  const _Wrapper({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: AmountFormatSeparators(
          data: AmountFormatSeparatorsData.pl,
          child: child,
        ),
      ),
    );
  }
}
