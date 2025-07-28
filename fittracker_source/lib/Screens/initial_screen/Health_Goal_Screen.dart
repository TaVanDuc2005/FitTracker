import 'package:flutter/material.dart';
import 'Loading_Screen.dart';
import '../../services/user_service.dart'; // THÊM IMPORT

class healthGoalsScreen extends StatefulWidget {
  const healthGoalsScreen({super.key});

  @override
  State<healthGoalsScreen> createState() => _HealthGoalsScreenState(); // SỬA TÊN CLASS
}

class _HealthGoalsScreenState extends State<healthGoalsScreen> {
  // SỬA TÊN CLASS
  List<String> selectedGoals = []; // SỬA TÊN BIẾN

  final List<String> options = [
    "Weight loss",
    "Weight gain",
    "Muscle building",
    "Maintain weight",
    "Other",
  ];

  @override
  void initState() {
    // THÊM initState
    super.initState();
    _loadSavedGoals();
  }

  // THÊM: Load health goals đã lưu
  Future<void> _loadSavedGoals() async {
    final savedGoal = await UserService.getGoal();
    if (savedGoal != null && savedGoal.isNotEmpty) {
      if (mounted) {
        setState(() {
          // Chuyển từ string thành list (split by comma)
          selectedGoals = savedGoal
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        });
      }
    }
  }

  // THÊM: Lưu health goals
  Future<void> _saveGoals() async {
    if (selectedGoals.isNotEmpty) {
      // Chuyển từ list thành string (join by comma)
      final goalsString = selectedGoals.join(', ');
      final success = await UserService.updateGoal(goalsString);
      if (success) {
        print('✅ Health goals saved: $goalsString');
      } else {
        print('❌ Failed to save health goals');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Text positioned at top
            Container(
              padding: const EdgeInsets.fromLTRB(30, 60, 30, 20),
              child: const Text(
                "What are your health goals?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),

            // Options list - scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: options.map((item) {
                    final isSelected = selectedGoals.contains(
                      item,
                    ); // SỬA TÊN BIẾN
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedGoals.remove(item); // SỬA TÊN BIẾN
                          } else {
                            selectedGoals.add(item); // SỬA TÊN BIẾN
                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFF0D9)
                              : const Color(0xFFF7F9FB),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[800],
                                ),
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),

                  // Next button - SỬA ĐỂ LƯU DỮ LIỆU
                  if (selectedGoals.isNotEmpty) // SỬA TÊN BIẾN
                    ElevatedButton(
                      onPressed: () async {
                        // THÊM async
                        // LƯU HEALTH GOALS TRƯỚC KHI CHUYỂN TRANG
                        await _saveGoals();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoadingScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
