import 'Food_Bast.dart';

/// Các loại món ăn
enum CategoryType { monNuoc, monKho, monXao, monChien }

class Food extends FoodBase {
  final CategoryType category;

  Food({
    required super.id,
    required super.name,
    required super.calories,
    required super.imageUrl,
    required super.description,
    required this.category,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      category: CategoryType.values[map['category']],
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
    };
  }
}



