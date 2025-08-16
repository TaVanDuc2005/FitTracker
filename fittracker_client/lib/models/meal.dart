import 'food.dart';

/// Đại diện cho một bữa ăn (Breakfast, Lunch, Dinner...)
class Meal {
  final String id;
  final String name;
  final List<Food> foods; // Danh sách món ăn thuộc bữa ăn
  final DateTime dateTime;

  Meal({
    required this.id,
    required this.name,
    required this.foods,
    required this.dateTime,
  });

  /// Tính tổng calo của toàn bộ món trong bữa ăn
  int get totalCalories =>
      foods.fold(0, (sum, item) => sum + item.calories);

  /// Chuyển dữ liệu từ Map (SQLite) thành đối tượng Meal
  /// [attachedFoods] là danh sách món ăn lấy từ bảng trung gian meal_food
  factory Meal.fromMap(Map<String, dynamic> map, List<Food> attachedFoods) {
    return Meal(
      id: map['id'],
      name: map['name'],
      dateTime: DateTime.parse(map['dateTime']),
      foods: attachedFoods,
    );
  }

  /// Chuyển đối tượng Meal thành Map để lưu vào SQLite
  /// (Không bao gồm danh sách món ăn - sẽ lưu ở bảng trung gian)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
