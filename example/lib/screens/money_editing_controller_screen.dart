// ignore_for_file: public_member_api_docs

import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../utils/separators_type.dart';

final class MoneyEditingControllerScreen extends StatefulWidget {
  const MoneyEditingControllerScreen({super.key});

  @override
  State<MoneyEditingControllerScreen> createState() => _MoneyEditingControllerScreenState();
}

final class _MoneyEditingControllerScreenState extends State<MoneyEditingControllerScreen> {
  var separatorsType = SeparatorsType.fromLocalePlus;

  final controller = MoneyEditingController(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('15.99'));

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
      appBar: AppBar(title: const Text('Money Editing Controller')),
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
            title: const Text('Money Controller Value & State'),
            subtitle: ListenableBuilder(
              listenable: Listenable.merge([controller, controller.state]),
              builder: (context, child) {
                final value = controller.value;

                if (value == null) {
                  return Text('null (currency: ${controller.currencyCode}) | ${controller.state.value.name}');
                } else {
                  return Text('${controller.value.toString()} | ${controller.state.value.name}');
                }
              },
            ),
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return Row(
                children: [
                  const SizedBox(width: 16.0),
                  const Text('Money label:'),
                  const SizedBox(width: 16.0),
                  MoneyLabel(
                    separators: separatorsType.resolve(context),
                    primaryTextStyle: Theme.of(context).textTheme.headlineMedium,
                    money: controller.value ?? Money.zero(controller.currencyCode),
                    positiveColor: Colors.blue,
                    negativeColor: Colors.red,
                    zeroColor: Colors.grey,
                  ),
                ],
              );
            },
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
            title: const Text('Set value: 25.15'),
            onTap: () {
              controller.value = Money(currencyCode: controller.currencyCode, amount: Decimal.parse('25.15'));
            },
          ),
          ListTile(
            title: const Text('Set value: 123456.789'),
            onTap: () {
              controller.value = Money(currencyCode: controller.currencyCode, amount: Decimal.parse('123456.789'));
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<CurrencyCode>(
              value: controller.currencyCode,
              decoration: const InputDecoration(
                labelText: 'Currency (each has different precision)',
              ),
              items: [
                CurrencyCodes.usd,
                CurrencyCodes.bhd,
                CurrencyCodes.sgd,
                CurrencyCodes.irr,
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) {
                if (value == null) return;
                controller.currencyCode = value;
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
