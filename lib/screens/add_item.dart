import 'package:flutter/material.dart';

class AddItemsPage extends StatefulWidget {
  const AddItemsPage({super.key});

  @override
  State<AddItemsPage> createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _productDescription = '';
  String _productName = '';
  String _selectedCategory = 'Meats';
  String _selectedPriority = 'Urgent';
  int _quantity = 1;
  bool _showSuggestions = false;

  // TODO: Replace with actual suggested results based on search input.
  final List<String> _suggestedResults = ['Coca-Cola', 'Pepsi', 'Sprite'];

  void _increment() {
    setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _addToCart() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$_productName added to cart!')));
    // TODO: Implement actual add to cart logic.
    debugPrint(
      'Added $_productName to cart quantity $_quantity - Category: $_selectedCategory, Priority: $_selectedPriority, Description: $_productDescription',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add to Cart')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Product Name',
                hintText: 'Enter product name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  _showSuggestions = true;
                });
              },
              onChanged: (value) {
                setState(() {
                  _productName = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Product Description
            ProductDescription(
              onDescriptionChanged: (value) {
                setState(() {
                  _productDescription = value;
                  _showSuggestions = true;
                });
              },
            ),
            const SizedBox(height: 20),

            // Suggested Results
            if (_showSuggestions)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggested Results',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._suggestedResults.map((item) {
                    return ListTile(
                      title: Text(item),
                      trailing: const Icon(Icons.add),
                      onTap: () {
                        setState(() {
                          _productName = item;
                          _searchController.text = item;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            const SizedBox(height: 20),

            // Product Category Card Chips
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() => _selectedCategory = category);
              },
            ),

            // Product Priority Card Chips
            PrioritySelector(
              selectedPriority: _selectedPriority,
              onPrioritySelected: (priority) {
                setState(() => _selectedPriority = priority);
              },
            ),

            // Product Quantity (+/- buttons)
            ProductQuantitySelector(
              quantity: _quantity,
              onIncrement: _increment,
              onDecrement: _decrement,
            ),
            const SizedBox(height: 30),

            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDescription extends StatelessWidget {
  final ValueChanged<String> onDescriptionChanged;

  const ProductDescription({super.key, required this.onDescriptionChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Product Description',
              hintText: 'Enter product description',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => onDescriptionChanged(value),
          ),
        ),
      ],
    );
  }
}

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['Meats', 'Produce', 'Beverages', 'Misc'];

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
            children: [
              const Text(
                'Product Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                children: categories.map((c) {
                  final isSelected = selectedCategory == c;
                  return ChoiceChip(
                    label: Text(c, style: const TextStyle(fontSize: 13)),
                    selected: isSelected,
                    selectedColor: Colors.green.shade100,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.green.shade900
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
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

class ProductQuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductQuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onDecrement,
        ),
        Text(
          '$quantity',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onIncrement,
        ),
      ],
    );
  }
}
