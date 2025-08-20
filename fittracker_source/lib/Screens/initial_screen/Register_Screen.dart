import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fittracker_source/services/user_service.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_controller.dart'; // for StepProgressForm
import 'dart:io';
import 'package:flutter/foundation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Lấy thông tin từ UserService
    final rawInfo = await UserService.getUserInfo();
    final Map<String, dynamic> userInfo = rawInfo ?? {};

    // username + password từ form
    userInfo['username'] =
        (userInfo['username'] as String?) ?? _usernameController.text.trim();

    final pwd = _passwordController.text.trim();
    if (pwd.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a password')));
      return;
    }
    userInfo['password'] = pwd;

    // Khởi tạo Firebase nếu chưa
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    try {
      final users = FirebaseFirestore.instance.collection('users');

      // ✅ Lấy danh sách userid hiện có
      final snapshot = await users.get();
      final existingIds = snapshot.docs.map((d) => d.id).toList();
      existingIds.sort();

      // ✅ Tìm số nhỏ nhất chưa dùng
      int i = 1;
      while (existingIds.contains(i.toString().padLeft(3, '0'))) {
        i++;
      }
      final docId = i.toString().padLeft(3, '0');

      // Chọn docId
      final username = (userInfo['username'] as String).trim();

      // Làm sạch dữ liệu trước khi lưu
      final Map<String, dynamic> cleaned = {};
      userInfo.forEach((k, v) {
        if (['password', 'confirm', 'token'].contains(k.toLowerCase())) return;
        if (v != null) cleaned[k] = v;
      });

      // Load JSON template
      Map<String, dynamic> template;
      try {
        final String jsonTemplate = await rootBundle.loadString(
          'assets/user_profile.json',
        );
        final parsed = jsonDecode(jsonTemplate);
        if (parsed is Map) {
          template = Map<String, dynamic>.from(parsed);
        } else {
          throw Exception('Template is not a JSON object');
        }
      } catch (e) {
        debugPrint('Failed to load template asset: $e — using default order');
        template = {
          'userid': null,
          'username': null,
          'password': null,
          'name': null,
          'gender': null,
          'age': null,
          'height': null,
          'weight': null,
          'lifestyle': null,
          'hasDietaryRestrictions': null,
          'dietaryRestrictionsList': null,
          'healthGoal': null,
          'targetWeight': null,
        };
      }

      // Duyệt theo thứ tự keys trong JSON mẫu
      final Map<String, dynamic> dataToSave = {};
      for (final key in template.keys) {
        if (key == 'userid') {
          dataToSave[key] = docId;
        } else if (key == 'password') {
          dataToSave[key] = pwd; // luôn có vì đã check ở trên
        } else {
          dataToSave[key] = cleaned.containsKey(key) ? cleaned[key] : null;
        }
      }
      // Ensure username present in saved doc (template might not include it)
      if (!dataToSave.containsKey('username') ||
          dataToSave['username'] == null) {
        dataToSave['username'] = username;
      }

      // Normalize numeric fields (allow strings from cleaned)
      int? _parseInt(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        final s = v.toString().trim();
        if (s.isEmpty) return null;
        return int.tryParse(s);
      }

      double? _parseDouble(dynamic v) {
        if (v == null) return null;
        if (v is double) return v;
        if (v is int) return v.toDouble();
        final s = v.toString().trim();
        if (s.isEmpty) return null;
        return double.tryParse(s.replaceAll(',', '.'));
      }

      dataToSave['age'] = _parseInt(dataToSave['age']);
      dataToSave['height'] = _parseDouble(dataToSave['height']);
      dataToSave['weight'] = _parseDouble(dataToSave['weight']);
      dataToSave['targetWeight'] = _parseDouble(dataToSave['targetWeight']);

      // ---- Compute isSetupComplete ----
      bool _isEmptyValue(dynamic v, String key) {
        if (v == null) return true;
        if (v is num) return v <= 0;
        if (v is String) {
          final s = v.trim();
          if (s.isEmpty) return true;
          const numericKeys = {'age', 'height', 'weight', 'targetWeight'};
          if (numericKeys.contains(key)) {
            final parsed = double.tryParse(s.replaceAll(',', '.'));
            return parsed == null || parsed <= 0;
          }
        }
        return false;
      }

      // include both 'goal' and 'healthGoal' in case template uses one or the other
      const requiredForComplete = [
        'name',
        'gender',
        'age',
        'height',
        'weight',
        'lifestyle',
        'hasDietaryRestrictions',
        'dietaryRestrictionsList',
        'healthGoal',
        'targetWeight',
      ];
      final bool complete = requiredForComplete.every(
        (k) => !_isEmptyValue(dataToSave[k], k),
      );
      dataToSave['isSetupComplete'] = complete;
      dataToSave['registeredAt'] = FieldValue.serverTimestamp();
      // ---- end compute ----

      // Lưu Firestore
      await users.doc(docId).set(dataToSave);

      // ✅ Xóa dữ liệu local trong UserService sau khi đăng ký thành công
      await UserService.clearUserInfo();

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop({'username': docId});
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu vào Firestore thất bại: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Please enter a username';
                  if (v.trim().length < 3) return 'Username too short';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure1 ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.length < 8)
                    return 'At least 8 characters required';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure2 ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
                validator: (v) {
                  if (v != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
