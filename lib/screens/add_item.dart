import 'package:flutter/material.dart';
import '../dataBase/grocery_service.dart';
import '../dataBase/database_helper.dart';
import '../models/cart_item.dart';
import '../dataBase/cart_service.dart';
import '../components/category_selector.dart';
import '../components/priority_selector.dart';
import '../components/quantity_selector.dart';
import '../components/due_date_selector.dart';

// Color definitions for consistent styling across the add item screen
const Color _categoryContainerColor =
    Colors.black; // Background for category section
const Color _categoryTextColor = Colors.white; // Text color in category section
const Color _priorityContainerColor =
    Colors.black; // Background for priority section
const Color _priorityTextColor = Colors.white; // Text color in priority section
const Color _addToCartButtonColor =
    Colors.black; // Background for add to cart button

/**
 * AddItemsPage - Screen where users search for and add items to their cart
 * 
 * This screen allows users to:
 * 1. Search for products in the grocery database
 * 2. Select quantity, category, and priority for items
 * 3. Add items to their shopping cart
 * 4. Add optional descriptions for items
 */

class AddItemsPage extends StatefulWidget {
  const AddItemsPage({super.key});

  @override
  State<AddItemsPage> createState() => _AddItemsPageState();
}

/**
 * _AddItemsPageState - Manages the state for the add items screen
 * 
 * Handles user interactions like:
 * - Typing in the search box
 * - Selecting products from search results
 * - Choosing quantity, category, and priority
 * - Adding items to cart
 */
class _AddItemsPageState extends State<AddItemsPage> {
  // Controllers and services
  final TextEditingController _searchController = TextEditingController();
  final CartHelper _cartHelper = CartHelper();
  final TextEditingController _priceController = TextEditingController();

  // User input state variables
  String _productDescription = ''; // Optional description user can add
  String _productName = ''; // Name of the selected product
  double _productPrice = 0.0; // Price of the selected product
  String _selectedCategory = 'Meats'; // User's chosen category (default: Meats)
  String _selectedPriority =
      'Urgent'; // User's chosen priority (default: Urgent)
  int _quantity = 0; // How many items to buy (starts at 0)
  DateTime? _dueDate; // When this item needs to be purchased by

  // UI state variables
  bool _showSuggestions = false; // Whether to show search results
  bool _isLoading = false; // Whether we're currently loading something
  GroceryItem? _selectedGroceryItem; // The product selected from search results

  // Database search results
  List<GroceryItem> _searchResults = []; // List of products matching search

  /**
   * Cleans up resources when the screen is closed
   * 
   * Disposes of the text controller to prevent memory leaks
   */
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /**
   * Searches for products in the grocery database
   * 
   * Takes the user's search text and looks for matching product names
   * Updates the UI to show search results or hide them if no query
   */
  Future<void> _searchProducts(String query) async {
    // Don't search if user hasn't typed anything
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
      // Search the grocery database for matching products
      final results = await GroceryItemsDatabase.searchItems(query);
      setState(() {
        _searchResults = results;
        _showSuggestions =
            results.isNotEmpty; // Only show results if we found something
        _isLoading = false;
      });
    } catch (e) {
      // Handle any database errors gracefully
      setState(() {
        _isLoading = false;
        _showSuggestions = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error searching products: $e')));
    }
  }

  /*
   * Increases the quantity by 1
   * 
   * Called when user taps the + button next to quantity
   */
  void _increment() {
    setState(() => _quantity++);
  }

  /**
   * Decreases the quantity by 1 (minimum of 1)
   * 
   * Called when user taps the - button next to quantity
   * Won't go below 1 because you can't buy zero items
   */
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  /**
   * Adds the selected item to the shopping cart
   * 
   * This function:
   * 1. Validates that required fields are filled
   * 2. Adds the item to the cart database
   * 3. Shows a success message
   * 4. Returns to main screen so user can see updated cart
   */
  Future<void> _addToCart() async {
    // Validate required fields
    if (_productName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a quantity greater than 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading state while adding to cart
      setState(() {
        _isLoading = true;
      });

      // Add item to cart using the cart service
      await _cartHelper.addToCartByName(
        _productName,
        price: _productPrice,
        quantity: _quantity,
        category: _selectedCategory.toLowerCase(),
        priority: _selectedPriority.toLowerCase(),
        description: _productDescription.isEmpty ? null : _productDescription,
        dueDate: _dueDate,
      );

      // If we have a selected grocery item and it doesn't have a category,
      // save the user's category choice for future searches
      if (_selectedGroceryItem != null &&
          _selectedGroceryItem!.category == null) {
        await GroceryItemsDatabase.assignCategoryToItem(
          _selectedGroceryItem!.id!,
          _selectedCategory.toLowerCase(),
        );
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_productName added to cart!'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to main screen with success indicator
      // This tells the main screen to refresh the cart
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            // Search Bar - where users type to find products
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Product Name',
                hintText: 'Enter product name',
                prefixIcon: const Icon(Icons.search),
                // Show loading spinner while searching
                suffixIcon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // When user presses enter, search immediately
              onSubmitted: (value) {
                _searchProducts(value);
              },
              // When user types, update product name and search after a delay
              onChanged: (value) {
                setState(() {
                  _productName = value;
                });
                // Debounced search - wait 500ms after user stops typing
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _searchProducts(value);
                  }
                });
              },
            ),
            const SizedBox(height: 20),

            // Product Description - optional text field for additional notes
            LabeledInputField(
              label: 'Product Description',
              hint: 'Enter product description',
              onChanged: (value) {
                setState(() {
                  _productDescription = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Product Price - text field for product price - keybord type number
            LabeledInputField(
              label: 'Product Price',
              hint: 'Enter produce price',
              keyboardType: TextInputType.number,
              controller: _priceController,
              onChanged: (value) {
                setState(() {
                  _productPrice = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 20),

            // Search Results - shows products that match the user's search
            if (_showSuggestions && _searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Results',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Container with border to visually separate search results
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
          child: Column(
            children: (_searchResults.length > 5
                ? _searchResults.sublist(0, 5)
                : _searchResults)
                            .map((item) {
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                          // Show checkmark if this item is selected, plus icon if not
                          trailing: Icon(
                            _selectedGroceryItem?.id == item.id
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: _selectedGroceryItem?.id == item.id
                                ? Colors.green
                                : Colors.black,
                          ),
                          // When user taps an item, select it and hide suggestions
                          onTap: () {
                            setState(() {
                              _selectedGroceryItem = item;
                              _productName = item.name;
                              _searchController.text = item.name;
                              _showSuggestions = false;
                              _productPrice = item.price;
                              _priceController.text = _productPrice
                                  .toStringAsFixed(2);
                            });
                          },
                        );
                      }).toList(),
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
            const SizedBox(height: 20),

            // Category Selector - let user choose product category (black container)
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() => _selectedCategory = category);
              },
            ),

            // Priority Selector - let user choose item priority (black container)
            PrioritySelector(
              selectedPriority: _selectedPriority,
              onPrioritySelected: (priority) {
                setState(() => _selectedPriority = priority);
              },
            ),

            // Quantity Selector - let user choose how many items to buy
            ProductQuantitySelector(
              quantity: _quantity,
              onIncrement: _increment, // Increase quantity by 1
              onDecrement: _decrement, // Decrease quantity by 1 (min 0)
            ),
            const SizedBox(height: 20),

            // Due Date Selector - let user choose when item needs to be purchased
            DueDateSelector(
              dueDate: _dueDate,
              onDueDateSelected: (date) {
                setState(() => _dueDate = date);
              },
            ),
            const SizedBox(height: 30),

            // Add to Cart Button - main action button (black background)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : _addToCart, // Disable while loading
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  _isLoading ? 'Adding...' : 'Add to Cart',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _addToCartButtonColor, // Black background
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Generic labeled input field widget for product description and product price
// For price it would show a number keyboard
// Price also has a controller to update its value programmatically from search products
class LabeledInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const LabeledInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        controller: controller,
      ),
    );
  }
}

/**
 * CategorySelector - Widget for choosing product category
 * 
 * Displays category options (Meats, Produce, Beverages, Misc) in a 
 * black container with white text. All buttons are arranged in a single row.
 */
class CategorySelector extends StatelessWidget {
  final String selectedCategory; // Currently selected category
  final ValueChanged<String>
  onCategorySelected; // Callback when user selects category

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  /**
   * Builds the category selector UI
   * 
   * Creates a black container with white text containing four category buttons
   * arranged in a single horizontal row
   */
  @override
  Widget build(BuildContext context) {
    final categories = ['Meats', 'Produce', 'Beverages', 'Misc'];

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: _categoryContainerColor, // Black background
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Product Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _categoryTextColor, // White text
                ),
              ),
              const SizedBox(height: 12),
              // Row keeps all buttons on same line
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: categories.map((c) {
                  final isSelected = selectedCategory == c;
                  return Flexible(
                    child: ChoiceChip(
                      label: Text(c, style: const TextStyle(fontSize: 13)),
                      selected: isSelected,
                      selectedColor:
                          Colors.green.shade100, // Light green when selected
                      backgroundColor: Colors.white, // White when not selected
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors
                                  .green
                                  .shade900 // Dark green text when selected
                            : Colors.black87, // Dark text when not selected
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) =>
                          onCategorySelected(c), // Call callback when tapped
                    ),
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

/**
 * PrioritySelector - Widget for choosing item priority
 * 
 * Displays priority options (Urgent, Regular) in a black container with white text.
 * Helps users indicate how important each item is for their shopping trip.
 */
class PrioritySelector extends StatelessWidget {
  final String selectedPriority; // Currently selected priority
  final ValueChanged<String>
  onPrioritySelected; // Callback when user selects priority

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  /**
   * Builds the priority selector UI
   * 
   * Creates a black container with two priority options: Urgent and Regular
   */
  @override
  Widget build(BuildContext context) {
    final priorities = ['Urgent', 'Regular'];

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: _priorityContainerColor, // Black background
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Product Priority',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _priorityTextColor, // White text
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: priorities.map((p) {
                  final isSelected = selectedPriority == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: isSelected,
                    selectedColor:
                        Colors.blue.shade100, // Light blue when selected
                    backgroundColor: Colors.white, // White when not selected
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue.shade900 : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (_) =>
                        onPrioritySelected(p), // Call callback when tapped
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

/**
 * ProductQuantitySelector - Widget for selecting how many items to add
 * 
 * Displays quantity controls with smart button visibility:
 * - Minus button only appears when quantity is 1 or more
 * - Plus button is always visible to allow adding items
 * - Current quantity is displayed between the buttons
 */
class ProductQuantitySelector extends StatelessWidget {
  final int quantity; // Current selected quantity
  final VoidCallback onIncrement; // Called when user taps plus button
  final VoidCallback onDecrement; // Called when user taps minus button

  const ProductQuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  /**
   * Builds the quantity selector UI
   * 
   * Creates a row with:
   * - Minus button (only visible when quantity > 0)
   * - Quantity display
   * - Plus button (always visible)
   */
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Minus button - only show when quantity is 1 or more
        // This prevents users from going below 0 and keeps UI clean when starting
        if (quantity > 0)
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onDecrement,
            tooltip: 'Decrease quantity', // Accessibility hint
          ),
        // If quantity is 0, add spacing to keep layout consistent
        if (quantity == 0)
          const SizedBox(width: 48), // Same width as IconButton
        // Current quantity display - shows how many items are selected
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$quantity',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Plus button - always visible so users can add items
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onIncrement,
          tooltip: 'Increase quantity', // Accessibility hint
        ),
      ],
    );
  }
}
