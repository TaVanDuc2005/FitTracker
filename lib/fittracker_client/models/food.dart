/// Các loại món ăn
enum CategoryType { monNuoc, monKho, monXao, monChien }

class Food {
  final String id;
  final String name;
  final int calories;
  final String imageUrl;
  final String description;
  final CategoryType category;
  final double protein;
  final double fat;
  final double carb;
  final double fiber;

  Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.protein,
    required this.fat,
    required this.carb,
    required this.fiber,
  });

  /// Dùng cho API / Firestore
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      category: CategoryType.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => CategoryType.monNuoc,
      ),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carb: (json['carb'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'imageUrl': imageUrl,
      'description': description,
      'category': category.toString().split('.').last, // gửi string thay vì index
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
