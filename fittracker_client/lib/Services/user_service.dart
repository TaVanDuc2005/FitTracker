import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _keyName = 'user_name';
  static const String _keyGender = 'user_gender';
  static const String _keyAge = 'user_age';
  static const String _keyHeight = 'user_height';
  static const String _keyWeight = 'user_weight';
  static const String _keyLifestyle = 'user_lifestyle';
  static const String _keyHasDietaryRestrictions = 'has_dietary_restrictions';
  static const String _keyDietaryRestrictionsList = 'dietary_restrictions_list';
  static const String _keyGoal = 'user_goal';
  static const String _keyTargetWeight = 'user_target_weight';
  static const String _keyIsSetupComplete = 'is_setup_complete';

  // Lưu thông tin cá nhân hoàn chỉnh
  static Future<bool> saveUserInfo({
    String? name,
    required String gender,
    required int age,
    required double height,
    required double weight,
    required String lifestyle,
    required String hasDietaryRestrictions,
    required String dietaryRestrictionsList,
    required String goal,
    required double targetWeight,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final futures = <Future<bool>>[
        prefs.setString(_keyGender, gender),
        prefs.setInt(_keyAge, age),
        prefs.setDouble(_keyHeight, height),
        prefs.setDouble(_keyWeight, weight),
        prefs.setString(_keyLifestyle, lifestyle),
        prefs.setString(
          _keyHasDietaryRestrictions,
          hasDietaryRestrictions,
        ), // "Yes"/"No"
        prefs.setString(
          _keyDietaryRestrictionsList,
          dietaryRestrictionsList,
        ), // "Veganism, Gluten-Free"
        prefs.setString(_keyGoal, goal),
        prefs.setDouble(_keyTargetWeight, targetWeight),
        prefs.setBool(_keyIsSetupComplete, true),
      ];

      // Chỉ lưu name nếu được cung cấp
      if (name != null && name.trim().isNotEmpty) {
        futures.add(prefs.setString(_keyName, name.trim()));
      }

      await Future.wait(futures);
      return true;
    } catch (e) {
      print('Error saving user info: $e');
      return false;
    }
  }

  // In user_service.dart
  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('✅ All user data cleared');
  }

  // Lưu name riêng lẻ
  static Future<bool> saveName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyName, name.trim());
    } catch (e) {
      print('Error saving name: $e');
      return false;
    }
  }

  // Lấy name
  static Future<String?> getName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyName);
    } catch (e) {
      print('Error getting name: $e');
      return null;
    }
  }

  // Lấy thông tin cá nhân (bao gồm name) - SỬA LẠI
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final isSetupComplete = prefs.getBool(_keyIsSetupComplete) ?? false;
      if (!isSetupComplete) {
        return null;
      }

      return {
        'name': prefs.getString(_keyName),
        'gender': prefs.getString(_keyGender),
        'age': prefs.getInt(_keyAge),
        'height': prefs.getDouble(_keyHeight),
        'weight': prefs.getDouble(_keyWeight),
        'lifestyle': prefs.getString(_keyLifestyle),
        'hasDietaryRestrictions': prefs.getString(
          _keyHasDietaryRestrictions,
        ), // SỬA
        'dietaryRestrictionsList': prefs.getString(
          _keyDietaryRestrictionsList,
        ), // SỬA
        'goal': prefs.getString(_keyGoal),
        'targetWeight': prefs.getDouble(_keyTargetWeight),
        'isSetupComplete': isSetupComplete,
      };
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  // Kiểm tra đã hoàn thành setup chưa
  static Future<bool> isSetupComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsSetupComplete) ?? false;
    } catch (e) {
      print('Error checking setup status: $e');
      return false;
    }
  }

  // ===== GETTER METHODS =====
  static Future<String?> getGender() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyGender);
    } catch (e) {
      print('Error getting gender: $e');
      return null;
    }
  }

  static Future<int?> getAge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyAge);
    } catch (e) {
      print('Error getting age: $e');
      return null;
    }
  }

  static Future<double?> getHeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_keyHeight);
    } catch (e) {
      print('Error getting height: $e');
      return null;
    }
  }

  static Future<double?> getWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_keyWeight); // SỬA: Từ getString thành getDouble
    } catch (e) {
      print('Error getting weight: $e');
      return null;
    }
  }

  static Future<String?> getLifestyle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyLifestyle);
    } catch (e) {
      print('Error getting lifestyle: $e');
      return null;
    }
  }

  // SỬA: Dietary restrictions methods
  static Future<String?> getDietaryRestrictions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyHasDietaryRestrictions); // SỬA KEY
    } catch (e) {
      print('Error getting dietary restrictions: $e');
      return null;
    }
  }

  // THÊM: Methods cho has dietary restrictions (Yes/No)
  static Future<String?> getHasDietaryRestrictions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyHasDietaryRestrictions);
    } catch (e) {
      print('Error getting has dietary restrictions: $e');
      return null;
    }
  }

  // THÊM: Methods cho dietary restrictions list (Multiple)
  static Future<String?> getDietaryRestrictionsList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyDietaryRestrictionsList);
    } catch (e) {
      print('Error getting dietary restrictions list: $e');
      return null;
    }
  }

  static Future<String?> getGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyGoal);
    } catch (e) {
      print('Error getting goal: $e');
      return null;
    }
  }

  static Future<double?> getTargetWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_keyTargetWeight);
    } catch (e) {
      print('Error getting target weight: $e');
      return null;
    }
  }

  // ===== UPDATE METHODS =====
  static Future<bool> updateName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyName, name.trim());
    } catch (e) {
      print('Error updating name: $e');
      return false;
    }
  }

  static Future<bool> updateGender(String gender) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyGender, gender);
    } catch (e) {
      print('Error updating gender: $e');
      return false;
    }
  }

  static Future<bool> updateAge(int age) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(_keyAge, age);
    } catch (e) {
      print('Error updating age: $e');
      return false;
    }
  }

  static Future<bool> updateHeight(double height) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setDouble(_keyHeight, height);
    } catch (e) {
      print('Error updating height: $e');
      return false;
    }
  }

  static Future<bool> updateWeight(double weight) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setDouble(_keyWeight, weight);
    } catch (e) {
      print('Error updating weight: $e');
      return false;
    }
  }

  static Future<bool> updateLifestyle(String lifestyle) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyLifestyle, lifestyle);
    } catch (e) {
      print('Error updating lifestyle: $e');
      return false;
    }
  }

  // SỬA: Dietary restrictions update methods
  static Future<bool> updateDietaryRestrictions(String restrictions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        _keyHasDietaryRestrictions,
        restrictions,
      ); // SỬA KEY
    } catch (e) {
      print('Error updating dietary restrictions: $e');
      return false;
    }
  }

  // THÊM: Update methods cho 2 loại dietary restrictions
  static Future<bool> updateHasDietaryRestrictions(
    String hasRestrictions,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyHasDietaryRestrictions, hasRestrictions);
    } catch (e) {
      print('Error updating has dietary restrictions: $e');
      return false;
    }
  }

  static Future<bool> updateDietaryRestrictionsList(
    String restrictionsList,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        _keyDietaryRestrictionsList,
        restrictionsList,
      );
    } catch (e) {
      print('Error updating dietary restrictions list: $e');
      return false;
    }
  }

  static Future<bool> updateGoal(String goal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyGoal, goal);
    } catch (e) {
      print('Error updating goal: $e');
      return false;
    }
  }

  static Future<bool> updateTargetWeight(double targetWeight) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setDouble(_keyTargetWeight, targetWeight);
    } catch (e) {
      print('Error updating target weight: $e');
      return false;
    }
  }

  // SỬA: Xóa tất cả thông tin (reset app)
  static Future<bool> clearUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.remove(_keyName),
        prefs.remove(_keyGender),
        prefs.remove(_keyAge),
        prefs.remove(_keyHeight),
        prefs.remove(_keyWeight),
        prefs.remove(_keyLifestyle),
        prefs.remove(_keyHasDietaryRestrictions), // SỬA
        prefs.remove(_keyDietaryRestrictionsList), // THÊM
        prefs.remove(_keyGoal),
        prefs.remove(_keyTargetWeight),
        prefs.remove(_keyIsSetupComplete),
      ]);

      return true;
    } catch (e) {
      print('Error clearing user info: $e');
      return false;
    }
  }

  // ===== CALCULATION METHODS =====
  // Tính BMI từ thông tin đã lưu
  static Future<double?> calculateBMI() async {
    try {
      final height = await getHeight();
      final weight = await getWeight();

      if (height == null || weight == null || height <= 0) return null;

      final heightInMeters = height / 100;
      final bmi = weight / (heightInMeters * heightInMeters);
      return double.parse(bmi.toStringAsFixed(1));
    } catch (e) {
      print('Error calculating BMI: $e');
      return null;
    }
  }

  // Tính calories cần thiết hàng ngày (TDEE)
  static Future<int?> calculateDailyCalories() async {
    try {
      final gender = await getGender();
      final age = await getAge();
      final height = await getHeight();
      final weight = await getWeight();
      final lifestyle = await getLifestyle();

      if (gender == null || age == null || height == null || weight == null) {
        return null;
      }

      // Công thức Mifflin-St Jeor cho BMR
      double bmr;
      if (gender.toLowerCase() == 'male') {
        bmr = 10 * weight + 6.25 * height - 5 * age + 5;
      } else {
        bmr = 10 * weight + 6.25 * height - 5 * age - 161;
      }

      // Hệ số hoạt động
      double activityFactor;
      switch (lifestyle?.toLowerCase()) {
        case 'student':
        case 'not employed':
        case 'retired':
          activityFactor = 1.2; // Ít vận động
          break;
        case 'employed part-time':
          activityFactor = 1.375; // Vận động nhẹ
          break;
        case 'employed full-time':
          activityFactor = 1.55; // Vận động vừa
          break;
        default:
          activityFactor = 1.2;
      }

      return (bmr * activityFactor).round();
    } catch (e) {
      print('Error calculating daily calories: $e');
      return null;
    }
  }

  // Tính macro targets
  static Future<Map<String, int>?> calculateMacroTargets() async {
    try {
      final dailyCalories = await calculateDailyCalories();
      if (dailyCalories == null) return null;

      return {
        'calories': dailyCalories,
        'protein': (dailyCalories * 0.15 / 4)
            .round(), // 15% calories từ protein
        'fat': (dailyCalories * 0.25 / 9).round(), // 25% calories từ fat
        'carbs': (dailyCalories * 0.60 / 4).round(), // 60% calories từ carbs
        'fiber': 25, // Khuyến nghị 25g/ngày
      };
    } catch (e) {
      print('Error calculating macro targets: $e');
      return null;
    }
  }

  // ===== UTILITY METHODS =====
  // SỬA: Debug - In tất cả thông tin
  static Future<void> printUserInfo() async {
    print('\n========== USER PROFILE ==========');

    final isComplete = await isSetupComplete();
    print('Setup Complete: $isComplete');

    if (!isComplete) {
      print('❌ User has not completed setup');
      print('===================================\n');
      return;
    }

    final userInfo = await getUserInfo();
    if (userInfo == null) {
      print('❌ No user data found');
      print('===================================\n');
      return;
    }

    print('📊 BASIC INFO:');
    print('   Name: ${userInfo['name'] ?? 'N/A'}');
    print('   Gender: ${userInfo['gender'] ?? 'N/A'}');
    print('   Age: ${userInfo['age'] ?? 'N/A'} years');
    print('   Height: ${userInfo['height'] ?? 'N/A'} cm');
    print('   Weight: ${userInfo['weight'] ?? 'N/A'} kg');
    print('   Target Weight: ${userInfo['targetWeight'] ?? 'N/A'} kg');

    print('\n🏃 LIFESTYLE:');
    print('   Activity: ${userInfo['lifestyle'] ?? 'N/A'}');
    print('   Goal: ${userInfo['goal'] ?? 'N/A'}');
    print(
      '   Has Dietary Restrictions: ${userInfo['hasDietaryRestrictions'] ?? 'N/A'}',
    ); // SỬA
    print(
      '   Dietary Restrictions List: ${userInfo['dietaryRestrictionsList'] ?? 'N/A'}',
    ); // SỬA

    final bmi = await calculateBMI();
    final dailyCalories = await calculateDailyCalories();
    final macros = await calculateMacroTargets();

    print('\n🎯 CALCULATIONS:');
    print('   BMI: ${bmi?.toStringAsFixed(1) ?? 'N/A'}');
    print('   Daily Calories: ${dailyCalories ?? 'N/A'} cal');

    if (macros != null) {
      print('   Daily Targets:');
      print('     • Protein: ${macros['protein']}g');
      print('     • Fat: ${macros['fat']}g');
      print('     • Carbs: ${macros['carbs']}g');
      print('     • Fiber: ${macros['fiber']}g');
    }

    print('===================================\n');
  }

  // Kiểm tra dữ liệu có đầy đủ không
  static Future<bool> hasCompleteData() async {
    try {
      final userInfo = await getUserInfo();
      if (userInfo == null) return false;

      final requiredFields = [
        'gender',
        'age',
        'height',
        'weight',
        'lifestyle',
        'goal',
      ];

      return requiredFields.every(
        (field) =>
            userInfo[field] != null && userInfo[field].toString().isNotEmpty,
      );
    } catch (e) {
      print('Error checking complete data: $e');
      return false;
    }
  }
}
