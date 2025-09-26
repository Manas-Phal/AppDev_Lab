import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calculator.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE calculations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            expression TEXT,
            result TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertCalculation(String expression, String result) async {
    final db = await database;
    return db.insert('calculations', {
      'expression': expression,
      'result': result,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getCalculations() async {
    final db = await database;
    return db.query('calculations', orderBy: 'id DESC');
  }

  Future<int> deleteCalculation(int id) async {
    final db = await database;
    return db.delete('calculations', where: 'id = ?', whereArgs: [id]);
  }

  // ✅ New: clear entire history
  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('calculations');
  }
}
