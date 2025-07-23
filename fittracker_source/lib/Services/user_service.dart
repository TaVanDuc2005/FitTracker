import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fittracker_source/models/user.dart';
import 'package:fittracker_source/utils/helpers.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'fittracker.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            id INTEGER PRIMARY KEY,
            name TEXT,
            age INTEGER,
            height REAL,
            weight REAL,
            gender TEXT,
            activityLevel TEXT
          )
        ''');
      },
    );
  }

  // Save or update user
  Future<void> saveUser(User user) async {
    final db = await database;
    await db.insert(
      'user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Load user (id = 1)
  Future<User?> getUser() async {
    final db = await database;
    final result = await db.query('user', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Delete user
  Future<void> deleteUser() async {
    final db = await database;
    await db.delete('user', where: 'id = ?', whereArgs: [1]);
  }

  // Tính BMI từ dữ liệu
  Future<double?> getBMI() async {
    final user = await getUser();
    if (user == null) return null;
    return calculateBMI(user.weight, user.height);
  }

  // Tính TDEE từ dữ liệu
  Future<double?> getTDEE() async {
    final user = await getUser();
    if (user == null) return null;
    final bmr = calculateBMR(
      gender: user.gender,
      weight: user.weight,
      height: user.height,
      age: user.age,
    );
    return calculateTDEE(bmr: bmr, activityLevel: user.activityLevel);
  }
}
