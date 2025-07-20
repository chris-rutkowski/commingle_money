import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../utils/separators_type.dart';

final class MoneyLabelScreen extends StatefulWidget {
  const MoneyLabelScreen({super.key});

  @override
  State<MoneyLabelScreen> createState() => _MoneyLabelScreenState();
}

final class _MoneyLabelScreenState extends State<MoneyLabelScreen> {
  var separatorsType = SeparatorsType.fromLocalePlus;
  var fractionalMode = FractionalMode.flexible;
  CurrencyCode currency = CurrencyCodes.usd;
  var displayCurrency = true;
  var displayNegativeSign = true;
  var animated = true;
  var isNegative = false;
  var highSlider = 12;
  var mediumSlider = 34;
  var lowSlider = 56;
  var decimalHighSlider = 78;
  var decimalLowSlider = 0;

  Money get money {
    final whole = Decimal.fromInt(highSlider * 10000 + mediumSlider * 100 + lowSlider);
    final fractional = Decimal.fromInt(decimalHighSlider).shift(-2) + Decimal.fromInt(decimalLowSlider).shift(-4);
    final total = whole + fractional;

    return Money(
      amount: isNegative ? -total : total,
      currencyCode: currency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = MoneyFormatter(
      fractionalMode: fractionalMode,
      displayCurrency: displayCurrency,
      displayNegativeSign: displayNegativeSign,
      separators: separatorsType.resolve(context),
      zeroText: 'Ø',
    );
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('MoneyLabel'),
            Text(
              'and MoneyFormatter',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFEEEEEE),
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MoneyLabel(
                    separators: separatorsType.resolve(context),
                    money: money,
                    animation: animated ? const MoneyLabelAnimation() : MoneyLabelAnimation.none,
                    fractionalMode: fractionalMode,
                    displayCurrency: displayCurrency,
                    displayNegativeSign: displayNegativeSign,
                    positiveColor: Colors.blue,
                    negativeColor: Colors.red,
                    zeroColor: Colors.grey,
                    primaryTextStyle: Theme.of(context).textTheme.headlineMedium,
                    zeroText: 'Ø',
                  ),
                  Text(formatter.format(money)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                SwitchListTile(
                  title: const Text('Animated'),
                  value: animated,
                  onChanged: (value) => setState(() => animated = value),
                ),
                SwitchListTile(
                  title: const Text('Display currency'),
                  value: displayCurrency,
                  onChanged: (value) => setState(() => displayCurrency = value),
                ),
                SwitchListTile(
                  title: const Text('Display negative sign'),
                  value: displayNegativeSign,
                  onChanged: (value) => setState(() => displayNegativeSign = value),
                ),
                SwitchListTile(
                  title: const Text('Negative value'),
                  value: isNegative,
                  onChanged: (value) => setState(() => isNegative = value),
                ),

                _SliderTile(
                  title: 'Amount ${highSlider.toString().padLeft(2, '0')}____.____',
                  value: highSlider,
                  onChanged: (x) => setState(() => highSlider = x),
                ),
                _SliderTile(
                  title: 'Amount __${mediumSlider.toString().padLeft(2, '0')}__.____',
                  value: mediumSlider,
                  onChanged: (x) => setState(() => mediumSlider = x),
                ),

                _SliderTile(
                  title: 'Amount ____${lowSlider.toString().padLeft(2, '0')}.____',
                  value: lowSlider,
                  onChanged: (x) => setState(() => lowSlider = x),
                ),
                _SliderTile(
                  title: 'Amount ______.${decimalHighSlider.toString().padLeft(2, '0')}__',
                  value: decimalHighSlider,
                  onChanged: (x) => setState(() => decimalHighSlider = x),
                ),
                _SliderTile(
                  title: 'Amount ______.__${decimalLowSlider.toString().padLeft(2, '0')}',
                  value: decimalLowSlider,
                  onChanged: (x) => setState(() => decimalLowSlider = x),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<CurrencyCode>(
                    value: currency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                    ),
                    items: [CurrencyCodes.usd, CurrencyCodes.bhd, CurrencyCodes.sgd, CurrencyCodes.irr]
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text(e)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => currency = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<FractionalMode>(
                    value: fractionalMode,
                    decoration: const InputDecoration(
                      labelText: 'Fractional mode',
                    ),
                    items: FractionalMode.values
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => fractionalMode = value);
                      }
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
                    items: SeparatorsType.values
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => separatorsType = value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _SliderTile extends StatelessWidget {
  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  const _SliderTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value.toDouble(),
        max: 99,
        onChanged: (x) => onChanged(x.toInt()),
      ),
    );
  }
}
