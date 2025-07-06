import 'package:commingle_money/commingle_money.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

final class MoneyLabelScreen extends StatefulWidget {
  const MoneyLabelScreen({super.key});

  @override
  State<MoneyLabelScreen> createState() => _MoneyLabelScreenState();
}

final class _MoneyLabelScreenState extends State<MoneyLabelScreen> {
  var fractionalMode = MoneyLabelFractionalMode.flexible;
  var displayCurrency = true;
  var animated = true;
  var isNegative = false;
  var highSlider = 12;
  var lowSlider = 34;
  var decimalSlider = 56;

  Money get currentMoney {
    final whole = highSlider * 100 + lowSlider;
    final fractional = Decimal.fromInt(decimalSlider).shift(-2);
    final total = Decimal.fromInt(whole) + fractional;

    return Money(
      amount: isNegative ? -total : total,
      currencyCode: 'USD',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MoneyLabel')),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFEEEEEE),
            padding: const EdgeInsets.all(32),
            child: Center(
              child: MoneyLabel(
                money: currentMoney,
                animation: animated ? const MoneyLabelAnimation() : null,
                fractionalMode: fractionalMode,
                displayCurrency: displayCurrency,
                positiveColor: Colors.green,
                negativeColor: Colors.red,
                zeroColor: Colors.grey,
                secondaryPadding: const EdgeInsets.only(top: 10),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                  title: const Text('Negative value'),
                  value: isNegative,
                  onChanged: (value) => setState(() => isNegative = value),
                ),

                SliderTile(
                  title: 'Amount ${highSlider}__.__',
                  value: highSlider,
                  onChanged: (x) => setState(() => highSlider = x),
                ),

                SliderTile(
                  title: 'Amount __$lowSlider.__',
                  value: lowSlider,
                  onChanged: (x) => setState(() => lowSlider = x),
                ),
                SliderTile(
                  title: 'Amount ____.${decimalSlider}',
                  value: decimalSlider,
                  onChanged: (x) => setState(() => decimalSlider = x),
                ),
                DropdownButtonFormField<MoneyLabelFractionalMode>(
                  value: fractionalMode,
                  decoration: const InputDecoration(
                    labelText: 'Fractional mode',
                    border: OutlineInputBorder(),
                  ),
                  items: MoneyLabelFractionalMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => fractionalMode = value);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SliderTile extends StatelessWidget {
  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  const SliderTile({
    super.key,
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
