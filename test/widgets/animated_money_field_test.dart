import 'package:commingle_money/commingle_money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedMoneyFieldController', () {
    test('sanitizes decimal input and limits fraction digits', () {
      final controller = AnimatedMoneyFieldController();

      controller.replaceEditingText('00012.987');

      expect(controller.leftInput, '12.98');
      expect(controller.rawEditingText, '12.98');
      expect(controller.value.toString(), '12.98');
    });

    test('replaces operator before second operand is entered', () {
      final controller = AnimatedMoneyFieldController()..replaceEditingText('101');

      controller.applyOperator(AnimatedMoneyFieldOperator.plus);
      controller.applyOperator(AnimatedMoneyFieldOperator.minus);

      expect(controller.leftInput, '101');
      expect(controller.rightInput, isEmpty);
      expect(controller.operator, AnimatedMoneyFieldOperator.minus);
      expect(controller.rawEditingText, isEmpty);
    });

    test('evaluates previous expression when another operator is pressed', () {
      final controller = AnimatedMoneyFieldController()..replaceEditingText('101');

      controller.applyOperator(AnimatedMoneyFieldOperator.plus);
      controller.replaceEditingText('1');
      controller.applyOperator(AnimatedMoneyFieldOperator.multiply);

      expect(controller.leftInput, '102');
      expect(controller.rightInput, isEmpty);
      expect(controller.operator, AnimatedMoneyFieldOperator.multiply);
      expect(controller.value.toString(), '102');
    });

    test('equals evaluates expression and trailing operator is dropped', () {
      final controller = AnimatedMoneyFieldController()..replaceEditingText('12');

      controller.applyOperator(AnimatedMoneyFieldOperator.plus);
      controller.evaluate();

      expect(controller.leftInput, '12');
      expect(controller.operator, isNull);

      controller.applyOperator(AnimatedMoneyFieldOperator.plus);
      controller.replaceEditingText('3');
      controller.evaluate();

      expect(controller.leftInput, '15');
      expect(controller.rightInput, isEmpty);
      expect(controller.operator, isNull);
      expect(controller.value.toString(), '15');
    });
  });

  group('AnimatedMoneyField widget', () {
    testWidgets('uses numeric keyboard, shows cursor on focus, and renders decimal placeholders', (tester) async {
      final focusNode = FocusNode();
      final controller = AnimatedMoneyFieldController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmountFormatSeparators(
              data: const AmountFormatSeparatorsData(),
              child: Center(
                child: AnimatedMoneyField(
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

      await tester.tap(find.byType(AnimatedMoneyField));
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);
      expect(find.byKey(const Key('animated-money-field-cursor')), findsOneWidget);

      final hiddenField = tester.widget<TextField>(find.byKey(const Key('animated-money-field-hidden-input')));
      expect(hiddenField.keyboardType, const TextInputType.numberWithOptions(decimal: true));

      await tester.enterText(find.byKey(const Key('animated-money-field-hidden-input')), '12.');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('USD '), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
      expect(find.text('00'), findsOneWidget);
    });
  });
}
