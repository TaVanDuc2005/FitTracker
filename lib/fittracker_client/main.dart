import 'package:flutter/material.dart';
import 'services/user/notification_service.dart';
import 'Screens/initial_screen/Welcome_Screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Firebase
  await Firebase.initializeApp();

  // 2. Khởi tạo Notification
  await NotificationService.initialize();

  // 3. Chạy app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const WelcomeScreen(),
    );
  }
}
