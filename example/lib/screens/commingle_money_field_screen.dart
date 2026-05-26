import 'package:commingle_money/commingle_money.dart';
import 'package:flutter/material.dart';

enum _FieldBuilderMode {
  defaultBuilder,
  decorated,
}

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

  final moneyEditingController = MoneyEditingController(
    currencyCode: CurrencyCodes.usd,
  );

  var layout = CommingleMoneyFieldLayout.compact;
  var fieldBuilderMode = _FieldBuilderMode.defaultBuilder;

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

  Widget _buildField(BuildContext context, Widget child) {
    return switch (fieldBuilderMode) {
      _FieldBuilderMode.defaultBuilder => child,
      _FieldBuilderMode.decorated => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: child,
        ),
      ),
    };
  }

  String _fieldBuilderModeLabel(_FieldBuilderMode mode) {
    return switch (mode) {
      _FieldBuilderMode.defaultBuilder => 'default',
      _FieldBuilderMode.decorated => 'decorated',
    };
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
              'This sample showcases the Commingle Money Field. Tap the amount to bring up the keyboard and edit the value with extra arithmetic operators.\n\nTap “USD” to change the currency. This label and currency picker designs are example implementations provided by this sample app.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Center(
              child: CommingleMoneyField(
                placeholder: 'amount',
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
                suffix: ElevatedButton(
                  onPressed: () {
                    moneyEditingController.value = null;
                  },
                  child: const Icon(Icons.clear),
                ),
                layout: layout,
                fieldBuilder: _buildField,
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
              children: MathOperator.values.map((operator) {
                return ElevatedButton(
                  onPressed: () => moneyEditingController.mathOperatorDispatcher.dispatch(operator),
                  child: Text(defaultMathOperatorSymbolResolver(operator)),
                );
              }).toList(),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<CommingleMoneyFieldLayout>(
                initialValue: layout,
                decoration: const InputDecoration(
                  labelText: 'Layout',
                ),
                items: CommingleMoneyFieldLayout.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => layout = value);
                },
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<_FieldBuilderMode>(
                initialValue: fieldBuilderMode,
                decoration: const InputDecoration(
                  labelText: 'Field builder',
                ),
                items: _FieldBuilderMode.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(_fieldBuilderModeLabel(e))))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => fieldBuilderMode = value);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
