import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flashgamer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE auth_token (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveToken(String token) async {
    final db = await instance.database;
    await db.delete('auth_token');
    await db.insert('auth_token', {
      'token': token,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<String?> getToken() async {
    final db = await instance.database;
    final result = await db.query('auth_token', limit: 1);
    if (result.isNotEmpty) {
      return result.first['token'] as String;
    }
    return null;
  }

  Future<void> deleteToken() async {
    final db = await instance.database;
    await db.delete('auth_token');
  }
}
