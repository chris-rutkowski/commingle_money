import 'package:commingle_money/commingle_money.dart';
import 'package:flutter/material.dart';

final class CommingleMoneyFieldScreen extends StatefulWidget {
  const CommingleMoneyFieldScreen({super.key});

  @override
  State<CommingleMoneyFieldScreen> createState() => _CommingleMoneyFieldScreenState();
}

final class _CommingleMoneyFieldScreenState extends State<CommingleMoneyFieldScreen> {
  static const sampleCurrencies = <CurrencyCode>[
    CurrencyCodes.usd,
    CurrencyCodes.eur,
    CurrencyCodes.gbp,
    CurrencyCodes.btc,
    CurrencyCodes.bhd,
  ];

  final mathOperatorDispatcher = MathOperatorDispatcher();
  final moneyEditingController = MoneyEditingController(
    currencyCode: CurrencyCodes.usd,
  );

  @override
  void dispose() {
    moneyEditingController.dispose();
    super.dispose();
  }

  Future<void> _pickCurrency() async {
    final selectedCurrency = await showModalBottomSheet<CurrencyCode>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sampleCurrencies.map((currencyCode) {
              return ListTile(
                title: Text(currencyCode),
                trailing: currencyCode == moneyEditingController.currencyCode ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(currencyCode),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selectedCurrency == null) return;
    moneyEditingController.currencyCode = selectedCurrency;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.w500,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Commingle Money Field')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),
            const Text(
              'This sample showcases the Commingle Money Field. Tap the amount to bring up the keyboard and edit the value with extra arithmetic operators.\n\nTap “USD” to change the currency. The label and picker are sample implementations injected via field’s prefix.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Center(
              child: CommingleMoneyField(
                placeholder: 'amount',
                mathOperatorDispatcher: mathOperatorDispatcher,
                controller: moneyEditingController,
                affixesSpacing: 8,
                textStyle: textStyle?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                prefix: ListenableBuilder(
                  listenable: moneyEditingController,
                  builder: (context, _) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _pickCurrency,
                      child: Text(
                        moneyEditingController.currencyCode,
                        style: textStyle?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
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
                  child: const Text('−'),
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
                ListenableBuilder(
                  listenable: moneyEditingController.focusNode,
                  builder: (context, _) {
                    return ElevatedButton(
                      onPressed: () => moneyEditingController.focusNode.hasFocus
                          ? moneyEditingController.focusNode.unfocus()
                          : moneyEditingController.focusNode.requestFocus(),
                      child: Text(moneyEditingController.focusNode.hasFocus ? 'Unfocus' : 'Focus'),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
