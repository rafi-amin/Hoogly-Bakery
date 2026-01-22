import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Provides a singleton SQLite database instance with schema creation and
/// sample seed data so the POS works offline from first launch.
///
/// Schema covers:
/// - users, categories, products, product_variants, addons
/// - sales, sale_items, sale_item_addons, invoice_counters
/// - legacy orders/order_items for the higher layers already using them
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static const _dbName = 'hoogli_pos.db';
  static const _dbVersion = 2;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _init();
    return _database!;
  }

  Future<Database> _init() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = join(documentsDir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Core user table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        pin TEXT NOT NULL,
        role TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      );
    ''');

    // Product catalog
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,            -- bakery / restaurant / mixed / other
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1
      );
    ''');

    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        base_price REAL NOT NULL,
        has_variants INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        image_path TEXT,
        -- legacy columns used by existing data layer
        price REAL NOT NULL DEFAULT 0,
        is_available INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(category_id) REFERENCES categories(id) ON UPDATE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE product_variants(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        sku TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE addons(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      );
    ''');

    // Sales & tickets
    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_no TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        sale_type TEXT NOT NULL,              -- takeaway / dinein
        subtotal REAL NOT NULL,
        discount_type TEXT NOT NULL,          -- flat / percent / none
        discount_value REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL,
        payment_method TEXT NOT NULL,         -- cash / bkash / nagad / card / mixed
        paid_amount REAL NOT NULL,
        due_amount REAL NOT NULL,
        cashier_id INTEGER,
        customer_name TEXT,
        customer_phone TEXT,
        note TEXT,
        FOREIGN KEY(cashier_id) REFERENCES users(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE sale_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        variant_id INTEGER,
        name_snapshot TEXT NOT NULL,
        variant_snapshot TEXT,
        qty INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY(sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY(product_id) REFERENCES products(id),
        FOREIGN KEY(variant_id) REFERENCES product_variants(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE sale_item_addons(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_item_id INTEGER NOT NULL,
        addon_id INTEGER NOT NULL,
        addon_name_snapshot TEXT NOT NULL,
        qty INTEGER NOT NULL,
        addon_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY(sale_item_id) REFERENCES sale_items(id) ON DELETE CASCADE,
        FOREIGN KEY(addon_id) REFERENCES addons(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE invoice_counters(
        id INTEGER PRIMARY KEY,
        last_number INTEGER NOT NULL
      );
    ''');

    // Legacy orders tables kept for the initial data/domain layer built earlier.
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subtotal REAL NOT NULL,
        tax REAL NOT NULL,
        total REAL NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE order_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE CASCADE,
        FOREIGN KEY(product_id) REFERENCES products(id)
      );
    ''');

    await _seedInitialData(db);
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Add the new POS tables if upgrading from v1.
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          pin TEXT NOT NULL,
          role TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS product_variants(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          price REAL NOT NULL,
          sku TEXT,
          is_active INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS addons(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          price REAL NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sales(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          invoice_no TEXT NOT NULL UNIQUE,
          created_at TEXT NOT NULL,
          sale_type TEXT NOT NULL,
          subtotal REAL NOT NULL,
          discount_type TEXT NOT NULL,
          discount_value REAL NOT NULL DEFAULT 0,
          total REAL NOT NULL,
          payment_method TEXT NOT NULL,
          paid_amount REAL NOT NULL,
          due_amount REAL NOT NULL,
          cashier_id INTEGER,
          customer_name TEXT,
          customer_phone TEXT,
          note TEXT,
          FOREIGN KEY(cashier_id) REFERENCES users(id)
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sale_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          variant_id INTEGER,
          name_snapshot TEXT NOT NULL,
          variant_snapshot TEXT,
          qty INTEGER NOT NULL,
          unit_price REAL NOT NULL,
          total_price REAL NOT NULL,
          FOREIGN KEY(sale_id) REFERENCES sales(id) ON DELETE CASCADE,
          FOREIGN KEY(product_id) REFERENCES products(id),
          FOREIGN KEY(variant_id) REFERENCES product_variants(id)
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sale_item_addons(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_item_id INTEGER NOT NULL,
          addon_id INTEGER NOT NULL,
          addon_name_snapshot TEXT NOT NULL,
          qty INTEGER NOT NULL,
          addon_price REAL NOT NULL,
          total_price REAL NOT NULL,
          FOREIGN KEY(sale_item_id) REFERENCES sale_items(id) ON DELETE CASCADE,
          FOREIGN KEY(addon_id) REFERENCES addons(id)
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS invoice_counters(
          id INTEGER PRIMARY KEY,
          last_number INTEGER NOT NULL
        );
      ''');

      // Best-effort: seed demo user and invoice counter if they don't exist yet.
      final users = await db.query('users', limit: 1);
      if (users.isEmpty) {
        await _seedUsers(db);
      }

      final counters = await db.query('invoice_counters', where: 'id = 1');
      if (counters.isEmpty) {
        await db.insert('invoice_counters', {'id': 1, 'last_number': 1000});
      }
    }
  }

  Future<void> _seedInitialData(Database db) async {
    await _seedUsers(db);
    await _seedCatalog(db);

    // Initialize invoice counter to a friendly starting number.
    await db.insert('invoice_counters', {'id': 1, 'last_number': 1000});
  }

  Future<void> _seedUsers(Database db) async {
    // Demo admin account
    await db.insert('users', {
      'name': 'Admin',
      'pin': '1234',
      'role': 'admin',
      'is_active': 1,
    });
  }

  Future<void> _seedCatalog(Database db) async {
    // Bakery & restaurant categories
    final categoryIds = <String, int>{};
    final categories = [
      {'name': 'Artisan Breads', 'type': 'bakery', 'sort_order': 1},
      {'name': 'Pastries', 'type': 'bakery', 'sort_order': 2},
      {'name': 'Hot Beverages', 'type': 'bakery', 'sort_order': 3},
      {'name': 'Cold Beverages', 'type': 'bakery', 'sort_order': 4},
      {'name': 'Brunch Plates', 'type': 'restaurant', 'sort_order': 5},
      {'name': 'Mains', 'type': 'restaurant', 'sort_order': 6},
    ];

    for (final c in categories) {
      final id = await db.insert('categories', {
        'name': c['name'],
        'type': c['type'],
        'sort_order': c['sort_order'],
        'is_active': 1,
      });
      categoryIds[c['name']! as String] = id;
    }

    // Core products
    final products = [
      {
        'name': 'Sourdough Loaf',
        'category': 'Artisan Breads',
        'price': 5.50,
      },
      {
        'name': 'Focaccia',
        'category': 'Artisan Breads',
        'price': 4.25,
      },
      {
        'name': 'Butter Croissant',
        'category': 'Pastries',
        'price': 3.25,
      },
      {
        'name': 'Chocolate Babka Slice',
        'category': 'Pastries',
        'price': 3.75,
      },
      {
        'name': 'Cinnamon Roll',
        'category': 'Pastries',
        'price': 3.50,
      },
      {
        'name': 'Flat White',
        'category': 'Hot Beverages',
        'price': 4.00,
      },
      {
        'name': 'Cappuccino',
        'category': 'Hot Beverages',
        'price': 3.90,
      },
      {
        'name': 'Iced Latte',
        'category': 'Cold Beverages',
        'price': 4.20,
      },
      {
        'name': 'House Lemonade',
        'category': 'Cold Beverages',
        'price': 3.10,
      },
      {
        'name': 'Avocado Toast',
        'category': 'Brunch Plates',
        'price': 8.50,
      },
      {
        'name': 'Shakshuka',
        'category': 'Brunch Plates',
        'price': 9.75,
      },
      {
        'name': 'Hoogli Burger',
        'category': 'Mains',
        'price': 11.50,
      },
    ];

    for (final p in products) {
      final categoryId = categoryIds[p['category']! as String]!;
      final price = (p['price']! as num).toDouble();
      await db.insert('products', {
        'name': p['name'],
        'category_id': categoryId,
        'base_price': price,
        'has_variants': 0,
        'is_active': 1,
        'image_path': null,
        // keep legacy columns in sync for the existing app layer
        'price': price,
        'is_available': 1,
      });
    }
  }
}
