// ignore_for_file: public_member_api_docs

import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../utils/separators_type.dart';

final class AmountEditingControllerScreen extends StatefulWidget {
  const AmountEditingControllerScreen({super.key});

  @override
  State<AmountEditingControllerScreen> createState() => _AmountEditingControllerScreenState();
}

final class _AmountEditingControllerScreenState extends State<AmountEditingControllerScreen> {
  var separatorsType = SeparatorsType.standard;

  final controller = AmountEditingController(precision: 2, amount: Decimal.parse('3532.2312'));

  @override
  void initState() {
    super.initState();

    controller.separators = separatorsType.resolve(context);

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
            title: const Text('Amount Controller Value & State'),
            subtitle: ListenableBuilder(
              listenable: Listenable.merge([controller, controller.state]),
              builder: (context, child) {
                return Text('${controller.value.toString()} | ${controller.state.value.name}');
              },
            ),
          ),

          ListTile(
            title: const Text('Dismiss keyboard'),
            onTap: () {
              FocusScope.of(context).unfocus();
            },
          ),
          ListTile(
            title: const Text('Set value: null'),
            onTap: () {
              controller.value = null;
            },
          ),
          ListTile(
            title: const Text('Set value: 12345.6789'),
            onTap: () {
              controller.value = Decimal.parse('12345.6789');
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<int?>(
              value: controller.precision,
              decoration: const InputDecoration(
                labelText: 'Precision digits',
              ),
              items: [null, 1, 2, 3, 8].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
              onChanged: (value) {
                controller.precision = value;
              },
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<SeparatorsType>(
              value: separatorsType,
              decoration: const InputDecoration(
                labelText: 'Separators',
              ),
              items: SeparatorsType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => separatorsType = value);
                controller.separators = value.resolve(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
