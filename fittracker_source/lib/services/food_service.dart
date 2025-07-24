import 'package:sqflite/sqflite.dart';
import 'package:fittracker_source/models/food.dart';
import 'database_service.dart';

class FoodService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> insertFood(Food food) async {
    final db = await _dbService.database;
    await db.insert('foods', food.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Food>> getAllFoods() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('foods');
    return maps.map((map) => Food.fromMap(map)).toList();
  }

  Future<void> updateFood(Food food) async {
    final db = await _dbService.database;
    await db.update('foods', food.toMap(), where: 'id = ?', whereArgs: [food.id]);
  }

  Future<void> deleteFood(String id) async {
    final db = await _dbService.database;
    await db.delete('foods', where: 'id = ?', whereArgs: [id]);
  }

  Future<Food?> getFoodById(String id) async {
    final db = await _dbService.database;
    final maps = await db.query('foods', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Food.fromMap(maps.first);
    }
    return null;
  }

  // Tìm kiếm món ăn theo tên hoặc loại
  Future<List<Food>> searchFoodsByNameOrCategory(String keyword) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return maps.map((map) => Food.fromMap(map)).toList();
  }

  // Lọc món ăn có lượng calo nhỏ hơn maxCalories
  Future<List<Food>> getFoodsUnderCalories(int maxCalories) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'calories <= ?',
      whereArgs: [maxCalories],
    );
    return maps.map((map) => Food.fromMap(map)).toList();
  }

  // Kiểm tra xem món ăn đã tồn tại theo tên
  Future<bool> foodExists(String name) async {
    final db = await _dbService.database;
    final result = await db.query(
      'foods',
      where: 'name = ?',
      whereArgs: [name],
    );
    return result.isNotEmpty;
  }
}
