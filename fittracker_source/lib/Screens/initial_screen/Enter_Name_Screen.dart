import 'package:flutter/material.dart';
import 'onboarding_controller.dart';
import 'package:fittracker_source/services/user_service.dart'; // THÊM IMPORT

class EnterNameScreen extends StatefulWidget {
  const EnterNameScreen({super.key});

  @override
  State<EnterNameScreen> createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onTextChanged);
    _loadSavedName();
  }

  Future<void> _loadSavedName() async {
    final savedName = await UserService.getName();
    if (savedName != null && savedName.isNotEmpty) {
      if (mounted) {
        setState(() {
          _nameController.text = savedName;
          _isButtonVisible = true;
        });
      }
    }
  }

  void _onTextChanged() {
    setState(() {
      _isButtonVisible = _nameController.text.trim().isNotEmpty;
    });
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
            Positioned(
                    top: 40,
                    left: 80,
                    child: Image.asset(
                      'Assets/Images/Enter_name.png',
                      width: 250,
                      height: 200,
                    ),
                  ),
            // Tiêu đề
            Positioned(
              top: 200,
              left: 30,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Center(
                    child: Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Let's get to know each other 😍 \nWhat is your name?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // TextField
            Positioned(
              top: 380,
              left: 30,
              right: 30,
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'First Name',
                  filled: true,
                  fillColor: Color(0xFFF8FAFC),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
              ),
            ),

            // Nút Next
            if (_isButtonVisible)
              Align(
                alignment: const Alignment(0, 0.75),
                child: ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    final name = _nameController.text.trim();

                    if (name.isNotEmpty) {
                      // LƯU NAME TẠM THỜI VÀO STORAGE
                      await UserService.saveName(name);
                      print('✅ Name saved: $name');
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StepProgressForm(),
                      ),
                    );
                  },  
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.black87,
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
