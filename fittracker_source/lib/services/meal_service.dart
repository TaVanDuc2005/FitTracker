import 'package:sqflite/sqflite.dart';
import 'package:fittracker_source/models/meal.dart';
import 'package:fittracker_source/models/food.dart';
import 'Database_Service.dart';
import 'Food_Service.dart';

class MealService {
  final dbService = DatabaseService();
  final foodService = FoodService();

  Future<void> insertMeal(Meal meal) async {
    final db = await dbService.database;
    await db.insert(
      'meals',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _updateMealFoodLinks(db, meal);
  }

  Future<void> _updateMealFoodLinks(Database db, Meal meal) async {
    await db.delete('meal_foods', where: 'meal_id = ?', whereArgs: [meal.id]);

    for (var food in meal.foods) {
      await db.insert('meal_foods', {
        'meal_id': meal.id,
        'food_id': food.id,
      });
    }
  }

  Future<List<Meal>> getMealsByDate(DateTime date) async {
    final db = await dbService.database;
    final dateOnly = date.toIso8601String().substring(0, 10);

    final mealMaps = await db.query(
      'meals',
      where: "substr(dateTime, 1, 10) = ?",
      whereArgs: [dateOnly],
      orderBy: 'dateTime DESC',
    );

    return _buildMealListFromMaps(db, mealMaps);
  }

  Future<List<Meal>> getRecentMeals({int days = 30}) async {
    final db = await dbService.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final cutoffString = cutoffDate.toIso8601String();

    final mealMaps = await db.query(
      'meals',
      where: "dateTime >= ?",
      whereArgs: [cutoffString],
      orderBy: 'dateTime DESC',
    );

    return _buildMealListFromMaps(db, mealMaps);
  }

  Future<void> deleteMeal(String mealId) async {
    final db = await dbService.database;
    await db.delete('meal_foods', where: 'meal_id = ?', whereArgs: [mealId]);
    await db.delete('meals', where: 'id = ?', whereArgs: [mealId]);
  }

  Future<List<Meal>> _buildMealListFromMaps(Database db, List<Map<String, dynamic>> mealMaps) async {
    List<Meal> result = [];

    for (var mealMap in mealMaps) {
      final mealId = mealMap['id'];

      final foodIdMaps = await db.query(
        'meal_foods',
        where: 'meal_id = ?',
        whereArgs: [mealId],
      );

      List<Food> foods = [];
      for (var row in foodIdMaps) {
        final foodId = row['food_id'] as String;
        final food = await foodService.getFoodById(foodId);
        if (food != null) {
          foods.add(food);
        }
      }

      result.add(Meal.fromMap(mealMap, foods));
    }

    return result;
  }

  /// Tổng calo trong ngày
  Future<int> getTotalCaloriesByDate(DateTime date) async {
    final meals = await getMealsByDate(date);
    int totalCalories = 0;

    for (var meal in meals) {
      for (var food in meal.foods) {
        totalCalories += food.calories;
      }
    }

    return totalCalories;
  }

  /// Tổng calo của một bữa ăn cụ thể
  Future<int> getTotalCaloriesForMeal(String mealId) async {
    final db = await dbService.database;
    final foodIdMaps = await db.query(
      'meal_foods',
      where: 'meal_id = ?',
      whereArgs: [mealId],
    );

    int total = 0;
    for (var row in foodIdMaps) {
      final food = await foodService.getFoodById(row['food_id'].toString());
      if (food != null) {
        total += food.calories;
      }
    }

    return total;
  }

  /// Tổng calo mỗi ngày trong 7 ngày gần nhất
  Future<Map<String, int>> getCaloriesForLast7Days() async {
    Map<String, int> dailyCalories = {};
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final dateStr = day.toIso8601String().substring(0, 10);
      final total = await getTotalCaloriesByDate(day);
      dailyCalories[dateStr] = total;
    }

    return dailyCalories;
  }
}
