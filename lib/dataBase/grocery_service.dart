import 'database_helper.dart';

class GroceryItemsDatabase {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all items
  static Future<List<GroceryItem>> getAllItems() async {
    return await _dbHelper.getAllItems();
  }

  // Get item by ID
  static Future<GroceryItem?> getItemById(int id) async {
    return await _dbHelper.getItemById(id);
  }

  // Search items by name
  static Future<List<GroceryItem>> searchItems(String query) async {
    return await _dbHelper.searchItems(query);
  }

  // Get items by category
  static Future<List<GroceryItem>> getItemsByCategory(String category) async {
    return await _dbHelper.getItemsByCategory(category);
  }

  // Additional SQLite-specific methods
  static Future<int> insertItem(GroceryItem item) async {
    return await _dbHelper.insertItem(item);
  }

  static Future<int> updateItem(GroceryItem item) async {
    return await _dbHelper.updateItem(item);
  }

  static Future<int> deleteItem(int id) async {
    return await _dbHelper.deleteItem(id);
  }

  static Future<List<String>> getAllCategories() async {
    return await _dbHelper.getAllCategories();
  }

  // Assign category to an item
  static Future<int> assignCategoryToItem(int itemId, String category) async {
    return await _dbHelper.assignCategoryToItem(itemId, category);
  }
}