import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

final class AnimatedMoneyFieldScreen extends StatefulWidget {
  const AnimatedMoneyFieldScreen({super.key});

  @override
  State<AnimatedMoneyFieldScreen> createState() => _AnimatedMoneyFieldScreenState();
}

final class _AnimatedMoneyFieldScreenState extends State<AnimatedMoneyFieldScreen> {
  final focusNode = FocusNode();
  final controller = OldAnimatedMoneyFieldController();
  final operationController = AwesomeMoneyFieldMathController();
  late final MoneyEditingController moneyEditingController;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);

    // moneyEditingController = MoneyEditingController(
    //   currencyCode: CurrencyCodes.btc,
    //   amount: Decimal.parse('1'),
    //   separators: AmountFormatSeparators.read(context),
    // );

    moneyEditingController = MoneyEditingController(
      currencyCode: CurrencyCodes.btc,
      amount: Decimal.zero,
      separators: AmountFormatSeparators.read(context),
    );
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Animated Money Field')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const SizedBox(
                //   // width: 200,
                //   child: AnimatedMoneyLabel(
                //     // money: Money(amount: Decimal.parse('0'), currencyCode: CurrencyCodes.usd),
                //     money: null,
                //     // money: Money(amount: Decimal.parse('2539.2'), currencyCode: CurrencyCodes.usd),
                //     forceFractional: true,
                //     showCursor: true,
                //     placeholder: '0',
                //   ),
                // ),
                AwesomeMoneyField(
                  operationController: operationController,
                  moneyController: moneyEditingController,
                  focusNode: focusNode,
                  prefix: const Text('Prefix '),
                  suffix: const Text(' Suffix'),
                ),
                ListenableBuilder(
                  listenable: moneyEditingController,
                  builder: (context, child) {
                    return Text('Current value: ${moneyEditingController.value}');
                  },
                ),
                // ConstrainedBox(
                //   constraints: const BoxConstraints(minHeight: 72),
                //   child: OldAnimatedMoneyField(
                //     controller: controller,
                //     focusNode: focusNode,
                //     cursorBlinkDuration: const Duration(milliseconds: 900),
                //     contentAnimationDuration: const Duration(milliseconds: 900),
                //     style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
                //     secondaryStyle: textTheme.titleLarge,
                //   ),
                // ),
                const SizedBox(height: 16),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => operationController.handle(AwesomeMoneyFieldButton.plus),
                      child: const Text('+'),
                    ),
                    ElevatedButton(
                      onPressed: () => operationController.handle(AwesomeMoneyFieldButton.minus),
                      child: const Text('-'),
                    ),
                    ElevatedButton(
                      onPressed: () => operationController.handle(AwesomeMoneyFieldButton.multiply),
                      child: const Text('×'),
                    ),
                    ElevatedButton(
                      onPressed: () => operationController.handle(AwesomeMoneyFieldButton.divide),
                      child: const Text('÷'),
                    ),
                    ElevatedButton(
                      onPressed: () => operationController.handle(AwesomeMoneyFieldButton.equal),
                      child: const Text('='),
                    ),
                    OutlinedButton(
                      onPressed: focusNode.unfocus,
                      child: const Text('Unfocus'),
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => moneyEditingController.value = Money(
                        amount: Decimal.parse('23.12'),
                        currencyCode: CurrencyCodes.usd,
                      ),
                      child: const Text('USD 23.12'),
                    ),
                    ElevatedButton(
                      onPressed: () => moneyEditingController.value = Money(
                        amount: Decimal.parse('15.4234'),
                        currencyCode: CurrencyCodes.btc,
                      ),
                      child: const Text('BTC 15.4234'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        moneyEditingController.currencyCode = CurrencyCodes.usd;
                        moneyEditingController.value = null;
                      },
                      child: const Text('USD null'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Current value: ${controller.value}',
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
