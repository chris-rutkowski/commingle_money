// ignore_for_file: public_member_api_docs

import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

final class MoneyEditingControllerScreen extends StatefulWidget {
  const MoneyEditingControllerScreen({super.key});

  @override
  State<MoneyEditingControllerScreen> createState() => _MoneyEditingControllerScreenState();
}

final class _MoneyEditingControllerScreenState extends State<MoneyEditingControllerScreen> {
  final controller = MoneyEditingController(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('15.99'));

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
            title: const Text('Money Controller Value'),
            subtitle: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final value = controller.value;

                if (value == null) {
                  return Text('null (currency: ${controller.currencyCode})');
                } else {
                  return Text(controller.value.toString());
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
                    primaryTextStyle: Theme.of(context).textTheme.headlineMedium,
                    money: controller.value ?? Money.zero(controller.currencyCode),
                    positiveColor: Colors.blue,
                    negativeColor: Colors.red,
                    zeroColor: Colors.grey,
                    secondaryPadding: const EdgeInsets.only(top: 10),
                  ),
                ],
              );
            },
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
            title: const Text('Set value: USD 25.15'),
            onTap: () {
              controller.value = Money(currencyCode: CurrencyCodes.usd, amount: Decimal.parse('25.15'));
            },
          ),
          ListTile(
            title: const Text('Set value: null'),
            onTap: () {
              controller.value = null;
            },
          ),
          ListTile(
            title: const Text('Set currency'),
            subtitle: Wrap(
              children: [
                TextButton(
                  onPressed: () => controller.currencyCode = CurrencyCodes.usd,
                  child: const Text('USD: 2'),
                ),
                TextButton(
                  onPressed: () => controller.currencyCode = CurrencyCodes.bhd,
                  child: const Text('BHD: 3'),
                ),
                TextButton(
                  onPressed: () => controller.currencyCode = CurrencyCodes.sgd,
                  child: const Text('SGD: 1'),
                ),
                TextButton(
                  onPressed: () => controller.currencyCode = CurrencyCodes.irr,
                  child: const Text('IRR: 0'),
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
