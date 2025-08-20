import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart' as app_user;

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  
  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

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
      final userJson = user.toJson();
      await prefs.setString('backup_user_profile', userJson.toString());
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
        return null; // Implement proper JSON parsing if needed
      }
      return null;
    } catch (e) {
      print('Error restoring from local: $e');
      return null;
    }
  }
}