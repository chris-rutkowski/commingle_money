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

      await tester.snapshot('initial');

      expect(controller.value, Decimal.parse('3532.23'));
      expect(controllerListenerValue, isNull);
    });
  });
}

extension _Snapshot on WidgetTester {
  Future<void> snapshot(String name) async {
    final sanitized = name
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_') // spaces → underscores
        .replaceAll(RegExp(r'[^\w/]'), ''); // strip non-filename-safe chars

    await expectLater(
      find.byType(SnapshotWrapper),
      matchesGoldenFile('goldens/amount_editing_controller/$sanitized.png'),
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
