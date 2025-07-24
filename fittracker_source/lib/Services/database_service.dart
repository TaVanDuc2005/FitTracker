import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static Database? _db;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fittracker.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Table: foods
    await db.execute('''
      CREATE TABLE foods (
        id TEXT PRIMARY KEY,
        name TEXT,
        calories INTEGER,
        imageUrl TEXT,
        description TEXT
      )
    ''');

    // Table: meals
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY,
        name TEXT,
        date TEXT
      )
    ''');

    // Table: meal_foods (many-to-many)
    await db.execute('''
      CREATE TABLE meal_foods (
        id TEXT PRIMARY KEY,
        mealId TEXT,
        foodId TEXT,
        quantity INTEGER,
        FOREIGN KEY (mealId) REFERENCES meals(id) ON DELETE CASCADE,
        FOREIGN KEY (foodId) REFERENCES foods(id) ON DELETE CASCADE
      )
    ''');

    // Table: water_logs
    await db.execute('''
      CREATE TABLE water_logs (
        id TEXT PRIMARY KEY,
        date TEXT,
        amount INTEGER
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fittracker.db');
    await deleteDatabase(path);
  }
}
