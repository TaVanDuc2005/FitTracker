// lib/fittracker_client/service/health/bmi_service.dart

import '../../models/user.dart';

class BMIService {
  /// Tính BMI từ object User
  double? calculateBMIFromUser(User user) {
    if (user.weight <= 0 || user.height <= 0) return null;
    final heightM = user.height / 100;
    final bmi = user.weight / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  /// Tính BMI từ số liệu trực tiếp
  double? calculateBMI(double weight, double height) {
    if (weight <= 0 || height <= 0) return null;
    final heightM = height / 100;
    final bmi = weight / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  /// Xếp loại BMI theo chuẩn WHO
  String classifyBMI(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
