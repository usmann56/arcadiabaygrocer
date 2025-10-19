import 'package:flutter/material.dart';
import 'screens/add_item.dart';
import 'screens/barcode_scanner.dart';
import 'dataBase/cart_service.dart';  // Cart database service
import 'models/cart_item.dart';       // Cart item data model

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arcadia Bay Grocer',
      theme: ThemeData(
        // Default accents black; progress bar green
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.black,
          textColor: Colors.black,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Arcadia Bay Grocer'),
    );
  }
}

/**
 * HomePage - Main screen showing the shopping cart
 * 
 * Changed from StatelessWidget to StatefulWidget to manage cart data.
 * Displays the user's shopping list and provides navigation to add items.
 */
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

/**
 * _HomePageState - Manages the shopping cart display and navigation
 * 
 * Handles:
 * - Loading cart items from database
 * - Refreshing cart when user adds/removes items
 * - Navigation to add item and barcode scanner screens
 */
class _HomePageState extends State<HomePage> {
  final CartHelper _cartHelper = CartHelper();  // Cart database service
  List<CartItem> _cartItems = [];               // Current items in cart
  bool _isLoading = true;                       // Whether we're loading cart data

  /**
   * Initialize the screen by loading cart items from database
   */
  @override
  void initState() {
    super.initState();
    _loadCartItems();  // Load cart items when screen opens
  }

  /**
   * Loads cart items from the database
   * 
   * Updates the UI to show current cart contents or handles errors gracefully
   */
  Future<void> _loadCartItems() async {
    try {
      final items = await _cartHelper.getCartItems();
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cart: $e')),
      );
    }
  }

  /**
   * Navigates to the Add Item screen
   * 
   * Refreshes cart when user returns if they added something
   */
  Future<void> _navigateToAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemsPage()),
    );
    
    if (result == true) {
      // Reload cart items if something was added
      _loadCartItems();
    }
  }

  /**
   * Navigates to the Barcode Scanner screen
   * 
   * Refreshes cart when user returns if they scanned and added something
   */
  Future<void> _navigateToBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
    );
    
    if (result == true) {
      // Reload cart items if something was added
      _loadCartItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing so the layout looks consistent on phones and desktops.
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width < 600
        ? 16
        : (width < 1024)
        ? 24
        : 32;
    const double maxContentWidth = 900;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content centered with max width and adaptive padding
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Narrow progression tracker under the title
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: const [
                            // simulated progress for checklist progression bar.
                            _ProgressTracker(progress: 0.45),
                            SizedBox(height: 8),
                            Text(
                              'Progression bar placeholder here - currently at 45%',
                            ),
                          ],
                        ),
                      ),

                      // Narrow 'filter' container with four buttons
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ActionBar(
                          onAddItemPressed: _navigateToAddItem,
                          onBarcodePressed: _navigateToBarcode,
                        ),
                      ),

                      // Large space in the middle for grocery list
                      Expanded(
                        child: _DataList(
                          cartItems: _cartItems,
                          isLoading: _isLoading,
                          onItemRemoved: _loadCartItems,
                        ),
                      ),

                      // Bottom spacer so corner icons don't overlap end of the grocery list
                      const SizedBox(height: 102),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-left shopping cart icon: navigates to Add Items page (placeholder)
            Positioned(
              left: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 12),
                child: _CornerIconButton(
                  key: const ValueKey('bottomLeftIcon'),
                  icon: Icons.add_shopping_cart_rounded,
                  onPressed: _navigateToAddItem,
                ),
              ),
            ),

            // Bottom-right barcode scanner icon: navigates to Barcode Scanner page (placeholder)
            Positioned(
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 32, bottom: 12),
                child: _CornerIconButton(
                  key: const ValueKey('bottomRightIcon'),
                  icon: Icons.barcode_reader,
                  onPressed: _navigateToBarcode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTracker extends StatelessWidget {
  const _ProgressTracker({required this.progress});

  final double progress; // 0.0 - 1.0

  @override
  Widget build(BuildContext context) {
    // Progression bar should be green
    const color = Colors.green;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.6),
        ),
        child: LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: Colors.transparent,
          minHeight: 10,
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    this.onAddItemPressed,
    this.onBarcodePressed,
  });

  final VoidCallback? onAddItemPressed;
  final VoidCallback? onBarcodePressed;

  @override
  Widget build(BuildContext context) {
    // Four placeholder filter buttons.
    final buttons = <Widget>[
      // Button: Meats
      _SmallButton(label: 'Meats', icon: Icons.agriculture, onPressed: () {}),
      // Button: Produce
      _SmallButton(label: 'Produce', icon: Icons.eco_sharp, onPressed: () {}),
      // Button: Beverages
      _SmallButton(
        label: 'Beverages',
        icon: Icons.local_drink,
        onPressed: () {},
      ),
      // Button: Misc
      _SmallButton(
        label: 'Misc',
        icon: Icons.question_mark_rounded,
        onPressed: () {},
      ),
    ];

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          for (int i = 0; i < buttons.length; i++) ...[
            Expanded(child: buttons[i]),
            if (i != buttons.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Button widget for items in the filter row.
    // Using a vertical (column) layout so the label has more room and doesn't overflow.
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/**
 * _DataList - Widget that displays the shopping cart contents
 * 
 * Shows either:
 * - Loading indicator while fetching cart data
 * - Empty state message when cart is empty
 * - List of cart items with details and remove buttons
 */
class _DataList extends StatelessWidget {
  const _DataList({
    required this.cartItems,    // List of items currently in cart
    required this.isLoading,    // Whether we're still loading data
    this.onItemRemoved,         // Callback when user removes an item
  });

  final List<CartItem> cartItems;
  final bool isLoading;
  final VoidCallback? onItemRemoved;

  /**
   * Removes an item from the cart
   * 
   * Called when user taps the delete button on a cart item
   */
  Future<void> _removeItem(BuildContext context, CartItem item) async {
    try {
      await CartHelper().removeFromCart(item.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} removed from cart')),
      );
      onItemRemoved?.call();  // Trigger cart refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item: $e')),
      );
    }
  }

  /**
   * Builds the cart display UI
   * 
   * Shows loading, empty state, or cart items based on current state
   */
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : cartItems.isEmpty
              ? // Empty cart message with helpful instructions
              const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Add groceries to your list',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add to your Cart or use the barcode scanner to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : // List of cart items with details and remove buttons
              ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      // Quantity circle - red for urgent items, grey for regular
                      leading: CircleAvatar(
                        backgroundColor: item.priority == 'urgent' 
                          ? Colors.red.shade100 
                          : Colors.grey.shade200,
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.priority == 'urgent' 
                              ? Colors.red.shade700 
                              : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      // Item name
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      // Item details: price, category, description
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$${item.price.toStringAsFixed(2)} each'),
                          if (item.category != null)
                            Text(
                              item.category!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (item.description != null && item.description!.isNotEmpty)
                            Text(
                              item.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      // Total price and delete button
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeItem(context, item),
                            color: Colors.red.shade600,
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: cartItems.length,
                ),
    );
  }
}

class _CornerIconButton extends StatelessWidget {
  const _CornerIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // white on black background for icon colors
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Padding to add more room inside the pill around icon.
      padding: const EdgeInsets.all(6), // was 6
      // Actual corner icon button widget.
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        // padding inside the icon.
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
        onPressed: onPressed,
        tooltip: 'Hover over (or long press) for button action',
      ),
    );
  }
}
