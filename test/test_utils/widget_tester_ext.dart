import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterExt on WidgetTester {
  Future<void> type(String text) async {
    await enterText(find.byType(TextField), text);
    await pump();
  }
}
