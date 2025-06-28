// ignore_for_file: public_member_api_docs

import 'package:amount_editing_controller/amount_editing_controller.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

final class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const Screen(),
    );
  }
}

final class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

final class _ScreenState extends State<Screen> {
  final controller = AmountEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amount Editing Controller')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Amount Field'),
            subtitle: TextField(
              controller: controller.textController,
              focusNode: controller.focusNode,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          ListTile(
            title: Text('Dismiss keyboard'),
            onTap: () {
              FocusScope.of(context).unfocus();
            },
          ),
          ListTile(
            title: Text('Amount Controller Value'),
            subtitle: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, child) {
                return Text(value.toString());
              },
            ),
          ),
          // TODO: observe changes delivered by controller
        ],
      ),
    );
  }
}
