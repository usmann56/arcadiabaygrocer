import '../dataBase/database_helper.dart';
import '../models/cart_item.dart';

/// Simple checklist model that uses actual database items
class SimpleChecklist {
  final String name;
  final List<GroceryItem> items;

  const SimpleChecklist({
    required this.name,
    required this.items,
  });

  /// Calculate progress based on cart items (0.0 - 1.0)
  double calculateProgress(List<CartItem> cartItems) {
    if (items.isEmpty) return 0.0;
    
    int foundItems = 0;
    for (GroceryItem checklistItem in items) {
      // Check if this grocery item exists in the cart
      bool foundInCart = cartItems.any((cartItem) => 
          cartItem.name.toLowerCase() == checklistItem.name.toLowerCase());
      
      if (foundInCart) {
        foundItems++;
      }
    }
    
    return foundItems / items.length;
  }

  /// Get items that are in checklist but not in cart
  List<GroceryItem> getMissingItems(List<CartItem> cartItems) {
    final missingItems = <GroceryItem>[];
    
    for (GroceryItem checklistItem in items) {
      bool foundInCart = cartItems.any((cartItem) => 
          cartItem.name.toLowerCase() == checklistItem.name.toLowerCase());
      
      if (!foundInCart) {
        missingItems.add(checklistItem);
      }
    }
    
    return missingItems;
  }
}
