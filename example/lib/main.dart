// ignore_for_file: public_member_api_docs

import 'package:commingle_money/commingle_money.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:locale_plus/locale_plus.dart';

import 'screens/menu_screen.dart';

void main() async {
  // timeDilation = 5;

  WidgetsFlutterBinding.ensureInitialized();

  final separators = kIsWeb
      ? _separatorsFromPlatformDispatcher()
      : await _separatorsFromLocalePlus();

  runApp(
    MyApp(separators: separators),
  );
}

Future<AmountFormatSeparatorsData> _separatorsFromLocalePlus() async {
  final groupingSeparator = await LocalePlus().getGroupingSeparator() ?? ',';
  final decimalSeparator = await LocalePlus().getDecimalSeparator() ?? '.';

  return AmountFormatSeparatorsData(
    grouping: groupingSeparator,
    decimal: decimalSeparator,
  );
}

AmountFormatSeparatorsData _separatorsFromPlatformDispatcher() {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final formatter = NumberFormat.decimalPattern(locale.toLanguageTag());
  final symbols = formatter.symbols;

  return AmountFormatSeparatorsData(
    grouping: symbols.GROUP_SEP,
    decimal: symbols.DECIMAL_SEP,
  );
}

final class MyApp extends StatelessWidget {
  final AmountFormatSeparatorsData separators;

  const MyApp({
    super.key,
    required this.separators,
  });

  @override
  Widget build(BuildContext context) {
    return AmountFormatSeparators(
      data: separators,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: const MenuScreen(),
      ),
    );
  }
}
