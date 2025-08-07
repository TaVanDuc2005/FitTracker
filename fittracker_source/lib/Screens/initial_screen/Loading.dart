import 'package:flutter/material.dart';
import 'Step5_HealthGoal.dart'; // Import đúng file đích bạn muốn chuyển đến
import 'Step4_ListDietaryRestriction.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    // Chờ 2 giây rồi chuyển sang màn hình tiếp theo
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Step5HealthGoal(), // Đúng tên class
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(), // Vòng loading
      ),
    );
  }
}
