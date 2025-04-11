import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:quickpass/features/cart/data/models/cart_item_model.dart';
import 'package:quickpass/api/client.dart';
import 'package:quickpass/utils/encryption.dart';

class OfflineSyncService {
  static Database? _database;
  final ApiClient _client = ApiClient();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'quickpass.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_data TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> init() async {
    await database; // Ensure DB is initialized
  }

  Future<void> saveCartItemOffline(CartItemModel item) async {
    final db = await database;
    final encryptedData = EncryptionUtil.encryptJson(item.toJson());
    await db.insert('cart', {'item_data': encryptedData});
  }

  Future<List<CartItemModel>> getOfflineCartItems() async {
    final db = await database;
    final result = await db.query('cart');
    return result
        .map((row) => CartItemModel.fromJson(
              EncryptionUtil.decryptJson(row['item_data'] as String),
            ))
        .toList();
  }

  Future<void> syncCart() async {
    try {
      final items = await getOfflineCartItems();
      if (items.isEmpty) return;

      for (var item in items) {
        await _client.post('/cart/add', item.toJson());
      }

      // Clear offline cart after sync
      final db = await database;
      await db.delete('cart');
    } catch (e) {
      print('Sync failed: $e'); // In production, use a proper logger
    }
  }

  Future<void> clearOfflineCart() async {
    final db = await database;
    await db.delete('cart');
  }
}