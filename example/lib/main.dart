// ignore_for_file: public_member_api_docs

import 'package:commingle_money/commingle_money.dart';
import 'package:flutter/material.dart';
import 'package:locale_plus/locale_plus.dart';

import 'screens/menu_screen.dart';

void main() async {
  // timeDilation = 5;

  WidgetsFlutterBinding.ensureInitialized();

  final groupingSeparator = await LocalePlus().getGroupingSeparator() ?? ',';
  final decimalSeparator = await LocalePlus().getDecimalSeparator() ?? '.';

  runApp(
    MyApp(
      separators: AmountFormatSeparatorsData(
        grouping: groupingSeparator,
        decimal: decimalSeparator,
      ),
    ),
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
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        home: const MenuScreen(),
      ),
    );
  }
}
