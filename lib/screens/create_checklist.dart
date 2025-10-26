import 'package:flutter/material.dart';
import '../models/checklist_item.dart';
import '../dataBase/grocery_service.dart';
import '../dataBase/database_helper.dart';

/// Simple checklist creation screen with grocery database integration
class CreateChecklistPage extends StatefulWidget {
  const CreateChecklistPage({super.key});

  @override
  State<CreateChecklistPage> createState() => _CreateChecklistPageState();
}

class _CreateChecklistPageState extends State<CreateChecklistPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<GroceryItem> _selectedItems = [];
  List<GroceryItem> _searchResults = [];
  bool _showSuggestions = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Search for grocery items in database
  Future<void> _searchItems(String query) async {
    print('Searching for: "$query"'); // Debug output
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSuggestions = false;
      });
      return;
    }

    // Show loading indicator while searching
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await GroceryItemsDatabase.searchItems(query);
      print('Found ${results.length} items'); // Debug output
      setState(() {
        _searchResults = results;
        _showSuggestions = results.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      print('Search error: $e'); // Debug output
      setState(() {
        _searchResults = [];
        _showSuggestions = false;
        _isLoading = false;
      });
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  /// Add selected item to checklist
  void _addItemToChecklist(GroceryItem item) {
    if (!_selectedItems.any((selectedItem) => selectedItem.id == item.id)) {
      setState(() {
        _selectedItems.add(item);
        _searchController.clear();
        _searchResults = [];
        _showSuggestions = false;
      });
    }
  }

  /// Remove item from checklist
  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  /// Create checklist with selected items
  void _createChecklist() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a checklist name')),
      );
      return;
    }
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final checklist = SimpleChecklist(name: name, items: List.from(_selectedItems));
    Navigator.pop(context, checklist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Checklist'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Checklist Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Checklist Name',
                hintText: 'e.g., Weekly Groceries',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Search for grocery items
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Grocery Items',
                hintText: 'e.g., Milk, Bread, Apples...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchItems,
            ),
            const SizedBox(height: 16),

            // Search Results - constrained height to avoid overflow
            if (_showSuggestions && _searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Results',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _searchResults.length > 5 ? 5 : _searchResults.length,
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          final isAlreadySelected = _selectedItems
                              .any((selectedItem) => selectedItem.id == item.id);

                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                            trailing: Icon(
                              isAlreadySelected
                                  ? Icons.check_circle
                                  : Icons.add_circle_outline,
                              color: isAlreadySelected ? Colors.green : Colors.black,
                            ),
                            onTap: isAlreadySelected ? null : () => _addItemToChecklist(item),
                            enabled: !isAlreadySelected,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            // Show "No Results" message if search found nothing
            if (_showSuggestions && _searchResults.isEmpty && !_isLoading)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Results Found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No products found matching your search.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Selected Items List
            if (_selectedItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'No items added yet\nSearch and select items above to build your checklist',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Items (${_selectedItems.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = _selectedItems[index];
                      return Card(
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(index),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Create Button
            ElevatedButton(
              onPressed: _createChecklist,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Create Checklist (${_selectedItems.length} items)'),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
