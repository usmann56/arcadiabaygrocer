import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GroceryItem {
  final int? id;
  final String name;
  final double price;
  final String? category;

  GroceryItem({
    this.id,
    required this.name,
    required this.price,
    this.category,
  });

  // Convert a GroceryItem into a Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price, 'category': category};
  }

  // Create a GroceryItem from a Map
  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      category: map['category'],
    );
  }

  @override
  String toString() {
    return 'GroceryItem{id: $id, name: $name, price: $price, category: $category}';
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'grocery_items.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE grocery_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT
      )
    ''');

    // Insert prebuilt grocery items into the table
    await _insertPrebuiltItems(db);
  }

  Future<void> _insertPrebuiltItems(Database db) async {
    List<Map<String, dynamic>> prebuiltItems = [
      // Items without predefined categories - users assign them
      {'name': 'Ground Beef (per LB)', 'price': 5.99},
      {'name': 'Chicken Breast', 'price': 4.99},
      {'name': 'Pork Chops', 'price': 6.49},
      {'name': 'Salmon Fillet', 'price': 12.99},
      {'name': 'Sliced Turkey (per LB)', 'price': 3.99},
      {'name': 'Bacon', 'price': 7.99},
      {'name': 'Italian Sausage', 'price': 5.49},
      {'name': 'Ribeye Steak (per LB)', 'price': 15.99},
      {'name': 'Bananas (per LB)', 'price': 1.29},
      {'name': 'Apples (per LB)', 'price': 3.99},
      {'name': 'Carrots', 'price': 1.99},
      {'name': 'Broccoli', 'price': 2.49},
      {'name': 'Spinach', 'price': 2.99},
      {'name': 'Tomatoes (per LB)', 'price': 2.79},
      {'name': 'Potatoes', 'price': 4.99},
      {'name': 'Onions', 'price': 2.49},
      {'name': 'Bell Peppers', 'price': 3.49},
      {'name': 'Lettuce', 'price': 1.99},
      {'name': 'Avocados', 'price': 4.99},
      {'name': 'Strawberries (per LB)', 'price': 3.99},
      {'name': 'Coca-Cola', 'price': 5.99},
      {'name': 'Pepsi', 'price': 5.99},
      {'name': 'Orange Juice', 'price': 3.49},
      {'name': 'Milk', 'price': 3.99},
      {'name': 'Coffee', 'price': 8.99},
      {'name': 'Bottled Water', 'price': 4.99},
      {'name': 'Energy Drink', 'price': 7.99},
      {'name': 'Apple Juice', 'price': 2.99},
      {'name': 'Beer', 'price': 8.99},
      {'name': 'Wine', 'price': 12.99},
      {'name': 'Bread', 'price': 2.49},
      {'name': 'Eggs', 'price': 2.99},
      {'name': 'Butter', 'price': 4.49},
      {'name': 'Cheese', 'price': 3.99},
      {'name': 'Yogurt', 'price': 4.99},
      {'name': 'Rice', 'price': 3.49},
      {'name': 'Pasta', 'price': 1.99},
      {'name': 'Cereal', 'price': 4.99},
      {'name': 'Peanut Butter', 'price': 3.99},
      {'name': 'Olive Oil', 'price': 6.99},
      {'name': 'Salt', 'price': 1.49},
      {'name': 'Sugar', 'price': 3.49},
      {'name': 'Flour', 'price': 2.99},
      {'name': 'Canned Tomatoes', 'price': 1.29},
      {'name': 'Chicken Broth', 'price': 1.99},
      {'name': 'Frozen Pizza', 'price': 4.99},
      {'name': 'Ice Cream', 'price': 5.99},
      {'name': 'Frozen Vegetables', 'price': 2.49},
      {'name': 'Toilet Paper', 'price': 8.99},
      {'name': 'Paper Towels', 'price': 7.99},
      {'name': 'Dish Soap', 'price': 2.99},
      {'name': 'Laundry Detergent', 'price': 9.99},
    ];

    Batch batch = db.batch();
    for (var item in prebuiltItems) {
      batch.insert('grocery_items', item);
    }
    await batch.commit();
  }

  // Get all items
  Future<List<GroceryItem>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('grocery_items');

    return List.generate(maps.length, (i) {
      return GroceryItem.fromMap(maps[i]);
    });
  }

  // Get item by ID
  Future<GroceryItem?> getItemById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grocery_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return GroceryItem.fromMap(maps.first);
    }
    return null;
  }

  // Search items by name
  Future<List<GroceryItem>> searchItems(String query) async {
    final db = await database;
    if (query.isEmpty) {
      return await getAllItems();
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'grocery_items',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) {
      return GroceryItem.fromMap(maps[i]);
    });
  }

  // Get items by category
  Future<List<GroceryItem>> getItemsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grocery_items',
      where: 'category = ?',
      whereArgs: [category.toLowerCase()],
    );

    return List.generate(maps.length, (i) {
      return GroceryItem.fromMap(maps[i]);
    });
  }

  // Assign category to an item
  Future<int> assignCategoryToItem(int itemId, String category) async {
    final db = await database;
    return await db.update(
      'grocery_items',
      {'category': category.toLowerCase()},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  // Insert new item
  Future<int> insertItem(GroceryItem item) async {
    final db = await database;
    return await db.insert('grocery_items', item.toMap());
  }

  // Update item
  Future<int> updateItem(GroceryItem item) async {
    final db = await database;
    return await db.update(
      'grocery_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete item
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('grocery_items', where: 'id = ?', whereArgs: [id]);
  }

  // Get all categories (excluding null/empty categories)
  Future<List<String>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM grocery_items WHERE category IS NOT NULL AND category != "" ORDER BY category',
    );

    return List.generate(maps.length, (i) {
      return maps[i]['category'] as String;
    });
  }
}
