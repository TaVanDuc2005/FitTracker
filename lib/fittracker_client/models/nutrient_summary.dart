class NutrientSummary {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  NutrientSummary({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  /// Tạo từ JSON (server trả về)
  factory NutrientSummary.fromJson(Map<String, dynamic> json) {
    return NutrientSummary(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
    );
  }

  /// Chuyển object thành JSON (gửi lên server)
  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  /// Cộng dồn nhiều summary (giữ lại nếu cần logic app)
  NutrientSummary operator +(NutrientSummary other) {
    return NutrientSummary(
      calories: calories + other.calories,
      protein: protein + other.protein,
      fat: fat + other.fat,
      carbs: carbs + other.carbs,
    );
  }
}
