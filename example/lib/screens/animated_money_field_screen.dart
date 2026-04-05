import 'package:commingle_money/commingle_money.dart';
import 'package:flutter/material.dart';

final class AnimatedMoneyFieldScreen extends StatefulWidget {
  const AnimatedMoneyFieldScreen({super.key});

  @override
  State<AnimatedMoneyFieldScreen> createState() => _AnimatedMoneyFieldScreenState();
}

final class _AnimatedMoneyFieldScreenState extends State<AnimatedMoneyFieldScreen> {
  final focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Animated Money Field')),
      body: ListView(
        children: [
          Center(
            child: AnimatedMoneyField(focusNode: focusNode),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('+'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('-'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('×'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('÷'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('='),
              ),
            ],
          ),
          ElevatedButton(onPressed: focusNode.unfocus, child: const Text('Unfocus')),
        ],
      ),
    );
  }
}
