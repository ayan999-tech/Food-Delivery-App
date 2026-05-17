
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'food_delivery.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        restaurant TEXT,
        total REAL,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        name TEXT,
        price REAL,
        quantity INTEGER
      )
    ''');
  }


  Future<int> insertOrder({
    required String restaurantName,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await database;

    int orderId = await db.insert(
      'orders',
      {
        'restaurant': restaurantName,
        'total': total,
        'date': DateTime.now().toString(),
      },
    );

    for (var item in items) {
      await db.insert(
        'order_items',
        {
          'order_id': orderId,
          'name': item['name'],
          'price': item['price'],
          'quantity': item['quantity'],
        },
      );
    }

    return orderId;
  }


  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return await db.query(
      'orders',
      orderBy: 'id DESC',
    );
  }


  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    final db = await database;
    return await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('order_items');
    await db.delete('orders');
  }
}


