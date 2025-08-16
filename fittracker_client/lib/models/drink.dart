import 'Food_Bast.dart';

/// Các loại món nước
enum DrinkCategory { sua, tra, cafe, nuocNgot }

class Drink extends FoodBase {
  final DrinkCategory category;
  final double sugar;
  final double fat;

  Drink({
    required super.id,
    required super.name,
    required super.calories,
    required super.imageUrl,
    required super.description,
    required this.category,
    required this.sugar,
    required this.fat,
  });

  factory Drink.fromMap(Map<String, dynamic> map) {
    return Drink(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      category: DrinkCategory.values[map['category']],
      sugar: (map['sugar'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'imageUrl': imageUrl,
      'description': description,
      'category': category.index,
      'sugar': sugar,
      'fat': fat,
    };
  }

  Drink copyWith({
    String? id,
    String? name,
    int? calories,
    String? imageUrl,
    String? description,
    DrinkCategory? category,
    double? sugar,
    double? fat,
  }) {
    return Drink(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      sugar: sugar ?? this.sugar,
      fat: fat ?? this.fat,
    );
  }
}
