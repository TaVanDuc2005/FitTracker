import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm dòng này
import '../../models/user.dart';
import '../core/database_service.dart';
import '../core/storage_service.dart';


class UserService {
  final String endpoint = 'users'; // JSON server endpoint

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

  /// Lấy tất cả user
  Future<List<User>> getAllUsers() async {
    final data = await DatabaseService.getData(endpoint);
    return data.map((json) => User.fromJson(json)).toList();
  }

  /// Lấy user theo ID
  Future<User> getUserById(String id) async {
    final data = await DatabaseService.getData(endpoint);
    final userJson = data.firstWhere((json) => json['id'] == id);
    return User.fromJson(userJson);
  }

  /// Tạo user mới
  Future<User> createUser(User user) async {
    final json = await DatabaseService.postData(endpoint, user.toJson());
    return User.fromJson(json);
  }

  /// Cập nhật user
  Future<User> updateUser(String id, User user) async {
    final json = await DatabaseService.putData(endpoint, id, user.toJson());
    return User.fromJson(json);
  }

  /// Xóa user
  Future<void> deleteUser(String id) async {
    await DatabaseService.deleteData(endpoint, id);
  }

  /// Upload ảnh profile và cập nhật URL
  Future<User> uploadProfilePicture(String userId, File file) async {
    final imageUrl = await StorageService.uploadFile(file, 'profile');
    final user = await getUserById(userId);
    final updatedUser = User(
      name: user.name,
      gender: user.gender,
      age: user.age,
      height: user.height,
      weight: user.weight,
      lifestyle: user.lifestyle,
      hasDietaryRestrictions: user.hasDietaryRestrictions,
      dietaryRestrictionsList: user.dietaryRestrictionsList,
      goal: user.goal,
      targetWeight: user.targetWeight,
    );

    final json = await DatabaseService.putData(
      endpoint,
      userId,
      {
        ...updatedUser.toJson(),
        'avatarUrl': imageUrl, // thêm trường ảnh
      },
    );

    return User.fromJson(json);
  }

  /// Cập nhật một field riêng lẻ
  Future<User> updateField(String userId, String key, dynamic value) async {
    final user = await getUserById(userId);
    final updatedJson = {
      ...user.toJson(),
      key: value,
    };
    final json = await DatabaseService.putData(endpoint, userId, updatedJson);
    return User.fromJson(json);
  }
}
