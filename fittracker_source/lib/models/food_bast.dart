abstract class FoodBase {
  final String id;
  final String name;
  final int calories;
  final String imageUrl;
  final String description;

  FoodBase({
    required this.id,
    required this.name,
    required this.calories,
    required this.imageUrl,
    required this.description,
  });

  Map<String, dynamic> toMap();
}
