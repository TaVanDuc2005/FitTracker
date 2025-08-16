import 'Food_Bast.dart';

/// Các loại món ăn
enum CategoryType { monNuoc, monKho, monXao, monChien }

class Food extends FoodBase {
  final CategoryType category;
  final double protein;
  final double fat;
  final double carb;
  final double fiber;
  
  Food({
    required super.id,
    required super.name,
    required super.calories,
    required super.imageUrl,
    required super.description,
    required this.category,
    required this.protein,
    required this.fat,
    required this.carb,
    required this.fiber,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],   
      name: map['name'],
      calories: map['calories'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      category: CategoryType.values[map['category']],
      protein: (map['protein'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      carb: (map['carb'] as num).toDouble(),
      fiber: (map['fiber'] as num).toDouble(),
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
      'protein': protein,
      'fat': fat,
      'carb': carb,
      'fiber': fiber,
    };
  }

  Food copyWith({
    String? id,
    String? name,
    int? calories,
    String? imageUrl,
    String? description,
    CategoryType? category,
    double? protein,
    double? fat,
    double? carb,
    double? fiber,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carb: carb ?? this.carb,
      fiber: fiber ?? this.fiber,
    );
  }
}
