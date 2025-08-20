import '../../models/user.dart';
import 'bmr_service.dart';

class TDEEService {
  final BMRService _bmrService = BMRService();

  /// Tính TDEE từ User
  double? calculateTDEEFromUser(User user) {
    final bmr = _bmrService.calculateBMRFromUser(user);
    if (bmr == null) return null;

    double factor;
    switch (user.lifestyle.toLowerCase()) {
      case 'student':
      case 'not employed':
      case 'retired':
        factor = 1.2;
        break;
      case 'employed part-time':
        factor = 1.375;
        break;
      case 'employed full-time':
        factor = 1.55;
        break;
      default:
        factor = 1.2;
    }

    return double.parse((bmr * factor).toStringAsFixed(1));
  }

  /// Tính TDEE từ số liệu trực tiếp
  double? calculateTDEE(
      double weight, double height, int age, String gender, String lifestyle) {
    final bmr = _bmrService.calculateBMR(weight, height, age, gender);
    if (bmr == null) return null;

    double factor;
    switch (lifestyle.toLowerCase()) {
      case 'student':
      case 'not employed':
      case 'retired':
        factor = 1.2;
        break;
      case 'employed part-time':
        factor = 1.375;
        break;
      case 'employed full-time':
        factor = 1.55;
        break;
      default:
        factor = 1.2;
    }

    return double.parse((bmr * factor).toStringAsFixed(1));
  }
}
