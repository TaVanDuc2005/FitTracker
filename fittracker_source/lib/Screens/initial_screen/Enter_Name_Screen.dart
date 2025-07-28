// file: enter_name_screen.dart

import 'package:flutter/material.dart';
import 'User_Info_Screen.dart';
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

  // THÊM: Hàm load name đã lưu
  Future<void> _loadSavedName() async {
    final savedName = await UserService.getName();
    if (savedName != null && savedName.isNotEmpty) {
      if (mounted) {
        setState(() {
          _nameController.text = savedName; // TỰ ĐỘNG ĐIỀN NAME
          _isButtonVisible = true; // HIỆN NÚT NEXT
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
            const Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Icon(
                  Icons.local_florist,
                  color: Colors.yellow,
                  size: 70,
                ),
              ),
            ),

            // Tiêu đề
            Positioned(
              top: 100,
              left: 30,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Center(
                    child: Text(
                      "Enter your name",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Let's get to know each other 😄 \nWhat is your name?",
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
              top: 240,
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
                    final name = _nameController.text.trim();

                    if (name.isNotEmpty) {
                      // LƯU NAME TẠM THỜI VÀO STORAGE
                      await UserService.saveName(name);
                      print('✅ Name saved: $name');
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserInfoScreen(),
                      ),
                    );
                  }, // THÊM dấu ph
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
