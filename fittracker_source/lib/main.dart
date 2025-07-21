import 'package:flutter/material.dart';
import 'Screens/active_screen/Journal/journal.dart';

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
<<<<<<< HEAD
      home: const JournalScreen(), 
=======
      home: const WelcomeScreen(),
>>>>>>> fbdd74d725f08efff293ca556fa2f841ebdb886d
    );
  }
}
