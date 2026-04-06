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
  final controller = AnimatedMoneyFieldController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);
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

  void _applyOperator(AnimatedMoneyFieldOperator operator) {
    controller.applyOperator(operator);
    focusNode.requestFocus();
  }

  void _evaluate() {
    controller.evaluate();
    focusNode.requestFocus();
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
                AnimatedMoneyLabel(
                  money: Money(amount: Decimal.parse('25320'), currencyCode: CurrencyCodes.usd),
                  // money: Money(amount: Decimal.parse('2539.2'), currencyCode: CurrencyCodes.usd),
                  forceFractional: true,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 72),
                  child: AnimatedMoneyField(
                    controller: controller,
                    focusNode: focusNode,
                    cursorBlinkDuration: const Duration(milliseconds: 900),
                    contentAnimationDuration: const Duration(milliseconds: 900),
                    style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
                    secondaryStyle: textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tap the amount, type digits from the numeric keyboard, and use the buttons below for arithmetic.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => _applyOperator(AnimatedMoneyFieldOperator.plus),
                      child: const Text('+'),
                    ),
                    ElevatedButton(
                      onPressed: () => _applyOperator(AnimatedMoneyFieldOperator.minus),
                      child: const Text('-'),
                    ),
                    ElevatedButton(
                      onPressed: () => _applyOperator(AnimatedMoneyFieldOperator.multiply),
                      child: const Text('×'),
                    ),
                    ElevatedButton(
                      onPressed: () => _applyOperator(AnimatedMoneyFieldOperator.divide),
                      child: const Text('÷'),
                    ),
                    ElevatedButton(
                      onPressed: _evaluate,
                      child: const Text('='),
                    ),
                    OutlinedButton(
                      onPressed: focusNode.unfocus,
                      child: const Text('Unfocus'),
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
