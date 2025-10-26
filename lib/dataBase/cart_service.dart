import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item.dart';

/**
 * CartHelper - Manages the shopping cart database
 * 
 * This class handles all cart operations like adding items, removing items,
 * and storing cart data permanently using SQLite database.
 * 
 * Uses Singleton pattern so there's only one cart instance throughout the app.
 */
class CartHelper {
  static final CartHelper _instance = CartHelper._internal();
  static Database? _database;
  CartHelper._internal();

  factory CartHelper() {
    return _instance;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /**
   * Initializes the cart database
   */
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cart.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /**
   * Creates the cart table when database is first created
   * Table structure includes:
   * id: unique identifier for each cart item
   * name: product name
   * price: cost per item
   * quantity: how many of this item
   * category: user-assigned category (optional)
   * priority: urgency level (urgent/regular)
   * description: user notes (optional)
   * upc: barcode for scanning (optional)
   */
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT,
        priority TEXT,
        description TEXT,
        upc TEXT,
        added_at INTEGER,
        urgent_reminder_shown INTEGER DEFAULT 0
      )
    ''');
  }

  /**
   * Handles database upgrades when schema changes
   * Currently handles upgrade from version 1 to 2:
   * Adds UPC column for barcode scanner support
   */
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add UPC column for barcode scanner support
      await db.execute('ALTER TABLE cart_items ADD COLUMN upc TEXT');
    }
    if (oldVersion < 3) {
      // Track when items are added
      await db.execute('ALTER TABLE cart_items ADD COLUMN added_at INTEGER');
      // Initialize existing rows with current timestamp
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await db.update('cart_items', {'added_at': nowMs});
    }
    if (oldVersion < 4) {
      // Per-item one-time reminder flag
      await db.execute('ALTER TABLE cart_items ADD COLUMN urgent_reminder_shown INTEGER DEFAULT 0');
    }
  }

  /**
   * Adds an item to the cart by product name
   * 
   * This is the main function for adding items to cart.
   * It handles:
   * Creating new cart entries
   * Updating quantities for existing items
   * Preventing duplicate entries
   * 
   * Parameters:
   * name: product name (required)
   * price: cost per item (optional, defaults to 0.0)
   * quantity: how many to add (optional, defaults to 1)
   * category: user-chosen category (optional)
   * priority: urgency level (optional, defaults to 'regular')
   * description: user notes (optional)
   * upc: barcode for future scanner integration (optional)
   */
  Future<int> addToCartByName(
    String name, {
    double price = 0.0,
    int quantity = 1,
    String? category,
    String? priority = 'regular',
    String? description,
    String? upc,
  }) async {
    final db = await database;

    // Check if item already exists in cart (by name)
    final List<Map<String, dynamic>> existing = await db.query(
      'cart_items',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (existing.isNotEmpty) {
      // Item exists - update the quantity instead of creating duplicate
      final existingItem = existing.first;
      final newQuantity = (existingItem['quantity'] as int) + quantity;

      return await db.update(
        'cart_items',
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [existingItem['id']],
      );
    } else {
      // Item doesn't exist - create new cart entry
      final cartItem = CartItem(
        name: name,
        price: price,
        quantity: quantity,
        category: category,
        priority: priority ?? 'regular',
        description: description,
        upc: upc,
        addedAt: DateTime.now(),
        urgentReminderShown: false,
      );

      return await db.insert('cart_items', cartItem.toMap());
    }
  }

  /**
   * Gets all items currently in the shopping cart
   * Returns a list of CartItem objects representing everything
   * the user has added to their cart. Used for displaying
   * the cart contents on the main screen.
   */
  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart_items');

    return List.generate(maps.length, (i) {
      return CartItem.fromMap(maps[i]);
    });
  }

  /**
   * Gets cart items filtered by category
   * If category is empty, returns all items
   */
  Future<List<CartItem>> getCartItemsByCategory(String category) async {
    final db = await database;

    if (category.isEmpty) {
      return await getCartItems();
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'cart_items',
      where: 'category = ?',
      whereArgs: [category.toLowerCase()],
    );

    return List.generate(maps.length, (i) {
      return CartItem.fromMap(maps[i]);
    });
  }

  /// Returns urgent items whose added_at is older than [threshold]
  Future<List<CartItem>> getUrgentItemsNeedingReminder(Duration threshold) async {
    final db = await database;
    final cutoffMs = DateTime.now().subtract(threshold).millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      'cart_items',
      where: "LOWER(priority) = 'urgent' AND added_at IS NOT NULL AND added_at <= ? AND (urgent_reminder_shown IS NULL OR urgent_reminder_shown = 0)",
      whereArgs: [cutoffMs],
    );

    return List.generate(maps.length, (i) => CartItem.fromMap(maps[i]));
  }

  /// Marks urgent reminder as shown for the given item IDs
  Future<void> markUrgentReminderShown(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    for (final id in ids) {
      batch.update(
        'cart_items',
        {'urgent_reminder_shown': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  /**
   * Removes an item completely from the cart
   * This deletes the entire cart entry for the given item ID.
   * Used when user taps the delete button on a cart item.
   */
  Future<int> removeFromCart(int id) async {
    final db = await database;
    return await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  /**
   * Clears all items from the cart
   * Removes everything from the shopping cart.
   * Useful for "start over" functionality or after checkout.
   */
  Future<int> clearCart() async {
    final db = await database;
    return await db.delete('cart_items');
  }

  /**
   * Updates the quantity of a specific cart item
   * Allows changing how many of an item the user wants to buy
   * without removing and re-adding the item.
   */
  Future<int> updateQuantity(int id, int newQuantity) async {
    final db = await database;

    if (newQuantity <= 0) {
      // If quantity is 0 or negative, remove the item entirely
      return await removeFromCart(id);
    }

    return await db.update(
      'cart_items',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /**
   * Gets the total cost of all items in the cart
   * Calculates: (price × quantity) for each item, then sums them up.
   * Returns the grand total for the entire shopping cart.
   */
  Future<double> getCartTotal() async {
    final items = await getCartItems();
    double total = 0.0;

    for (final item in items) {
      total += (item.price * item.quantity);
    }

    return total;
  }

  /**
   * Gets the total number of items in the cart
   * Counts all individual items (accounting for quantities).
   * For example: 3 apples + 2 oranges = 5 total items.
   */
  Future<int> getCartItemCount() async {
    final items = await getCartItems();
    int count = 0;

    for (final item in items) {
      count += item.quantity;
    }

    return count;
  }
}
