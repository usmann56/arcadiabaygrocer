import 'package:flutter/material.dart';

class AddItemsPage extends StatelessWidget {
  const AddItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Items')),
      body: const Center(
        child: Text(
          'Add Items screen placeholder\n(Here you will search to add items)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
