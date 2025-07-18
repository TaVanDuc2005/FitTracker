import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onTextChanged);
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
            // 🌿 Icon trang trí bốn góc
            const Positioned(
              top: 20,
              left: 0,
              right: 0, // thêm vào để dùng toàn bộ chiều ngang
              child: Center(
                child: Icon(
                  Icons.local_florist,
                  color: Colors.yellow,
                  size: 70,
                ),
              ),
            ),

            // 📝 Tiêu đề và mô tả (trên cùng, lệch trái 20)
            Positioned(
              top: 100,
              left: 30,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Center(
                    // bọc lại để chắc chắn Text nằm giữa
                    child: Text(
                      "Welcome",
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

            Positioned(
              top: 240,
              left: 30,
              right: 30,
              child: TextField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                autocorrect: true,
                enableSuggestions: true,
                enableIMEPersonalizedLearning: true,
                smartDashesType: SmartDashesType.enabled,
                smartQuotesType: SmartQuotesType.enabled,
                style: const TextStyle(fontSize: 16, color: Colors.black),
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

            // 🚀 Nút Start ở gần cuối màn hình
            if (_isButtonVisible)
              Align(
                alignment: const Alignment(0, 0.75),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Thêm điều hướng sang màn hình tiếp theo
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
                  child: const Text("Next", style: TextStyle(fontSize: 18)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
