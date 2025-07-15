import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // thêm constructor có key (Flutter 3+)

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Flutter',
      home: const DemoPage(), // Sử dụng trang vừa tạo
    );
  }
}
