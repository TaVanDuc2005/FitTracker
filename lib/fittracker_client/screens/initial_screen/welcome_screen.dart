import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../screens/active_screen/journal/journal_screen.dart';
import 'onboarding/onboarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // PHẦN TRÊN: Tiêu đề và icon trang trí
            Expanded(
              child: Stack(
                children: [
                  // 🌿 Các biểu tượng trang trí
                  Positioned(
                    top: 90,
                    left: 50,
                    child: Image.asset(
                      'Assets/Images/Welcome3.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: -50,
                    child: Image.asset(
                      'Assets/Images/Welcome5.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: -40,
                    child: Image.asset(
                      'Assets/Images/Welcome2.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 60,
                    child: Image.asset(
                      'Assets/Images/Welcome4.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  // 📝 Tiêu đề và mô tả
                  Positioned(
                    top: 180,
                    left: 50,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "fittracker",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Personalized nutrition for\nevery motivation",
                          style: TextStyle(fontSize: 20, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // PHẦN DƯỚI: Ảnh - Nút Start - Login
            Column(
              children: [
                // 🧘 Hình ảnh
                Image.asset(
                  'Assets/Images/Welcome1.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 8),

                // 🚀 Nút Start
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(),
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Start",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(
                              onNext: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const JournalScreen(),
                                  ),
                                );
                              },
                              onBack: () {
                                Navigator.pop(context); // Quay lại màn Welcome
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
