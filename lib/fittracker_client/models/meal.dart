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
  double get totalCalories =>
      foods.fold(0.0, (sum, item) => sum + item.calories);

  /// Parse từ JSON (server response)
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      foods: (json['foods'] as List<dynamic>)
          .map((f) => Food.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert sang JSON (đẩy lên server)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateTime': dateTime.toIso8601String(),
      'foods': foods.map((f) => f.toJson()).toList(),
    };
  }
}
