import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final Color? containerColor;
  final Color? textColor;
  final Color? labelColor;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.containerColor,
    this.textColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['Meats', 'Produce', 'Beverages', 'Misc'];

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: containerColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Product Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: labelColor ?? textColor ?? Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                children: categories.map((c) {
                  final isSelected = selectedCategory == c;
                  return ChoiceChip(
                    label: Text(c, style: TextStyle(fontSize: 13, color: textColor ?? (isSelected ? Colors.green.shade900 : Colors.black87))),
                    selected: isSelected,
                    selectedColor: Colors.green.shade100,
                    labelStyle: TextStyle(
                      color: textColor ?? (isSelected ? Colors.green.shade900 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => onCategorySelected(c),
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
