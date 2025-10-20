class GroceryItem {
  final int id;
  final String name;
  final double price;

  GroceryItem({
    required this.id,
    required this.name,
    required this.price,
  });
}

class GroceryItemsDatabase {
  static List<GroceryItem> groceryItems = [
    // Meats
    GroceryItem(id: 1, name: 'Ground Beef (per LB)', price: 5.99),
    GroceryItem(id: 2, name: 'Chicken Breast', price: 4.99),
    GroceryItem(id: 3, name: 'Pork Chops', price: 6.49),
    GroceryItem(id: 4, name: 'Salmon Fillet', price: 12.99),
    GroceryItem(id: 5, name: 'Sliced Turkey (per LB)', price: 3.99),
    GroceryItem(id: 6, name: 'Bacon', price: 7.99),
    GroceryItem(id: 7, name: 'Italian Sausage', price: 5.49),
    GroceryItem(id: 8, name: 'Ribeye Steak (per LB)', price: 15.99),

    // Produce
    GroceryItem(id: 9, name: 'Bananas (per LB)', price: 1.29),
    GroceryItem(id: 10, name: 'Apples (per LB)', price: 3.99),
    GroceryItem(id: 11, name: 'Carrots', price: 1.99),
    GroceryItem(id: 12, name: 'Broccoli', price: 2.49),
    GroceryItem(id: 13, name: 'Spinach', price: 2.99),
    GroceryItem(id: 14, name: 'Tomatoes (per LB)', price: 2.79),
    GroceryItem(id: 15, name: 'Potatoes', price: 4.99),
    GroceryItem(id: 16, name: 'Onions', price: 2.49),
    GroceryItem(id: 17, name: 'Bell Peppers', price: 3.49),
    GroceryItem(id: 18, name: 'Lettuce', price: 1.99),
    GroceryItem(id: 19, name: 'Avocados', price: 4.99),
    GroceryItem(id: 20, name: 'Strawberries (per LB)', price: 3.99),

    // Beverages
    GroceryItem(id: 21, name: 'Coca-Cola', price: 5.99),
    GroceryItem(id: 22, name: 'Pepsi', price: 5.99),
    GroceryItem(id: 23, name: 'Orange Juice', price: 3.49),
    GroceryItem(id: 24, name: 'Milk', price: 3.99),
    GroceryItem(id: 25, name: 'Coffee', price: 8.99),
    GroceryItem(id: 26, name: 'Bottled Water', price: 4.99),
    GroceryItem(id: 27, name: 'Energy Drink', price: 7.99),
    GroceryItem(id: 28, name: 'Apple Juice', price: 2.99),
    GroceryItem(id: 29, name: 'Beer', price: 8.99),
    GroceryItem(id: 30, name: 'Wine', price: 12.99),

    // Misc
    GroceryItem(id: 31, name: 'Bread', price: 2.49),
    GroceryItem(id: 32, name: 'Eggs', price: 2.99),
    GroceryItem(id: 33, name: 'Butter', price: 4.49),
    GroceryItem(id: 34, name: 'Cheese', price: 3.99),
    GroceryItem(id: 35, name: 'Yogurt', price: 4.99),
    GroceryItem(id: 36, name: 'Rice', price: 3.49),
    GroceryItem(id: 37, name: 'Pasta', price: 1.99),
    GroceryItem(id: 38, name: 'Cereal', price: 4.99),
    GroceryItem(id: 39, name: 'Peanut Butter', price: 3.99),
    GroceryItem(id: 40, name: 'Olive Oil', price: 6.99),
    GroceryItem(id: 41, name: 'Salt', price: 1.49),
    GroceryItem(id: 42, name: 'Sugar', price: 3.49),
    GroceryItem(id: 43, name: 'Flour', price: 2.99),
    GroceryItem(id: 44, name: 'Canned Tomatoes', price: 1.29),
    GroceryItem(id: 45, name: 'Chicken Broth', price: 1.99),
    GroceryItem(id: 46, name: 'Frozen Pizza', price: 4.99),
    GroceryItem(id: 47, name: 'Ice Cream', price: 5.99),
    GroceryItem(id: 48, name: 'Frozen Vegetables', price: 2.49),
    GroceryItem(id: 49, name: 'Toilet Paper', price: 8.99),
    GroceryItem(id: 50, name: 'Paper Towels', price: 7.99),
    GroceryItem(id: 51, name: 'Dish Soap', price: 2.99),
    GroceryItem(id: 52, name: 'Laundry Detergent', price: 9.99),
  ];

  // Get all items
  static List<GroceryItem> getAllItems() {
    return groceryItems;
  }

  // Get item by ID
  static GroceryItem? getItemById(int id) {
    try {
      return groceryItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search items by name
  static List<GroceryItem> searchItems(String query) {
    if (query.isEmpty) return groceryItems;
    
    return groceryItems
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get items by category (based on ID ranges)
  static List<GroceryItem> getItemsByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'meats':
        return groceryItems.where((item) => item.id >= 1 && item.id <= 8).toList();
      case 'produce':
        return groceryItems.where((item) => item.id >= 9 && item.id <= 20).toList();
      case 'beverages':
        return groceryItems.where((item) => item.id >= 21 && item.id <= 30).toList();
      case 'misc':
        return groceryItems.where((item) => item.id >= 31 && item.id <= 52).toList();
      default:
        return groceryItems;
    }
  }
}