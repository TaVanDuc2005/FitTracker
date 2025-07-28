import 'package:flutter/material.dart';
import 'package:fittracker_source/Screens/active_screen/journal/journal_screen.dart';
import '../../services/user_service.dart';
import 'On_boarding_Screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserData();
  }

  Future<void> _checkUserData() async {
    try {
      print('🔍 Welcome Screen: Checking existing user data...');

      // Check if setup is completed
      final isSetupComplete = await UserService.isSetupComplete();
      print('   ✓ Setup complete: $isSetupComplete');

      if (isSetupComplete) {
        // Double-check by getting actual user info
        final userInfo = await UserService.getUserInfo();

        if (userInfo != null &&
            userInfo['name'] != null &&
            userInfo['weight'] != null &&
            userInfo['height'] != null) {
          print('   ✓ Valid user data found: ${userInfo['name']}');
          print('   🚀 Auto-navigating to Journal Screen...');

          // ✅ AUTO NAVIGATE: Vào Journal luôn
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const JournalScreen()),
            );
          }
          return;
        }
      }

      // No valid user data found - Welcome screen sẽ hiện
      print('   ❌ No valid user data - showing welcome screen');
    } catch (e) {
      print('❌ Error checking user data: $e');
      // Welcome screen sẽ hiện khi có lỗi
    }
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

            // 📝 Tiêu đề và mô tả
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.self_improvement,
                    size: 80,
                    color: Color.fromRGBO(76, 175, 80, 1),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your personalized plan',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // 🚀 Nút Start
            Align(
              alignment: const Alignment(0, 0.75),
              child: ElevatedButton(
                onPressed: () {
                  print('🚀 Starting onboarding process...');
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
                    Icon(Icons.play_arrow, color: Colors.white, size: 20),
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
