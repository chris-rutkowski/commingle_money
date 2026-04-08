import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

final class CommingleMoneyFieldScreen extends StatefulWidget {
  const CommingleMoneyFieldScreen({super.key});

  @override
  State<CommingleMoneyFieldScreen> createState() => _CommingleMoneyFieldScreenState();
}

final class _CommingleMoneyFieldScreenState extends State<CommingleMoneyFieldScreen> {
  final focusNode = FocusNode();
  final mathOperatorDispatcher = MathOperatorDispatcher();
  late final MoneyEditingController moneyEditingController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    moneyEditingController = MoneyEditingController(
      currencyCode: CurrencyCodes.usd,
      // amount: null,
      separators: AmountFormatSeparators.read(context),
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    moneyEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commingle Money Field')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommingleMoneyField(
                  mathOperatorDispatcher: mathOperatorDispatcher,
                  moneyController: moneyEditingController,
                  focusNode: focusNode,
                  affixesSpacing: 16,
                  textStyle: const TextStyle(
                    // overwriting Headline Large properties
                    fontWeight: FontWeight.bold,
                  ),
                  prefix: const Text('Prefix'),
                  suffix: const Text('Suffix'),
                ),

                const SizedBox(height: 4),

                ListenableBuilder(
                  listenable: moneyEditingController,
                  builder: (context, child) {
                    return Text(
                      moneyEditingController.value == null
                          ? 'Current value: ${moneyEditingController.currencyCode} null'
                          : 'Current value: ${moneyEditingController.value.toString()}',
                      textAlign: TextAlign.center,
                    );
                  },
                ),

                const SizedBox(height: 16),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => mathOperatorDispatcher.handle(MathOperator.plus),
                      child: const Text('+'),
                    ),
                    ElevatedButton(
                      onPressed: () => mathOperatorDispatcher.handle(MathOperator.minus),
                      child: const Text('-'),
                    ),
                    ElevatedButton(
                      onPressed: () => mathOperatorDispatcher.handle(MathOperator.multiply),
                      child: const Text('×'),
                    ),
                    ElevatedButton(
                      onPressed: () => mathOperatorDispatcher.handle(MathOperator.divide),
                      child: const Text('÷'),
                    ),
                    ElevatedButton(
                      onPressed: () => mathOperatorDispatcher.handle(MathOperator.equal),
                      child: const Text('='),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: focusNode.unfocus,
                      child: const Text('Unfocus'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

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
                      onPressed: () => moneyEditingController.value = Money(
                        amount: Decimal.parse('1.234'),
                        currencyCode: CurrencyCodes.bhd,
                      ),
                      child: const Text('BHD 1.234'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
