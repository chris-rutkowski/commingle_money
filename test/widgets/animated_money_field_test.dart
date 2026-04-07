import 'package:commingle_money/commingle_money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedMoneyFieldController', () {
    test('sanitizes decimal input and limits fraction digits', () {
      final controller = OldAnimatedMoneyFieldController();

      controller.replaceEditingText('00012.987');

      expect(controller.leftInput, '12.98');
      expect(controller.rawEditingText, '12.98');
      expect(controller.value.toString(), '12.98');
    });

    test('replaces operator before second operand is entered', () {
      final controller = OldAnimatedMoneyFieldController()..replaceEditingText('101');

      controller.applyOperator(OldAnimatedMoneyFieldOperator.plus);
      controller.applyOperator(OldAnimatedMoneyFieldOperator.minus);

      expect(controller.leftInput, '101');
      expect(controller.rightInput, isEmpty);
      expect(controller.operator, OldAnimatedMoneyFieldOperator.minus);
      expect(controller.rawEditingText, isEmpty);
    });

    test('evaluates previous expression when another operator is pressed', () {
      final controller = OldAnimatedMoneyFieldController()..replaceEditingText('101');

      controller.applyOperator(OldAnimatedMoneyFieldOperator.plus);
      controller.replaceEditingText('1');
      controller.applyOperator(OldAnimatedMoneyFieldOperator.multiply);

      expect(controller.leftInput, '102');
      expect(controller.rightInput, isEmpty);
      expect(controller.operator, OldAnimatedMoneyFieldOperator.multiply);
      expect(controller.value.toString(), '102');
    });

    test('equals evaluates expression and trailing operator is dropped', () {
      final controller = OldAnimatedMoneyFieldController()..replaceEditingText('12');

      controller.applyOperator(OldAnimatedMoneyFieldOperator.plus);
      controller.evaluate();

      expect(controller.leftInput, '12');
      expect(controller.operator, isNull);

      controller.applyOperator(OldAnimatedMoneyFieldOperator.plus);
      controller.replaceEditingText('3');
      controller.evaluate();

      expect(controller.leftInput, '15');
      expect(controller.rightInput, isEmpty);
      expect(controller.operator, isNull);
      expect(controller.value.toString(), '15');
    });

    test('pending operator can be cleared explicitly', () {
      final controller = OldAnimatedMoneyFieldController()..replaceEditingText('5');

      controller.applyOperator(OldAnimatedMoneyFieldOperator.plus);
      controller.clearPendingOperator();

      expect(controller.operator, isNull);
      expect(controller.leftInput, '5');
      expect(controller.rawEditingText, '5');
    });
  });

  group('AnimatedMoneyField widget', () {
    testWidgets('uses numeric keyboard, shows cursor on focus, and renders decimal placeholders', (tester) async {
      final focusNode = FocusNode();
      final controller = OldAnimatedMoneyFieldController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmountFormatSeparators(
              data: const AmountFormatSeparatorsData(),
              child: Center(
                child: OldAnimatedMoneyField(
                  focusNode: focusNode,
                  controller: controller,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('USD '), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byType(OldAnimatedMoneyField));
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);
      expect(find.byKey(const Key('animated-money-field-cursor')), findsOneWidget);

      final hiddenField = tester.widget<TextField>(find.byKey(const Key('animated-money-field-hidden-input')));
      expect(hiddenField.keyboardType, const TextInputType.numberWithOptions(decimal: true));

      await tester.enterText(find.byKey(const Key('animated-money-field-hidden-input')), '12.');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('USD '), findsAtLeastNWidgets(1));
      expect(find.text('1'), findsAtLeastNWidgets(1));
      expect(find.text('2'), findsAtLeastNWidgets(1));
      expect(find.text('.'), findsAtLeastNWidgets(1));
      expect(find.text('0'), findsAtLeastNWidgets(2));
      expect(find.byType(FittedBox), findsOneWidget);
    });

    testWidgets('backspace removes pending operator and unfocus evaluates expression', (tester) async {
      final focusNode = FocusNode();
      final controller = OldAnimatedMoneyFieldController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: OldAnimatedMoneyField(
                focusNode: focusNode,
                controller: controller,
                contentAnimationDuration: const Duration(milliseconds: 50),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OldAnimatedMoneyField));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('animated-money-field-hidden-input')), '5');
      await tester.pump();

      controller.applyOperator(OldAnimatedMoneyFieldOperator.plus);
      await tester.pump();

      final hiddenBeforeBackspace = tester.widget<TextField>(
        find.byKey(const Key('animated-money-field-hidden-input')),
      );
      expect(hiddenBeforeBackspace.controller!.selection.isCollapsed, isFalse);

      await tester.enterText(find.byKey(const Key('animated-money-field-hidden-input')), '');
      await tester.pump();

      expect(controller.operator, isNull);
      expect(find.text('USD '), findsAtLeastNWidgets(1));

      controller.applyOperator(OldAnimatedMoneyFieldOperator.plus);
      await tester.pump();
      await tester.enterText(find.byKey(const Key('animated-money-field-hidden-input')), '2');
      await tester.pump();

      focusNode.unfocus();
      await tester.pump();

      expect(controller.operator, isNull);
      expect(controller.value.toString(), '7');
      expect(find.text('USD '), findsAtLeastNWidgets(1));
    });

    testWidgets('cursor stays before placeholder decimal digits in arithmetic preview', (tester) async {
      final focusNode = FocusNode();
      final controller = OldAnimatedMoneyFieldController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: OldAnimatedMoneyField(
                focusNode: focusNode,
                controller: controller,
                contentAnimationDuration: Duration.zero,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OldAnimatedMoneyField));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('animated-money-field-hidden-input')), '58');
      await tester.pump();

      controller.applyOperator(OldAnimatedMoneyFieldOperator.plus);
      await tester.pump();

      await tester.enterText(find.byKey(const Key('animated-money-field-hidden-input')), '1.');
      await tester.pump();

      final dotFinder = find.text('.');
      final zeroFinder = find.text('0');
      final equalsFinder = find.text('=');
      final cursorFinder = find.byKey(const Key('animated-money-field-cursor'));

      expect(dotFinder, findsAtLeastNWidgets(1));
      expect(zeroFinder, findsAtLeastNWidgets(2));
      expect(equalsFinder, findsAtLeastNWidgets(1));

      final dotX = tester.getTopLeft(dotFinder.first).dx;
      final cursorXAtDot = tester.getTopLeft(cursorFinder).dx;
      final zeroWidgets = zeroFinder.evaluate().toList();
      final zeroXAtDot = zeroWidgets
          .map((element) => (element.renderObject! as RenderBox).localToGlobal(Offset.zero).dx)
          .reduce((value, element) => value < element ? value : element);
      final equalsXAtDot = tester.getTopLeft(equalsFinder.first).dx;

      expect(dotX, lessThan(cursorXAtDot));
      expect(cursorXAtDot, lessThan(zeroXAtDot));
      expect(zeroXAtDot, lessThan(equalsXAtDot));

      await tester.enterText(find.byKey(const Key('animated-money-field-hidden-input')), '1.2');
      await tester.pump();

      final twoFinder = find.text('2');
      final trailingZeroFinder = find.text('0');

      expect(twoFinder, findsAtLeastNWidgets(1));
      expect(trailingZeroFinder, findsAtLeastNWidgets(1));

      final twoX = tester.getTopLeft(twoFinder.first).dx;
      final cursorXAtTenths = tester.getTopLeft(cursorFinder).dx;
      final zeroXAtTenths = trailingZeroFinder
          .evaluate()
          .map((element) => (element.renderObject! as RenderBox).localToGlobal(Offset.zero).dx)
          .reduce((value, element) => value < element ? value : element);

      expect(twoX, lessThan(cursorXAtTenths));
      expect(cursorXAtTenths, lessThan(zeroXAtTenths));
    });
  });
}
