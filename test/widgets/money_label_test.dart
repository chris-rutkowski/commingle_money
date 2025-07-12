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
    testWidgets('renders simple Text widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        SnapshotWrapper(
          child: MoneyLabel(
            money: Money(
              currencyCode: 'USD',
              amount: Decimal.parse('1234.56'),
            ),
            primaryTextStyle: const TextStyle(fontFamily: 'Noto', fontSize: 30),
            secondaryTextStyle: const TextStyle(fontFamily: 'Noto', fontSize: 15),
            secondaryPadding: const EdgeInsets.only(top: 10),
          ),
        ),
      );

      await expectLater(
        find.byType(SnapshotWrapper),
        matchesGoldenFile('goldens/new.png'),
      );
    });
  });
}

final class SnapshotWrapper extends StatelessWidget {
  final Widget child;

  const SnapshotWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextHeightBehavior(
        textHeightBehavior: const TextHeightBehavior(),
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Noto', fontSize: 16),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
