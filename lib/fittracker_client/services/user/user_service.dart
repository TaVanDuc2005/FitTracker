import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart' as app_user;
import '../health/bmi_service.dart';
import '../health/tdee_service.dart';
import 'dart:convert';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  
  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  static Future<app_user.User> getCurrentUser() async {
    final fbUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (fbUser == null) throw Exception('No logged-in user');

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(fbUser.uid)
        .get();

    return app_user.User.fromJson(doc.data()!);
  }

  /// Lưu tên tạm thời vào local storage
  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  /// Lấy tên đã lưu tạm thời từ local storage
  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  /// Xóa tên tạm thời khỏi local storage
  static Future<void> clearTempName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
  }

  static Future<String?> getGender() async {
    final userService = UserService();
    final user = await userService.restoreFromLocal();
    return user?.gender;
  }

  static Future<int?> getAge() async {
    final userService = UserService();
    final user = await userService.restoreFromLocal();
    return user?.age;
  }

  static Future<double?> getHeight() async {
    final userService = UserService();
    final user = await userService.restoreFromLocal();
    return user?.height;
  }

  static Future<double?> getWeight() async {
    final userService = UserService();
    final user = await userService.restoreFromLocal();
    return user?.weight;
  }

  static Future<String?> getLifestyle() async {
    final userService = UserService();
    final user = await userService.restoreFromLocal();
    return user?.lifestyle;
  }

  static Future<String?> getHasDietaryRestrictions() async {
    final userService = UserService();
    final user = await userService.restoreFromLocal();
    return user?.hasDietaryRestrictions;
  }

  static Future<String?> getDietaryRestrictionsList() async {
    final userService = UserService();
    final user = await userService.restoreFromLocal();
    return user?.dietaryRestrictionsList;
  }

  static Future<String?> getGoal() async {
    final userService = UserService();
    final user = await userService.restoreFromLocal();
    return user?.goal;
  }

  static Future<double?> getTargetWeight() async {
    final userService = UserService();
    final user = await userService.restoreFromLocal();
    return user?.targetWeight;
  }

  static Future<bool> isSetupComplete() async {
    final userService = UserService();
    final user = await userService.restoreFromLocal();
    return user?.isSetupComplete ?? false;
  }

    /// Lưu toàn bộ thông tin user vào local (dùng cho auto setup)
  static Future<bool> saveUserInfo({
    required String? name,
    required String? gender,
    required int? age,
    required double? height,
    required double? weight,
    required String? lifestyle,
    required String? hasDietaryRestrictions,
    required String? dietaryRestrictionsList,
    required String? goal,
    required double? targetWeight,
  }) async {
    try {
      final user = app_user.User(
        name: name ?? '',
        gender: gender ?? '',
        age: age ?? 0,
        height: height ?? 0,
        weight: weight ?? 0,
        lifestyle: lifestyle ?? '',
        hasDietaryRestrictions: hasDietaryRestrictions ?? 'No',
        dietaryRestrictionsList: dietaryRestrictionsList ?? 'None',
        goal: goal ?? '',
        targetWeight: targetWeight ?? 0,
      );

      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString('backup_user_profile', userJson);

      return true;
    } catch (e) {
      print('Error saving user info: $e');
      return false;
    }
  }

  /// Lấy thông tin user từ local
  static Future<app_user.User?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('backup_user_profile');
      if (userJson == null) return null;

      final data = jsonDecode(userJson) as Map<String, dynamic>;
      return app_user.User.fromJson(data);
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

   static Future<void> printUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    print("===== 🔎 DEBUG: USER INFO =====");
    print("Name: ${prefs.getString('name')}");
    print("Gender: ${prefs.getString('gender')}");
    print("Age: ${prefs.getInt('age')}");
    print("Height: ${prefs.getDouble('height')}");
    print("Weight: ${prefs.getDouble('weight')}");
    print("Lifestyle: ${prefs.getString('lifestyle')}");
    print("HasDietaryRestrictions: ${prefs.getString('hasDietaryRestrictions')}");
    print("DietaryRestrictionsList: ${prefs.getString('dietaryRestrictionsList')}");
    print("Goal: ${prefs.getString('goal')}");
    print("TargetWeight: ${prefs.getDouble('targetWeight')}");
    print("isSetupComplete: ${prefs.getBool('isSetupComplete') ?? false}");
    print("================================");
  }

  static Future<double?> calculateBMI() async {
    final user = await getCurrentUser();
    return BMIService().calculateBMIFromUser(user);
  }

  static Future<double?> calculateTDEE() async {
    final user = await getUserInfo();
    if (user == null) return null;
    return TDEEService().calculateTDEEFromUser(user);
  }

  /// Tính macro targets (grams protein, fat, carbs) dựa trên TDEE và goal
  static Future<Map<String, double>?> calculateMacroTargets() async {
    final user = await getUserInfo(); // hoặc getCurrentUser()
    if (user == null) return null;

    final tdee = TDEEService().calculateTDEEFromUser(user);
    if (tdee == null) return null;

    // Điều chỉnh calories theo goal
    double calorieAdjustment;
    switch (user.goal.toLowerCase()) {
      case 'lose weight':
        calorieAdjustment = 0.8;
        break;
      case 'gain muscle':
        calorieAdjustment = 1.15;
        break;
      case 'maintain':
      default:
        calorieAdjustment = 1.0;
    }
    final adjustedCalories = tdee * calorieAdjustment;

    // Tỉ lệ macro: protein 25%, fat 25%, carbs còn lại 50%
    final proteinCalories = adjustedCalories * 0.25;
    final fatCalories = adjustedCalories * 0.25;
    final carbsCalories = adjustedCalories - proteinCalories - fatCalories;

    // 1g protein = 4 cal, 1g carb = 4 cal, 1g fat = 9 cal
    final proteinGrams = proteinCalories / 4;
    final fatGrams = fatCalories / 9;
    final carbsGrams = carbsCalories / 4;

    return {
      'calories': double.parse(adjustedCalories.toStringAsFixed(1)),
      'protein': double.parse(proteinGrams.toStringAsFixed(1)),
      'fat': double.parse(fatGrams.toStringAsFixed(1)),
      'carbs': double.parse(carbsGrams.toStringAsFixed(1)),
    };
  }

  /// Lưu user profile lên Firebase
  Future<bool> saveUserProfile(app_user.User user) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      // Thêm timestamp và userId
      final userMap = user.toJson();
      userMap['uid'] = currentUser.uid;
      userMap['email'] = currentUser.email;
      userMap['createdAt'] = DateTime.now().toIso8601String();
      userMap['updatedAt'] = DateTime.now().toIso8601String();

      await _usersCollection.doc(currentUser.uid).set(userMap);
      
      // Xóa tên tạm thời sau khi lưu thành công
      await clearTempName();
      
      return true;
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  /// Lấy user profile từ Firebase
  Future<app_user.User?> getUserProfile([String? userId]) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('No user ID provided');
      }

      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return app_user.User.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Cập nhật user profile
  Future<bool> updateUserProfile(app_user.User user, [String? userId]) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('No user ID provided');
      }

      final userMap = user.toJson();
      userMap['updatedAt'] = DateTime.now().toIso8601String();

      await _usersCollection.doc(uid).update(userMap);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Cập nhật một field riêng lẻ
  Future<bool> updateField(String fieldName, dynamic value, [String? userId]) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('No user ID provided');
      }

      await _usersCollection.doc(uid).update({
        fieldName: value,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating field $fieldName: $e');
      return false;
    }
  }

  /// Cập nhật nhiều field cùng lúc
  Future<bool> updateFields(Map<String, dynamic> fields, [String? userId]) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('No user ID provided');
      }

      final updateData = Map<String, dynamic>.from(fields);
      updateData['updatedAt'] = DateTime.now().toIso8601String();

      await _usersCollection.doc(uid).update(updateData);
      return true;
    } catch (e) {
      print('Error updating fields: $e');
      return false;
    }
  }

  /// Cập nhật ảnh profile
  Future<bool> updateProfileImage(String imageUrl, [String? userId]) async {
    return await updateField('profileImageUrl', imageUrl, userId);
  }

  /// Kiểm tra user đã tồn tại chưa
  Future<bool> userExists([String? userId]) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) return false;

      final doc = await _usersCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  /// Xóa user profile
  Future<bool> deleteUserProfile([String? userId]) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('No user ID provided');
      }

      await _usersCollection.doc(uid).delete();
      return true;
    } catch (e) {
      print('Error deleting user profile: $e');
      return false;
    }
  }

  /// Stream user profile để lắng nghe thay đổi real-time
  Stream<app_user.User?> streamUserProfile([String? userId]) {
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(null);
    }

    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return app_user.User.fromJson(data);
      }
      return null;
    });
  }

  /// Lấy current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Lấy current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Kiểm tra user đã đăng nhập chưa
  bool get isUserLoggedIn => _auth.currentUser != null;

  /// Tạo user profile từ dữ liệu tạm thời
  Future<app_user.User?> createUserFromTempData() async {
    try {
      final tempName = await getName();
      if (tempName == null || tempName.isEmpty) return null;

      return app_user.User(
        name: tempName,
        gender: 'male', // default value
        age: 25,
        height: 170.0,
        weight: 70.0,
        lifestyle: 'moderately_active',
        hasDietaryRestrictions: 'no',
        dietaryRestrictionsList: '',
        goal: 'maintain_weight',
        targetWeight: 70.0,
      );
    } catch (e) {
      print('Error creating user from temp data: $e');
      return null;
    }
  }

  /// Backup user data to local storage (cho offline support)
  Future<void> backupToLocal(app_user.User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson()); // chuyển User -> JSON String
      await prefs.setString('backup_user_profile', userJson);
    } catch (e) {
      print('Error backing up to local: $e');
    }
  }

  /// Restore user data from local storage
  Future<app_user.User?> restoreFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString('backup_user_profile');
      if (userJsonString != null) {
        final data = jsonDecode(userJsonString) as Map<String, dynamic>;
        return app_user.User.fromJson(data); // parse JSON -> User object
      }
      return null;
    } catch (e) {
      print('Error restoring from local: $e');
      return null;
    }
  }
}