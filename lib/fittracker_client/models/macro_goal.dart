class MacroGoal {
  final int id;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  MacroGoal({
    required this.id,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory MacroGoal.fromJson(Map<String, dynamic> json) {
    return MacroGoal(
      id: json['id'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }
}
