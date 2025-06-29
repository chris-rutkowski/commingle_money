// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'amount_editing_controller_screen.dart';
import 'money_editing_controller_screen.dart';

final class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example Menu')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Amount Editing Controller'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AmountEditingControllerScreen()));
            },
          ),
          ListTile(
            title: const Text('Money Editing Controller'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MoneyEditingControllerScreen()));
            },
          ),
        ],
      ),
    );
  }
}
