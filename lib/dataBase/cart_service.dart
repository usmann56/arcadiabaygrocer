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
  // Singleton pattern - ensures only one instance exists
  static final CartHelper _instance = CartHelper._internal();
  static Database? _database;
  CartHelper._internal();

  // Factory constructor returns the same instance every time
  factory CartHelper() {
    return _instance;
  }

  /**
   * Gets the database instance
   * Creates the database if it doesn't exist yet
   */
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /**
   * Initializes the cart database
   * Creates a new database file called 'cart.db'
   */
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cart.db');
    
    try {
      await deleteDatabase(path);
    } catch (e) {
    }
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /**
   * Creates the cart table when database is first created
   * 
   * Table structure includes:
   * - id: unique identifier for each cart item
   * - name: product name
   * - price: cost per item
   * - quantity: how many of this item
   * - category: user-assigned category (optional)
   * - priority: urgency level (urgent/regular)
   * - description: user notes (optional)
   * - upc: barcode for scanning (optional)
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
        upc TEXT
      )
    ''');
  }

  /**
   * Handles database upgrades when schema changes
   * 
   * Currently handles upgrade from version 1 to 2:
   * - Adds UPC column for barcode scanner support
   */
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add UPC column for barcode scanner support
      await db.execute('ALTER TABLE cart_items ADD COLUMN upc TEXT');
    }
  }

  /**
   * Adds an item to the cart by product name
   * 
   * This is the main function for adding items to cart.
   * It handles:
   * - Creating new cart entries
   * - Updating quantities for existing items
   * - Preventing duplicate entries
   * 
   * Parameters:
   * - name: product name (required)
   * - price: cost per item (optional, defaults to 0.0)
   * - quantity: how many to add (optional, defaults to 1)
   * - category: user-chosen category (optional)
   * - priority: urgency level (optional, defaults to 'regular')
   * - description: user notes (optional)
   * - upc: barcode for future scanner integration (optional)
   */
  Future<int> addToCartByName(String name, {
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
      );
      
      return await db.insert('cart_items', cartItem.toMap());
    }
  }

  /**
   * Gets all items currently in the shopping cart
   * 
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
   * Removes an item completely from the cart
   * 
   * This deletes the entire cart entry for the given item ID.
   * Used when user taps the delete button on a cart item.
   */
  Future<int> removeFromCart(int id) async {
    final db = await database;
    return await db.delete(
      'cart_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /**
   * Clears all items from the cart
   * 
   * Removes everything from the shopping cart.
   * Useful for "start over" functionality or after checkout.
   */
  Future<int> clearCart() async {
    final db = await database;
    return await db.delete('cart_items');
  }

  /**
   * Updates the quantity of a specific cart item
   * 
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
   * 
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
   * 
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