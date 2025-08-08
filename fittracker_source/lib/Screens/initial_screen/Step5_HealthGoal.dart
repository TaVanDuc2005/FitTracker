import 'package:flutter/material.dart';
import 'Loading_Screen.dart';
import '../../services/user_service.dart';
import 'Step1_UserInfo.dart';
import 'Recommend.dart';

class Step5HealthGoal extends StatefulWidget {
  final VoidCallback onBack;

  const Step5HealthGoal({super.key, required this.onBack});

  @override
  State<Step5HealthGoal> createState() => _Step5SummaryState();
}

class _Step5SummaryState extends State<Step5HealthGoal> {
  String? selectedGoal;
  double? bmi;
  String? gender;
  int? age;
  double? height;
  double? weight;

  final List<String> options = [
    "Weight loss",
    "Weight gain",
    "Muscle building",
    "Maintain weight",
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedGoal = await UserService.getGoal();
    final savedGender = await UserService.getGender();
    final savedAge = await UserService.getAge();
    final savedHeight = await UserService.getHeight();
    final savedWeight = await UserService.getWeight();

    setState(() {
      gender = savedGender;
      age = savedAge;
      height = savedHeight;
      weight = savedWeight;

      if (savedHeight != null && savedWeight != null && savedHeight > 0) {
        bmi = savedWeight / ((savedHeight / 100) * (savedHeight / 100));
      }

      if (savedGoal != null && savedGoal.isNotEmpty) {
        selectedGoal = savedGoal.split(',').first.trim();
      }
    });
  }

  Future<void> _saveGoals() async {
    if (selectedGoal != null && selectedGoal!.isNotEmpty) {
      final success = await UserService.updateGoal(selectedGoal!);
      if (success) {
        print('✅ Health goal saved: $selectedGoal');
      } else {
        print('❌ Failed to save health goal');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // hoặc màu bạn muốn
      body: Column(
        children: [
          // Title
          Container(
            padding: const EdgeInsets.fromLTRB(30, 60, 30, 20),
            child: const Text(
              "What are your health goals?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),

          if (bmi != null && gender != null && age != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "BMI: ${bmi!.toStringAsFixed(1)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text("Gender: $gender", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Age: $age", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                ],
              ),
            ),

          // Options list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: options.map((item) {
                  final isSelected = selectedGoal == item;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGoal = item;
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
                                color: isSelected ? Colors.green : Colors.grey,
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

          // Buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                ElevatedButton(
                  onPressed: widget.onBack,
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

                // Finish / Save button
                if (selectedGoal != null)
                  ElevatedButton(
                    onPressed: () async {
                      await _saveGoals();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecommendScreen(
                            height: height ?? 170, // fallback nếu null
                            weight: weight ?? 60,
                            goal: selectedGoal!,
                          ),
                        ),
                      );

                      /*showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Setup Complete"),
                        content: const Text(
                          "Your health goals have been saved.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );*/
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
    );
  }
}