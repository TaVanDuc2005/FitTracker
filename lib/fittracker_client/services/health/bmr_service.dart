import '../../models/user.dart';

class BMRService {
  /// Tính BMR từ object User (Mifflin-St Jeor)
  double? calculateBMRFromUser(User user) {
    final weight = user.weight;
    final height = user.height;
    final age = user.age;
    final gender = user.gender.toLowerCase();

    if (weight <= 0 || height <= 0 || age <= 0) return null;

    double bmr;
    if (gender == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    return double.parse(bmr.toStringAsFixed(1));
  }

  /// Tính BMR từ số liệu trực tiếp
  double? calculateBMR(double weight, double height, int age, String gender) {
    if (weight <= 0 || height <= 0 || age <= 0) return null;

    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    return double.parse(bmr.toStringAsFixed(1));
  }
}
