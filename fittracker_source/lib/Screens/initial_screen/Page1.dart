import 'package:flutter/material.dart';
import 'Page2.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 🌿 Icon trang trí bốn góc
            const Positioned(
              top: 90,
              left: 80,
              child: Icon(Icons.eco, color: Colors.greenAccent, size: 40),
            ),
            const Positioned(
              top: 90,
              right: 0,
              child: Icon(Icons.local_florist, color: Colors.orange, size: 40),
            ),
            const Positioned(
              bottom: 320,
              left: 0,
              child: Icon(Icons.star, color: Colors.redAccent, size: 40),
            ),
            const Positioned(
              bottom: 330,
              right: 60,
              child: Icon(Icons.sunny, color: Colors.amber, size: 40),
            ),

            // 📝 Tiêu đề và mô tả (trên cùng, lệch trái 20)
            Positioned(
              top: 180,
              left: 30,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "FitTracker",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Personalized nutrition for\nevery motivation",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // 🧘 Icon thiền ở giữa màn hình
            const Align(
              alignment: Alignment(0, 0.6),
              child: Icon(
                Icons.self_improvement,
                size: 80,
                color: Color.fromRGBO(76, 175, 80, 1),
              ),
            ),

            // 🚀 Nút Start ở gần cuối màn hình
            Align(
              alignment: const Alignment(0, 0.75),
              child: ElevatedButton(
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
                child: const Text("Start", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
