import 'package:flutter/material.dart';
import '../models/checklist_item.dart';
import '../models/cart_item.dart';
import '../dataBase/database_helper.dart'; // For GroceryItem
import 'create_checklist.dart';

/// Screen to view the active checklist and its items
class ViewChecklistPage extends StatefulWidget {
  final SimpleChecklist checklist;
  final List<CartItem> cartItems;

  const ViewChecklistPage({
    super.key,
    required this.checklist,
    required this.cartItems,
  });

  @override
  State<ViewChecklistPage> createState() => _ViewChecklistPageState();
}

class _ViewChecklistPageState extends State<ViewChecklistPage> {
  
  /// Check if a checklist item is in the cart
  bool _isItemInCart(GroceryItem item) {
    return widget.cartItems.any((cartItem) => cartItem.name == item.name);
  }

  /// Show confirmation dialog before creating a new checklist
  Future<void> _showCreateNewChecklistDialog() async {
    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Checklist'),
          content: const Text(
            'Creating a new checklist will overwrite the current one. '
            'Are you sure you want to continue?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Create New'),
            ),
          ],
        );
      },
    );

    if (shouldCreate == true && mounted) {
      // Navigate to create checklist screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateChecklistPage(),
        ),
      );
      
      if (result != null && result is SimpleChecklist && mounted) {
        // Return the new checklist to the main screen
        Navigator.pop(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.checklist.calculateProgress(widget.cartItems);
    final percentage = (progress * 100).round();
    final completedItems = widget.checklist.items.where(_isItemInCart).length;
    final totalItems = widget.checklist.items.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.checklist.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Summary Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Progress: $percentage%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedItems of $totalItems items in cart',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items List
            const Text(
              'Checklist Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: widget.checklist.items.length,
                itemBuilder: (context, index) {
                  final item = widget.checklist.items[index];
                  final isInCart = _isItemInCart(item);
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        isInCart ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isInCart ? Colors.green : Colors.grey,
                        size: 28,
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: isInCart ? TextDecoration.lineThrough : null,
                          color: isInCart ? Colors.grey : Colors.black,
                          fontWeight: isInCart ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isInCart ? Colors.grey : Colors.black87,
                        ),
                      ),
                      trailing: isInCart 
                        ? const Icon(Icons.shopping_cart, color: Colors.green)
                        : const Icon(Icons.shopping_cart_outlined, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Create New Checklist Button
            ElevatedButton.icon(
              onPressed: _showCreateNewChecklistDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create New Checklist'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}