import 'package:flutter/material.dart';

class AnimatedMoneyField extends StatefulWidget {
  final String currency;
  final int decimalDigits;
  final FocusNode focusNode;

  const AnimatedMoneyField({
    super.key,
    this.currency = 'USD',
    this.decimalDigits = 2,
    required this.focusNode,
  });

  @override
  State<AnimatedMoneyField> createState() => _AnimatedMoneyFieldState();
}

class _AnimatedMoneyFieldState extends State<AnimatedMoneyField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      width: 100,
      height: 50,
    );
  }
}
