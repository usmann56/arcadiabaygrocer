/**
 * CartItem - Represents a single item in the shopping cart
 * 
 * This class holds all the information about an item that the user
 * wants to buy, including what it is, how much it costs, and user preferences.
 */
class CartItem {
  final int? id; // Unique database ID (null for new items)
  final String name; // Product name (e.g., "Bananas")
  final String? upc; // Barcode/UPC code for barcode scanner
  final double price; // Price per item in dollars
  final String? category; // User-assigned category ("meats", "produce", etc.)
  final String priority; // How important this item is ("urgent" or "regular")
  final int quantity; // How many of this item to buy
  final String? description; // Optional notes about the item
  final DateTime? addedAt; // When the item was first added to the cart
  final bool
  urgentReminderShown; // Whether the one-time urgent reminder has been shown for this item
  final DateTime? dueDate; // When this item needs to be purchased by

  /**
   * Creates a new CartItem
   * 
   * Required fields: name, price, priority, quantity
   * Optional fields: id, upc, category, description, dueDate
   */
  CartItem({
    this.id,
    required this.name,
    this.upc,
    required this.price,
    this.category,
    required this.priority,
    required this.quantity,
    this.description,
    this.addedAt,
    this.urgentReminderShown = false,
    this.dueDate,
  });

  /**
   * Converts CartItem to a Map for database storage
   * 
   * The database stores data as key-value pairs (Maps), so we need
   * to convert our object into this format before saving
   */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'upc': upc,
      'price': price,
      'category': category,
      'priority': priority,
      'quantity': quantity,
      'description': description,
      'added_at': addedAt?.millisecondsSinceEpoch,
      'urgent_reminder_shown': urgentReminderShown ? 1 : 0,
      'due_date': dueDate?.millisecondsSinceEpoch,
    };
  }

  /**
   * Creates a CartItem from database Map data
   * 
   * Read data from the database, comes back as a Map.
   * factory method converts it back to a CartItem object.
   */
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      name: map['name'],
      upc: map['upc'],
      price: (map['price'] as num).toDouble(), // Safely convert price to double
      category: map['category'],
      priority: map['priority'],
      quantity: map['quantity'],
      description: map['description'],
      addedAt: map['added_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['added_at'] as int)
          : null,
      urgentReminderShown: (map['urgent_reminder_shown'] ?? 0) == 1,
      dueDate: map['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int)
          : null,
    );
  }

  /**
   * Converts CartItem to a readable string
   * 
   */
  @override
  String toString() {
    return 'CartItem{id: $id, name: $name, upc: $upc, price: $price, category: $category, priority: $priority, quantity: $quantity, description: $description, addedAt: $addedAt, urgentReminderShown: $urgentReminderShown, dueDate: $dueDate}';
  }
}
