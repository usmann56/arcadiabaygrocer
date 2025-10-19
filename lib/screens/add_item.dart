import 'package:flutter/material.dart';
import '../components/category_selector.dart';
import '../components/priority_selector.dart';
import '../components/quantity_selector.dart';

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
    if (_productName.isEmpty || _productDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Product name or description is missing!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
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
