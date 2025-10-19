import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onPrioritySelected;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    final priorities = ['Urgent', 'Regular'];

    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Product Priority',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: priorities.map((p) {
                  final isSelected = selectedPriority == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: isSelected,
                    selectedColor: Colors.blue.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue.shade900 : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (_) => onPrioritySelected(p),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
