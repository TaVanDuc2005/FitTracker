import '../../models/user.dart';
import '../health/tdee_service.dart';

class MacroSuggestionService {
  final TDEEService _tdeeService = TDEEService();

  /// Tính macro targets từ User
  Map<String, int>? calculateMacrosFromUser(User user) {
    final tdee = _tdeeService.calculateTDEEFromUser(user);
    if (tdee == null) return null;

    return _calculateMacros(tdee);
  }

  /// Tính macro targets từ số liệu trực tiếp
  Map<String, int>? calculateMacros(
      double weight, double height, int age, String gender, String lifestyle) {
    final tdee = _tdeeService.calculateTDEE(weight, height, age, gender, lifestyle);
    if (tdee == null) return null;

    return _calculateMacros(tdee);
  }

  /// Hàm private tính macro dựa trên TDEE
  Map<String, int> _calculateMacros(double tdee) {
    // Phân bố macro: 15% protein, 25% fat, 60% carbs
    final proteinCalories = tdee * 0.15;
    final fatCalories = tdee * 0.25;
    final carbsCalories = tdee * 0.60;

    return {
      'calories': tdee.round(),
      'protein': (proteinCalories / 4).round(), // 1g protein = 4 cal
      'fat': (fatCalories / 9).round(),         // 1g fat = 9 cal
      'carbs': (carbsCalories / 4).round(),     // 1g carbs = 4 cal
      'fiber': 25,                              // Khuyến nghị 25g/ngày
    };
  }
}
