// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'screens/menu_screen.dart';

void main() {
  // timeDilation = 5;
  runApp(const MyApp());
}

final class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const MenuScreen(),
    );
  }
}
