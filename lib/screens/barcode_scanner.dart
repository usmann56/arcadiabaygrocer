import 'package:flutter/material.dart';
import '../components/category_selector.dart';
import '../components/priority_selector.dart';
import '../components/quantity_selector.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String? _barcode;
  String _productName = '';
  String _productDescription = '';
  String _selectedCategory = 'Meats';
  String _selectedPriority = 'Urgent';
  int _quantity = 1;

  // Simulate scanning and extracting info
  Future<void> _scanBarcode() async {
    // TODO: Replace this simulation with an actual scanner later
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _barcode = '0123456789';
      _productName = 'Coca-Cola 1L';
      _productDescription = 'Refreshing beverage with original taste';
    });
  }

  void _increment() => setState(() => _quantity++);
  void _decrement() => setState(() {
    if (_quantity > 1) _quantity--;
  });

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$_productName ($_quantity × $_selectedCategory, $_selectedPriority) added to cart!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Scanner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1️⃣ Scan Barcode Button
            ElevatedButton.icon(
              onPressed: _scanBarcode,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Barcode'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // 2️⃣ Display scanned details
            if (_barcode != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Barcode: $_barcode',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Product: $_productName'),
                  Text('Description: $_productDescription'),
                ],
              ),

            const SizedBox(height: 20),

            // Category selection
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() => _selectedCategory = category);
              },
            ),

            // Priority selection
            PrioritySelector(
              selectedPriority: _selectedPriority,
              onPrioritySelected: (priority) {
                setState(() => _selectedPriority = priority);
              },
            ),

            const SizedBox(height: 20),

            // Quantity selector
            ProductQuantitySelector(
              quantity: _quantity,
              onIncrement: _increment,
              onDecrement: _decrement,
            ),

            const SizedBox(height: 30),

            // 6️⃣ Add button
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
