double calculateBMI(double weight, double heightCm) {
  final heightM = heightCm / 100;
  return double.parse((weight / (heightM * heightM)).toStringAsFixed(2));
}

double calculateBMR({
  required String gender,
  required double weight,
  required double height,
  required int age,
}) {
  return gender == 'male'
      ? 10 * weight + 6.25 * height - 5 * age + 5
      : 10 * weight + 6.25 * height - 5 * age - 161;
}

double calculateTDEE({
  required double bmr,
  required String activityLevel,
}) {
  const factors = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };
  return double.parse((bmr * (factors[activityLevel] ?? 1.2)).toStringAsFixed(2));
}
