// ignore_for_file: public_member_api_docs

import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

final class AmountEditingControllerScreen extends StatefulWidget {
  const AmountEditingControllerScreen({super.key});

  @override
  State<AmountEditingControllerScreen> createState() => _AmountEditingControllerScreenState();
}

final class _AmountEditingControllerScreenState extends State<AmountEditingControllerScreen> {
  final controller = AmountEditingController(precision: 2, amount: Decimal.parse('3532.2312'));

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
              const Text('Controller value changed!'),
              Text(controller.value.toString()),
            ],
          ),
          duration: const Duration(milliseconds: 500),
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
            title: const Text('Amount Field'),
            subtitle: TextField(
              controller: controller.textController,
              focusNode: controller.focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          ListTile(
            title: const Text('Amount Controller Value'),
            subtitle: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, child) {
                return Text(value.toString());
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16),
            child: Text('Interact:'),
          ),
          ListTile(
            title: const Text('Dismiss keyboard'),
            onTap: () {
              FocusScope.of(context).unfocus();
            },
          ),
          ListTile(
            title: const Text('Set value: 12345.6789'),
            onTap: () {
              controller.value = Decimal.parse('12345.6789');
            },
          ),
          ListTile(
            title: const Text('Set precision digits'),
            subtitle: Wrap(
              children: [
                TextButton(
                  onPressed: () => controller.precision = null,
                  child: const Text('null'),
                ),
                TextButton(
                  onPressed: () => controller.precision = 1,
                  child: const Text('1'),
                ),
                TextButton(
                  onPressed: () => controller.precision = 2,
                  child: const Text('2'),
                ),
                TextButton(
                  onPressed: () => controller.precision = 3,
                  child: const Text('3'),
                ),
                TextButton(
                  onPressed: () => controller.precision = 8,
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
