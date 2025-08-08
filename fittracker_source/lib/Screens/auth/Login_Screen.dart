import 'package:flutter/material.dart';
import 'Register_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);

    final username = _usernameController.text.trim();
    Navigator.of(context).pop({'username': username});
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
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
<<<<<<< HEAD
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a username' : null,
=======
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter a username'
                    : null,
>>>>>>> 9115f8365ea0432247877f76e2b577bd48dc033a
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
<<<<<<< HEAD
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                    v == null || v.length < 8 ? 'Password must be at least 8 characters' : null,
=======
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => v == null || v.length < 8
                    ? 'Password must be at least 8 characters'
                    : null,
>>>>>>> 9115f8365ea0432247877f76e2b577bd48dc033a
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                child: _isLoading
                    ? const SizedBox(
<<<<<<< HEAD
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
=======
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
>>>>>>> 9115f8365ea0432247877f76e2b577bd48dc033a
                    : const Text('Log in'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Sign up"),
<<<<<<< HEAD
              )
=======
              ),
>>>>>>> 9115f8365ea0432247877f76e2b577bd48dc033a
            ],
          ),
        ),
      ),
    );
  }
}
