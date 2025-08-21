import 'package:flutter/material.dart';
import 'onboarding/onboarding_controller.dart';
import '../../services/user/user_service.dart';

class EnterNameScreen extends StatefulWidget {
  const EnterNameScreen({super.key});

  @override
  State<EnterNameScreen> createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onTextChanged);
    _loadSavedName();
  }

  Future<void> _loadSavedName() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final savedName = await UserService.getName();
      if (savedName != null && savedName.isNotEmpty && mounted) {
        setState(() {
          _nameController.text = savedName;
          _isButtonVisible = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      print('Error loading saved name: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load saved name';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onTextChanged() {
    final text = _nameController.text.trim();
    final hasText = text.isNotEmpty;
    
    // Validate name
    String? error;
    if (text.isNotEmpty) {
      if (text.length < 2) {
        error = 'Name must be at least 2 characters';
      } else if (text.length > 50) {
        error = 'Name is too long (maximum 50 characters)';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
        error = 'Name can only contain letters and spaces';
      }
    }
    
    if (_isButtonVisible != (hasText && error == null) || _errorMessage != error) {
      setState(() {
        _isButtonVisible = hasText && error == null;
        _errorMessage = error;
      });
    }
  }

  Future<void> _saveNameAndContinue() async {
    final name = _nameController.text.trim();
    
    // Final validation
    if (name.isEmpty) {
      _showErrorSnackBar('Please enter your name');
      return;
    }
    
    if (name.length < 2) {
      _showErrorSnackBar('Name must be at least 2 characters');
      return;
    }
    
    if (name.length > 50) {
      _showErrorSnackBar('Name is too long (maximum 50 characters)');
      return;
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      _showErrorSnackBar('Name can only contain letters and spaces');
      return;
    }

    // Hide keyboard and show loading
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      // Save name to SharedPreferences
      await UserService.saveName(name);
      
      // Debug log
      print('✅ Name saved temporarily: $name');
      
      if (mounted) {
        // Navigate to next screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StepFlow()),
        );
      }
    } catch (e) {
      print('❌ Error saving name: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to save your name. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned(
              top: 40,
              left: 80,
              child: Image.asset(
                'Assets/Images/Enter_name.png',
                width: 250,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 250,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
            
            // Title Section
            Positioned(
              top: 200,
              left: 30,
              right: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Center(
                    child: Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Let's get to know each other 😍 \nWhat is your name?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // TextField Section
            Positioned(
              top: 380,
              left: 30,
              right: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 50,
                    decoration: InputDecoration(
                      hintText: 'First Name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: _isLoading ? Colors.grey[100] : const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      counterText: '', // Hide character counter
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                          color: _errorMessage != null ? Colors.red : const Color(0xFFE0E0E0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                          color: _errorMessage != null ? Colors.red : Colors.black87,
                          width: 2,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[600],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Next Button
            if (_isButtonVisible && !_isLoading)
              Positioned(
                bottom: 120,
                left: 30,
                right: 30,
                child: ElevatedButton(
                  onPressed: _saveNameAndContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.black87,
                    elevation: 4,
                    shadowColor: Colors.black26,
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18, 
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // Loading Button
            if (_isLoading)
              Positioned(
                bottom: 120,
                left: 30,
                right: 30,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Saving...",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}