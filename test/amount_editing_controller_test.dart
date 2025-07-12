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
    testWidgets('flow', (WidgetTester tester) async {
      final controller = AmountEditingController(precision: 2, amount: Decimal.parse('3532.2312'));

      Decimal? controllerListenerValue;

      controller.addListener(() {
        controllerListenerValue = controller.value;
      });

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
      await tester.snapshot('initial');
      expect(controller.value, Decimal.parse('3532.23'));
      expect(controller.textController.text, '3,532.23');
      expect(controllerListenerValue, isNull);

      // User modifies
      await tester.type('1234.56');
      await tester.snapshot('1234.56 focused');
      expect(controller.value, Decimal.parse('1234.56'));
      expect(controllerListenerValue, Decimal.parse('1234.56'));
      expect(controller.textController.text, '1234.56');

      // Users dismisses keyboard - value should be formatted
      controllerListenerValue = null;
      await tester.dismissKeyboard(controller);
      await tester.snapshot('1,234.56');
      expect(controller.value, Decimal.parse('1234.56'));
      expect(controllerListenerValue, isNull);

      // App changes precision
      controller.precision = 1;
      await tester.pump();
      await tester.snapshot('1,234.6');
      expect(controllerListenerValue, Decimal.parse('1234.6'));
      expect(controller.textController.text, '1,234.6');
    });
  });
}

extension _WidgetTester on WidgetTester {
  Future<void> snapshot(String name) async {
    final sanitized = name
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_') // spaces → underscores
        .replaceAll(RegExp(r'[^\w/.,]'), ''); // strip non-filename-safe chars

    await expectLater(
      find.byType(SnapshotWrapper),
      matchesGoldenFile('goldens/amount_editing_controller/$sanitized.png'),
    );
  }

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
