import 'package:flutter/material.dart';
import 'package:fittracker_client/services/notification_service.dart';
import 'Screens/initial_screen/Welcome_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
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
