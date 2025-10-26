import 'package:flutter/material.dart';
import 'screens/add_item.dart';
import 'screens/barcode_scanner.dart';
import 'screens/create_checklist.dart'; // Simple checklist creation
import 'screens/view_checklist.dart'; // View checklist screen
import 'dataBase/cart_service.dart'; // Cart database service
import 'models/cart_item.dart'; // Cart item data model
import 'models/checklist_item.dart'; // Simple checklist model

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
  final CartHelper _cartHelper = CartHelper(); // Cart database service
  List<CartItem> _cartItems = []; // Current items in cart
  bool _isLoading = true; // Whether we're loading cart data
  SimpleChecklist? _activeChecklist; // Current checklist
  bool _urgentReminderInProgress = false; // Prevent duplicate dialogs

  /**
   * Initialize the screen by loading cart items from database
   */
  @override
  void initState() {
    super.initState();
    _loadCartItems(''); // Load cart items when screen opens
  }

  /**
   * Loads cart items from the database
   * 
   * Updates the UI to show current cart contents or handles errors gracefully
   * category filter: empty string loads all items
   */
  Future<void> _loadCartItems(String category) async {
    try {
      final items = await _cartHelper.getCartItemsByCategory(category);
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
      // After loading the cart, check if we need to show an urgent reminder
      if (mounted) {
        _maybeShowUrgentReminder();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading cart: $e')));
    }
  }

  /**
   * Navigates to the Add Item screen
   * 
   * Always refreshes cart when user returns to ensure it's up-to-date
   */
  Future<void> _navigateToAddItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemsPage()),
    );

    // Always reload cart items when returning from add item screen
    // This ensures the main screen shows the most current cart state
    _loadCartItems('');
  }

  /// Shows a one-time per-item popup reminding about urgent items added over a week ago
  Future<void> _maybeShowUrgentReminder() async {
    if (_urgentReminderInProgress) return; // guard against re-entrancy
    // Use a 7-day threshold; items meeting the condition are shown together in one popup
    final urgent = await _cartHelper.getUrgentItemsNeedingReminder(
      const Duration(days: 7),
    );
    if (urgent.isEmpty) return;

    // Build message listing item names
    final names = urgent.map((e) => '• ${e.name}').join('\n');

    if (!mounted) return;
    _urgentReminderInProgress = true;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            "You've marked these items as urgent- need to repurchase?",
          ),
          content: SingleChildScrollView(child: Text(names)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );

    // Mark these items as shown so they won't trigger again
    final ids = urgent
        .where((e) => e.id != null)
        .map((e) => e.id as int)
        .toList();
    await _cartHelper.markUrgentReminderShown(ids);
    _urgentReminderInProgress = false;
  }

  /**
   * Navigates to the Barcode Scanner screen
   * 
   * Always refreshes cart when user returns to ensure it's up-to-date
   */
  Future<void> _navigateToBarcode() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
    );

    // Always reload cart items when returning from barcode scanner
    // This ensures the main screen shows the most current cart state
    _loadCartItems('');
  }

  /**
   * Shows weekly price estimate for items due in the next 7 days
   * 
   * Calculates the total cost of items that have due dates within the next week
   */
  Future<void> _showWeeklyPriceEstimate() async {
    try {
      // Get current date and calculate 7 days from now
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      // Filter items due in the next 7 days
      final itemsDueThisWeek = _cartItems.where((item) {
        if (item.dueDate == null) return false;
        return item.dueDate!.isAfter(now) && item.dueDate!.isBefore(nextWeek);
      }).toList();

      // Calculate total cost
      double totalCost = 0.0;
      for (final item in itemsDueThisWeek) {
        totalCost += (item.price * item.quantity);
      }

      // Show dialog with results
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Weekly Price Estimate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Items due in the next 7 days: ${itemsDueThisWeek.length}'),
              const SizedBox(height: 8),
              Text('Total estimated cost: \$${totalCost.toStringAsFixed(2)}'),
              if (itemsDueThisWeek.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Items due this week:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...itemsDueThisWeek.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '• ${item.name} - \$${(item.price * item.quantity).toStringAsFixed(2)}',
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error calculating estimate: $e')));
    }
  }

  /**
   * Navigates to Create Checklist screen
   */
  Future<void> _navigateToCreateChecklist() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateChecklistPage()),
    );

    if (result != null && result is SimpleChecklist) {
      setState(() {
        _activeChecklist = result;
      });
    }
  }

  /**
   * Handles checklist bar tap - view checklist if active, create if none
   */
  Future<void> _handleChecklistBarTap() async {
    if (_activeChecklist != null) {
      // Navigate to view checklist screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewChecklistPage(
            checklist: _activeChecklist!,
            cartItems: _cartItems,
          ),
        ),
      );

      // If a new checklist was created from the view screen, update it
      if (result != null && result is SimpleChecklist) {
        setState(() {
          _activeChecklist = result;
        });
      }
    } else {
      // No active checklist, navigate to create one
      _navigateToCreateChecklist();
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
                      // Checklist progression tracker
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _activeChecklist == null
                            ? _CreateChecklistButton(
                                onPressed: _navigateToCreateChecklist,
                              )
                            : _ChecklistProgress(
                                checklist: _activeChecklist!,
                                cartItems: _cartItems,
                                onTap: _handleChecklistBarTap,
                              ),
                      ),

                      // Narrow 'filter' container with four buttons
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ActionBar(loadCartItems: _loadCartItems),
                      ),

                      // Large space in the middle for grocery list
                      Expanded(
                        child: _DataList(
                          cartItems: _cartItems,
                          isLoading: _isLoading,
                          onItemRemoved: () => _loadCartItems(''),
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

            // Bottom-center weekly price estimator button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WeeklyEstimatorButton(
                    onPressed: _showWeeklyPriceEstimate,
                  ),
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

class _ActionBar extends StatefulWidget {
  const _ActionBar({this.loadCartItems});
  final Future<void> Function(String category)? loadCartItems;

  @override
  State<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<_ActionBar> {
  String? _selectedCategory;

  Future<void> _handleCategoryTap(String category) async {
    // Toggle logic
    // Need to call load items with empty steing if category is deselected
    final isSameCategory = _selectedCategory == category;

    setState(() {
      _selectedCategory = isSameCategory ? null : category;
    });

    // Call the provided function with empty string if deselected
    if (widget.loadCartItems != null) {
      await widget.loadCartItems!(isSameCategory ? '' : category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: _SmallButton(
              label: 'Meats',
              icon: Icons.agriculture,
              isSelected: _selectedCategory == 'meats',
              onPressed: () => _handleCategoryTap('meats'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SmallButton(
              label: 'Produce',
              icon: Icons.eco_sharp,
              isSelected: _selectedCategory == 'produce',
              onPressed: () => _handleCategoryTap('produce'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SmallButton(
              label: 'Beverages',
              icon: Icons.local_drink,
              isSelected: _selectedCategory == 'beverages',
              onPressed: () => _handleCategoryTap('beverages'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SmallButton(
              label: 'Misc',
              icon: Icons.question_mark_rounded,
              isSelected: _selectedCategory == 'misc',
              onPressed: () => _handleCategoryTap('misc'),
            ),
          ),
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
    this.isSelected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
            : Colors.transparent,
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade400,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.black87,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black87,
            ),
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
    required this.cartItems, // List of items currently in cart
    required this.isLoading, // Whether we're still loading data
    this.onItemRemoved, // Callback when user removes an item
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${item.name} removed from cart')));
      onItemRemoved?.call(); // Trigger cart refresh
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing item: $e')));
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
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                      style: TextStyle(fontSize: 14, color: Colors.grey),
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
                      if (item.description != null &&
                          item.description!.isNotEmpty)
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      if (item.dueDate != null)
                        Text(
                          'Due: ${item.dueDate!.day}/${item.dueDate!.month}/${item.dueDate!.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
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

/// Widget to show "Create Checklist" button with + icon
class _CreateChecklistButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateChecklistButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 24, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  'Create Checklist',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget to show checklist progress
class _ChecklistProgress extends StatelessWidget {
  final SimpleChecklist checklist;
  final List<CartItem> cartItems;
  final VoidCallback onTap;

  const _ChecklistProgress({
    required this.checklist,
    required this.cartItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress using actual cart items
    final progress = checklist.calculateProgress(cartItems);
    final percentage = (progress * 100).round();

    return Column(
      children: [
        // Progress bar (clickable to create new checklist)
        GestureDetector(
          onTap: onTap,
          child: _ProgressTracker(progress: progress),
        ),
        const SizedBox(height: 8),
        // Progress info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Checklist: ${checklist.name}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$percentage% complete',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: progress >= 1.0 ? Colors.green : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        if (progress >= 1.0)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'Checklist Complete!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/**
 * _WeeklyEstimatorButton - Button for calculating weekly price estimates
 * 
 * Displays a button with calculator icon and "Weekly Estimate" text.
 * Styled consistently with other corner buttons but with different colors.
 */
class _WeeklyEstimatorButton extends StatelessWidget {
  const _WeeklyEstimatorButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Blue background to distinguish from other buttons
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: IconButton(
        icon: const Icon(Icons.calculate, color: Colors.white),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
        onPressed: onPressed,
        tooltip: 'Calculate weekly price estimate',
      ),
    );
  }
}
