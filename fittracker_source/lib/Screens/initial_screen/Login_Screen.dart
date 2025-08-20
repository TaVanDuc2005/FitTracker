import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Register_Screen.dart';
import '../../services/user_service.dart';
import 'onboarding_controller.dart';
import 'Enter_Name_Screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LoginScreen({super.key, required this.onNext, required this.onBack});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkLoggedOnce();
  }

  Future<void> _checkLoggedOnce() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('hasLoggedOnce') ?? false;
      if (!seen) return;
      final local = await UserService.getUserInfo();
      final username = (local != null && local['username'] != null)
          ? local['username'].toString()
          : '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const StepProgressForm(),
            settings: RouteSettings(
              arguments: {
                'initialStep': 6,
                'username': username,
                'userid': username,
              },
            ),
          ),
        );
      });
    } catch (_) {}
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final usernameInput = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      final usersColl = FirebaseFirestore.instance.collection('users');
      final query = await usersColl
          .where('username', isEqualTo: usernameInput)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not found')));
        return;
      }

      final docSnap = query.docs.first;
      final storedPw = docSnap['password'];
      if (storedPw != password) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Wrong password')));
        return;
      }

      // Auth OK, lấy dữ liệu user từ Firestore
      final userData = docSnap.data();
      final uid = docSnap.id;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasLoggedOnce', true);
        await prefs.setString('lastUsername', usernameInput);
      } catch (_) {}

      // Danh sách các field cần kiểm tra
      final order = [
        'name',
        'gender',
        'age',
        'height',
        'weight',
        'lifestyle',
        'hasDietaryRestrictions',
        'healthGoal',
        'targetWeight',
      ];

      String? firstMissing;
      for (final k in order) {
        final v = userData[k];
        if (v == null ||
            (v is String && v.trim().isEmpty) ||
            (v is num && v <= 0)) {
          firstMissing = k;
          break;
        }
      }

      if (firstMissing == null) {
        // tất cả đầy -> vào main/journal
        if (!mounted) return;
        setState(() => _isLoading = false);
        widget.onNext();
        return;
      }

      // Map missing field -> step index
      int stepIndex;
      switch (firstMissing) {
        case 'name':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const EnterNameScreen(),
              settings: RouteSettings(
                arguments: {'username': usernameInput, 'userid': uid},
              ),
            ),
          );
          return;
        case 'gender':
        case 'age':
        case 'height':
        case 'weight':
          stepIndex = 1;
          break;
        case 'lifestyle':
          stepIndex = 2;
          break;
        case 'hasDietaryRestrictions':
          stepIndex = 3;
          break;
        case 'healthGoal':
          stepIndex = 6;
          break;
        case 'targetWeight':
          stepIndex = 7;
          break;
        default:
          stepIndex = 1;
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const StepProgressForm(),
          settings: RouteSettings(
            arguments: {
              'initialStep': stepIndex,
              'username': usernameInput,
              'userid': uid,
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (email)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter a username'
                    : null,
              ),
              const SizedBox(height: 12),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => v == null || v.length < 8
                    ? 'Password must be at least 8 characters'
                    : null,
              ),
              const SizedBox(height: 20),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Log in'),
                ),
              ),
              const SizedBox(height: 12),

              // Sign up
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Sign up"),
              ),

              const Spacer(),

              // Back
              TextButton(onPressed: widget.onBack, child: const Text("Back")),
            ],
          ),
        ),
      ),
    );
  }
}
