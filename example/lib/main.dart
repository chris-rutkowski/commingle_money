// ignore_for_file: public_member_api_docs

import 'package:amount_editing_controller/amount_editing_controller.dart';
import 'package:decimal/decimal.dart';
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
      home: const AmountEditingControllerScreen(),
    );
  }
}

final class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example Menu')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Amount Editing Controller'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AmountEditingControllerScreen()));
            },
          ),
        ],
      ),
    );
  }
}

final class AmountEditingControllerScreen extends StatefulWidget {
  const AmountEditingControllerScreen({super.key});

  @override
  State<AmountEditingControllerScreen> createState() => _AmountEditingControllerScreenState();
}

final class _AmountEditingControllerScreenState extends State<AmountEditingControllerScreen> {
  final controller = AmountEditingController(fractionalDigits: 2, amount: Decimal.parse('3532.2312'));

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      debugPrint('Controller value changed: ${controller.value}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Controller value changed!'),
              Text(controller.value.toString()),
            ],
          ),
          duration: Duration(milliseconds: 500),
        ),
      );
    });
  }

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
            title: Text('Amount Controller Value'),
            subtitle: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, child) {
                return Text(value.toString());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16),
            child: Text('Interact:'),
          ),
          ListTile(
            title: Text('Dismiss keyboard'),
            onTap: () {
              FocusScope.of(context).unfocus();
            },
          ),
          ListTile(
            title: Text('Set value: 12345.6789'),
            onTap: () {
              controller.value = Decimal.parse('12345.6789');
            },
          ),
          ListTile(
            title: Text('Set fractional digits'),
            subtitle: Wrap(
              children: [
                TextButton(
                  onPressed: () => controller.fractionalDigits = null,
                  child: const Text('null'),
                ),
                TextButton(
                  onPressed: () => controller.fractionalDigits = 1,
                  child: const Text('1'),
                ),
                TextButton(
                  onPressed: () => controller.fractionalDigits = 2,
                  child: const Text('2'),
                ),
                TextButton(
                  onPressed: () => controller.fractionalDigits = 3,
                  child: const Text('3'),
                ),
                TextButton(
                  onPressed: () => controller.fractionalDigits = 8,
                  child: const Text('8'),
                ),
              ],
            ),
          ),

          // TODO: observe changes delivered by controller
        ],
      ),
    );
  }
}
