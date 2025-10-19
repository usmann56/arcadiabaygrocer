import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../components/category_selector.dart';
import '../components/priority_selector.dart';
import '../components/quantity_selector.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScannerView()),
    );

    if (!mounted) return;
    if (barcode != null) {
      setState(() {
        _barcode = barcode;
        _productName = 'Fetching name...';
        _productDescription = 'Fetching description...';
      });

      await _fetchProductDetails(barcode);

      if (mounted) {
        debugPrint(
          'Added $_productName (barcode: $_barcode) - '
          'Quantity: $_quantity, Category: $_selectedCategory, '
          'Priority: $_selectedPriority, Description: $_productDescription',
        );
      }
    }
  }

  Future<void> _fetchProductDetails(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final product = data['product'];

        if (product != null) {
          setState(() {
            _productName = product['product_name'] ?? 'Unknown product';
            _productDescription = product['generic_name'] ?? '';
          });
        } else {
          debugPrint('Product not found for barcode $barcode');
        }
      } else {
        debugPrint('API error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) debugPrint('Error fetching product: $e');
    }
  }

  void _increment() => setState(() => _quantity++);
  void _decrement() => setState(() {
    if (_quantity > 1) _quantity--;
  });

  void _addToCart() {
    if (_productName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Product name or description is missing!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$_productName ($_quantity × $_selectedCategory, $_selectedPriority) added to cart!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // TODO: add to db
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Scanner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Scan Barcode Button
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
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
            PrioritySelector(
              selectedPriority: _selectedPriority,
              onPrioritySelected: (priority) {
                setState(() => _selectedPriority = priority);
              },
            ),
            const SizedBox(height: 20),
            ProductQuantitySelector(
              quantity: _quantity,
              onIncrement: _increment,
              onDecrement: _decrement,
            ),
            const SizedBox(height: 30),
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

/// Separate widget for scanner view
class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose(); // 🧹 properly dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          final code = capture.barcodes.first.rawValue;
          if (code != null) {
            _controller.stop(); // stop camera before popping
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}
