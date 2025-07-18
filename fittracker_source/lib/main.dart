import 'package:flutter/material.dart';
import 'Screens/initial_screen/Page5.dart'; // Đảm bảo bạn đã tạo file này trong lib/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const LifestyleScreen(), // Gọi màn hình bạn vừa tạo
    );
  }
}
