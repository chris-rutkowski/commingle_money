import 'dart:io';
import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final fontData = File('test/assets/noto_sans.ttf').readAsBytesSync();
    final fontLoader = FontLoader('Noto')..addFont(Future.value(fontData.buffer.asByteData()));
    await fontLoader.load();
  });

  group('CommingleMoneyField', () {
    testWidgets('typing updates controller with grouping and precision', (tester) async {
      final controller = createController();
      addTearDown(controller.dispose);

      await tester.pumpField(controller: controller);
      await tester.tap(find.byType(CommingleMoneyField));
      await tester.pump();

      await tester.typeSequentially('1234.567');

      expect(controller.value?.currencyCode, CurrencyCodes.usd);
      expect(controller.value?.amount, Decimal.parse('1234.56'));
    });

    testWidgets('backspace removes digits and eventually clears controller', (tester) async {
      final controller = createController();
      addTearDown(controller.dispose);

      await tester.pumpField(controller: controller);
      await tester.tap(find.byType(CommingleMoneyField));
      await tester.pump();

      await tester.typeSequentially('123');
      expect(controller.value?.amount, Decimal.parse('123'));

      await tester.pressBackspace();
      expect(controller.value?.amount, Decimal.parse('12'));

      await tester.pressBackspace();
      expect(controller.value?.amount, Decimal.parse('1'));

      await tester.pressBackspace();
      expect(controller.value, isNull);
    });

    testWidgets('arithmetic updates controller with evaluated result and equal commits it', (tester) async {
      final controller = createController(amount: Decimal.parse('12'));
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
      );

      dispatcher.handle(MathOperator.plus);
      await tester.settleField();

      await tester.typeSequentially('3');
      expect(controller.value?.amount, Decimal.parse('15'));

      dispatcher.handle(MathOperator.equal);
      await tester.settleField();

      expect(controller.value?.amount, Decimal.parse('15'));

      await tester.typeSequentially('4');
      expect(
        controller.value?.amount,
        Decimal.parse('154'),
        reason: 'Equal should commit the result back into operand A and clear math mode.',
      );
    });

    testWidgets('accepts Arabic-Indic digits and decimal separator', (tester) async {
      final controller = createController();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        direction: TextDirection.rtl,
      );
      await tester.tap(find.byType(CommingleMoneyField));
      await tester.pump();

      await tester.typeSequentially('١٢٣٫٤٥');

      expect(controller.value?.currencyCode, CurrencyCodes.usd);
      expect(controller.value?.amount, Decimal.parse('123.45'));
    });

    testWidgets('Arabic locale renders Arabic-Indic digits', (tester) async {
      final controller = createController(amount: Decimal.parse('1234.56'));
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        direction: TextDirection.rtl,
        locale: const Locale('ar'),
      );

      await tester.snapshot();
    });

    testWidgets('changing operator mid-expression carries evaluated result into operand A', (tester) async {
      final controller = createController(amount: Decimal.parse('12'));
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
      );

      dispatcher.handle(MathOperator.plus);
      await tester.settleField();
      await tester.typeSequentially('3');
      expect(controller.value?.amount, Decimal.parse('15'));

      dispatcher.handle(MathOperator.multiply);
      await tester.settleField();
      await tester.typeSequentially('2');

      expect(controller.value?.amount, Decimal.parse('30'));
    });

    testWidgets('unfocus during pending arithmetic keeps evaluated controller value', (tester) async {
      final controller = createController(amount: Decimal.parse('25'));
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
      );

      dispatcher.handle(MathOperator.minus);
      await tester.settleField();
      await tester.typeSequentially('5');
      expect(controller.value?.amount, Decimal.parse('20'));

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.settleField();

      await tester.typeSequentially('1');
      expect(
        controller.value?.amount,
        Decimal.parse('201'),
        reason: 'Unfocus should clear the pending operator and keep the current output.',
      );
    });

    testWidgets('external controller change resets pending arithmetic state', (tester) async {
      final controller = createController(amount: Decimal.parse('50'));
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
      );

      dispatcher.handle(MathOperator.divide);
      await tester.settleField();
      await tester.typeSequentially('2');
      expect(controller.value?.amount, Decimal.parse('25'));

      controller.value = Money(
        currencyCode: CurrencyCodes.usd,
        amount: Decimal.parse('7'),
      );
      await tester.settleField();

      await tester.typeSequentially('3');
      expect(
        controller.value?.amount,
        Decimal.parse('73'),
        reason: 'A programmatic controller update should reset math mode back to plain editing.',
      );
    });

    testWidgets('minus below zero clamps controller to zero', (tester) async {
      final controller = createController(amount: Decimal.parse('10'));
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
      );

      dispatcher.handle(MathOperator.minus);
      await tester.settleField();
      await tester.typeSequentially('99');

      expect(controller.value?.amount, Decimal.zero);
    });

    testWidgets('divide by zero clamps controller to zero', (tester) async {
      final controller = createController(amount: Decimal.parse('10'));
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
      );

      dispatcher.handle(MathOperator.divide);
      await tester.settleField();
      await tester.typeSequentially('0');

      expect(controller.value?.amount, Decimal.zero);
    });

    testWidgets('end to end flow handles multiple operators equal and currency changes', (tester) async {
      final controller = createController(amount: Decimal.parse('12'));
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
        prefix: const Text('USD'),
        suffix: const Text('value'),
        affixesSpacing: 8,
      );

      await tester.snapshotNamed('end_to_end_flow_step_1_initial');

      dispatcher.handle(MathOperator.plus);
      await tester.settleField();
      await tester.typeSequentially('3');
      expect(controller.value?.currencyCode, CurrencyCodes.usd);
      expect(controller.value?.amount, Decimal.parse('15'));
      await tester.snapshotNamed('end_to_end_flow_step_2_after_plus');

      dispatcher.handle(MathOperator.multiply);
      await tester.settleField();
      await tester.typeSequentially('2');
      expect(controller.value?.amount, Decimal.parse('30'));
      await tester.snapshotNamed('end_to_end_flow_step_3_after_multiply');

      dispatcher.handle(MathOperator.equal);
      await tester.settleField();
      expect(controller.value?.currencyCode, CurrencyCodes.usd);
      expect(controller.value?.amount, Decimal.parse('30'));
      await tester.snapshotNamed('end_to_end_flow_step_4_after_equal');

      controller.value = Money(
        currencyCode: CurrencyCodes.btc,
        amount: Decimal.parse('1.2345'),
      );
      await tester.settleField();

      expect(controller.value?.currencyCode, CurrencyCodes.btc);
      expect(controller.value?.amount, Decimal.parse('1.2345'));
      await tester.snapshotNamed('end_to_end_flow_step_5_after_currency_change');

      dispatcher.handle(MathOperator.divide);
      await tester.settleField();
      await tester.typeSequentially('2');
      expect(controller.value?.currencyCode, CurrencyCodes.btc);
      expect(controller.value?.amount, Decimal.parse('0.61725'));
      await tester.snapshotNamed('end_to_end_flow_step_6_after_divide');

      dispatcher.handle(MathOperator.equal);
      await tester.settleField();
      expect(controller.value?.currencyCode, CurrencyCodes.btc);
      expect(controller.value?.amount, Decimal.parse('0.61725'));
      await tester.snapshotNamed('end_to_end_flow_step_7_after_second_equal');

      dispatcher.handle(MathOperator.minus);
      await tester.settleField();
      await tester.typeSequentially('9');
      expect(controller.value?.currencyCode, CurrencyCodes.btc);
      expect(controller.value?.amount, Decimal.zero);
      await tester.snapshotNamed('end_to_end_flow_step_8_after_clamp_to_zero');

      dispatcher.handle(MathOperator.equal);
      await tester.settleField();
      expect(controller.value?.currencyCode, CurrencyCodes.btc);
      expect(controller.value?.amount, Decimal.zero);
      await tester.snapshotNamed('end_to_end_flow_step_9_zero_committed');

      await tester.tap(find.byType(CommingleMoneyField));
      await tester.pump();
      dispatcher.handle(MathOperator.plus);
      await tester.settleField();
      await tester.typeSequentially('5');

      expect(
        controller.value?.amount,
        Decimal.parse('5'),
        reason: 'Operators should be ignored when the current output is zero, so typing resumes plain editing.',
      );
      expect(controller.value?.currencyCode, CurrencyCodes.btc);
      await tester.snapshotNamed('end_to_end_flow_step_10_zero_operator_ignored');
    });

    testWidgets('operators are ignored when value is empty', (tester) async {
      final controller = createController();
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
      );

      dispatcher.handle(MathOperator.plus);
      await tester.settleField();
      await tester.typeSequentially('7');

      expect(
        controller.value?.amount,
        Decimal.parse('7'),
        reason: 'When there is no operand A yet, operator input should not enter arithmetic mode.',
      );
    });

    testWidgets('empty with affixes', (tester) async {
      final controller = createController();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        prefix: const Text('USD'),
        suffix: const Text('value'),
        affixesSpacing: 8,
      );

      await tester.snapshot();
    });

    testWidgets('rtl with Arabic affixes', (tester) async {
      final controller = createController();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        prefix: const Text('ر.س'),
        suffix: const Text('المبلغ'),
        affixesSpacing: 8,
        placeholder: 'صفر',
        direction: TextDirection.rtl,
      );

      await tester.snapshot();
    });

    testWidgets('filled with affixes', (tester) async {
      final controller = createController(amount: Decimal.parse('1234.56'));
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        prefix: const Text('USD'),
        suffix: const Text('value'),
        affixesSpacing: 8,
      );

      await tester.settleField();
      await tester.snapshot();
    });

    testWidgets('arithmetic hides affixes and shows expression', (tester) async {
      final controller = createController(amount: Decimal.parse('12'));
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
        prefix: const Text('USD'),
        suffix: const Text('value'),
        affixesSpacing: 8,
      );

      dispatcher.handle(MathOperator.plus);
      await tester.settleField();
      await tester.typeSequentially('3');
      await tester.snapshot();
    });

    testWidgets('rtl arithmetic with Arabic input', (tester) async {
      final controller = createController(amount: Decimal.parse('12'));
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
        prefix: const Text('ر.س'),
        suffix: const Text('المبلغ'),
        affixesSpacing: 8,
        direction: TextDirection.rtl,
      );

      dispatcher.handle(MathOperator.plus);
      await tester.settleField();
      await tester.typeSequentially('٣');

      expect(controller.value?.amount, Decimal.parse('15'));

      dispatcher.handle(MathOperator.equal);
      await tester.settleField();
      expect(controller.value?.amount, Decimal.parse('15'));

      await tester.snapshot();
    });

    testWidgets('uses default operator symbols', (tester) async {
      final controller = createController(amount: Decimal.parse('12'));
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
      );

      dispatcher.handle(MathOperator.plus);
      await tester.settleField();

      expect(find.text('+'), findsOneWidget);
    });

    testWidgets('uses custom operator symbols', (tester) async {
      final controller = createController(amount: Decimal.parse('12'));
      final dispatcher = MathOperatorDispatcher();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        dispatcher: dispatcher,
        mathOperatorSymbolBuilder: (operator) => switch (operator) {
          MathOperator.plus => 'plus',
          MathOperator.equal => 'equals',
          _ => defaultMathOperatorSymbolResolver(operator),
        },
      );

      dispatcher.handle(MathOperator.plus);
      await tester.settleField();
      expect(find.text('plus'), findsOneWidget);

      await tester.typeSequentially('3');
      expect(find.text('equals'), findsOneWidget);
    });

    testWidgets('placeholder with custom text style', (tester) async {
      final controller = createController();
      addTearDown(controller.dispose);

      await tester.pumpField(
        controller: controller,
        textStyle: const TextStyle(
          fontFamily: 'Noto',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      );

      await tester.snapshot();
    });
  });
}

MoneyEditingController createController({
  Decimal? amount,
  CurrencyCode currencyCode = CurrencyCodes.usd,
}) {
  return MoneyEditingController(
    currencyCode: currencyCode,
    amount: amount,
    separators: AmountFormatSeparatorsData.pl,
  );
}

extension _WidgetTester on WidgetTester {
  Future<void> pumpField({
    required MoneyEditingController controller,
    MathOperatorDispatcher? dispatcher,
    Widget? prefix,
    Widget? suffix,
    double affixesSpacing = 0,
    TextStyle? textStyle,
    String placeholder = '0',
    TextDirection direction = TextDirection.ltr,
    Locale? locale,
    MathOperatorSymbolResolver mathOperatorSymbolBuilder = defaultMathOperatorSymbolResolver,
  }) async {
    await pumpWidget(
      SnapshotWrapper(
        direction: direction,
        locale: locale,
        child: CommingleMoneyField(
          controller: controller,
          mathOperatorDispatcher: dispatcher,
          symbolResolver: mathOperatorSymbolBuilder,
          prefix: prefix,
          suffix: suffix,
          affixesSpacing: affixesSpacing,
          textStyle: textStyle,
          placeholder: placeholder,
        ),
      ),
    );

    await settleField();
  }

  Future<void> typeSequentially(String value) async {
    for (final char in value.split('')) {
      await enterText(find.byType(TextField), char);
      await settleField();
    }
  }

  Future<void> pressBackspace() async {
    await enterText(find.byType(TextField), '');
    await settleField();
  }

  Future<void> settleField() async {
    await pump();
    await pump(const Duration(milliseconds: 300));
  }

  Future<void> snapshot() async {
    await snapshotNamed(
      testDescription.toLowerCase().replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'[^\w/.,]'), ''),
    );
  }

  Future<void> snapshotNamed(String name) async {
    await binding.setSurfaceSize(const Size(380, 140));
    await settleField();

    await expectLater(
      find.byType(SnapshotWrapper),
      matchesGoldenFile('goldens/commingle_money_field/$name.png'),
    );
  }
}

final class SnapshotWrapper extends StatelessWidget {
  final Widget child;
  final TextDirection direction;
  final Locale? locale;

  const SnapshotWrapper({
    super.key,
    required this.child,
    this.direction = TextDirection.ltr,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      home: AmountFormatSeparators(
        data: AmountFormatSeparatorsData.pl,
        child: MoneyPresentationDefaults(
          data: const MoneyPresentationDefaultsData(
            primaryTextStyle: TextStyle(fontFamily: 'Noto', fontSize: 30, color: Colors.black),
            secondaryTextStyle: TextStyle(fontFamily: 'Noto', fontSize: 15, color: Colors.black),
            positiveColor: Colors.blue,
            negativeColor: Colors.red,
            zeroColor: Colors.grey,
          ),
          child: Theme(
            data: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              textTheme: const TextTheme(
                headlineLarge: TextStyle(fontFamily: 'Noto', fontSize: 30, color: Colors.black),
                bodyMedium: TextStyle(fontFamily: 'Noto', fontSize: 16, color: Colors.black),
              ),
            ),
            child: Scaffold(
              body: Directionality(
                textDirection: direction,
                child: DefaultTextHeightBehavior(
                  textHeightBehavior: const TextHeightBehavior(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
