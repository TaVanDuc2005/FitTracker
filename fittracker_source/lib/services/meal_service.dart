import 'package:sqflite/sqflite.dart';
import 'package:fittracker_source/models/meal.dart';
import 'package:fittracker_source/models/food.dart';
import 'database_service.dart';
import 'food_service.dart';

class MealService {
  final dbService = DatabaseService();
  final foodService = FoodService();

  Future<void> insertMeal(Meal meal) async {
    final db = await dbService.database;

    await db.insert('meals', meal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    // Xoá trước để tránh trùng (nếu update)
    await db.delete('meal_foods', where: 'meal_id = ?', whereArgs: [meal.id]);

    // Thêm danh sách food liên kết
    for (var food in meal.foods) {
      await db.insert('meal_foods', {
        'meal_id': meal.id,
        'food_id': food.id,
      });
    }
  }

  Future<List<Meal>> getAllMeals() async {
    final db = await dbService.database;

    final mealMaps = await db.query('meals');
    List<Meal> result = [];

    for (var mealMap in mealMaps) {
      final mealId = mealMap['id'];

      // Lấy danh sách food_id
      final foodIdMaps = await db.query('meal_foods',
          where: 'meal_id = ?', whereArgs: [mealId]);

      List<Food> foods = [];
      for (var foodMap in foodIdMaps) {
        final foodId = foodMap['food_id'];
        final food = await foodService.getFoodById(foodId);
        if (food != null) {
          foods.add(food);
        }
      }

      result.add(Meal.fromMap(mealMap, foods));
    }

    return result;
  }

  Future<void> deleteMeal(String mealId) async {
    final db = await dbService.database;
    await db.delete('meal_foods', where: 'meal_id = ?', whereArgs: [mealId]);
    await db.delete('meals', where: 'id = ?', whereArgs: [mealId]);
  }
}
