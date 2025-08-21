import 'package:flutter/material.dart';
import '../../../services/user/user_service.dart';
import '../../../models/user.dart' as app_user;

class RangeProgressBar extends StatelessWidget {
  final double minValue;
  final double maxValue;
  final double currentValue;
  final String label;
  final Color barColor;

  const RangeProgressBar({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.currentValue,
    required this.label,
    this.barColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    double progress = ((currentValue - minValue) / (maxValue - minValue)).clamp(
      0.0,
      1.0,
    );

    final barWidth = MediaQuery.of(context).size.width - 48;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: barColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            Positioned(
              left: (progress * barWidth).clamp(0, barWidth - 20),
              top: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: barColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              minValue.toStringAsFixed(1),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              maxValue.toStringAsFixed(1),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class Step5HealthGoal extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const Step5HealthGoal({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<Step5HealthGoal> createState() => _Step5HealthGoalState();
}

class _Step5HealthGoalState extends State<Step5HealthGoal> {
  String? selectedGoal;
  double? bmi;
  final UserService _userService = UserService();
  app_user.User? _tempUser;

  final Map<String, String> goalMapping = {
    "Weight loss": "lose_weight",
    "Weight gain": "gain_weight", 
    "Muscle building": "build_muscle",
    "Maintain weight": "maintain_weight",
  };

  final List<String> options = [
    "Weight loss",
    "Weight gain",
    "Muscle building",
    "Maintain weight",
  ];

  final Map<String, List<double>> bmiRanges = {
    "Weight loss": [18.5, 24.9],
    "Weight gain": [25.0, 29.9],
    "Muscle building": [20.0, 30.0],
    "Maintain weight": [18.5, 24.9],
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      // Thử restore từ backup local trước
      _tempUser = await _userService.restoreFromLocal();
      
      // Nếu không có backup, tạo từ temp data
      if (_tempUser == null) {
        _tempUser = await _userService.createUserFromTempData();
      }
      
      // Nếu vẫn không có, tạo user mới với tên đã lưu
      if (_tempUser == null) {
        final savedName = await UserService.getName();
        if (savedName != null) {
          _tempUser = app_user.User(name: savedName);
        }
      }
      
      if (_tempUser != null && mounted) {
        // Tính BMI
        final height = _tempUser!.height;
        final weight = _tempUser!.weight;
        if (height > 0) {
          bmi = weight / ((height / 100) * (height / 100));
        }

        // Tìm goal option phù hợp với giá trị đã lưu
        final savedGoal = _tempUser!.goal;
        String? matchingOption;
        
        for (var entry in goalMapping.entries) {
          if (entry.value == savedGoal) {
            matchingOption = entry.key;
            break;
          }
        }

        setState(() {
          selectedGoal = matchingOption;
        });
      }
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }

  Future<void> _saveTempData() async {
    if (_tempUser == null || selectedGoal == null) return;
    
    // Map UI option to model value
    final goalValue = goalMapping[selectedGoal!] ?? "maintain_weight";
    
    // Calculate target weight based on goal and current BMI
    double targetWeight = _tempUser!.weight;
    if (selectedGoal == "Weight loss" && bmi != null && bmi! > 24.9) {
      // Target BMI of 22 for weight loss
      targetWeight = 22 * ((_tempUser!.height / 100) * (_tempUser!.height / 100));
    } else if (selectedGoal == "Weight gain" && bmi != null && bmi! < 20) {
      // Target BMI of 23 for weight gain
      targetWeight = 23 * ((_tempUser!.height / 100) * (_tempUser!.height / 100));
    }
    
    _tempUser = _tempUser!.copyWith(
      goal: goalValue,
      targetWeight: targetWeight,
    );
    
    // Backup to local storage
    await _userService.backupToLocal(_tempUser!);
    print('✅ Health goal saved: $selectedGoal');
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25.0) return "Normal";
    if (bmi < 30.0) return "Overweight";
    return "Obese";
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25.0) return Colors.green;
    if (bmi < 30.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final range = selectedGoal != null ? bmiRanges[selectedGoal!] : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Container(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Health Goals",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "What are your health goals?",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // BMI and user info card
            if (bmi != null && _tempUser != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.orange.shade50,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _infoItem("BMI", bmi!.toStringAsFixed(1)),
                          _infoItem("Category", _getBMICategory(bmi!)),
                          _infoItem("Age", _tempUser!.age.toString()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getBMIColor(bmi!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _getBMIColor(bmi!), width: 1),
                        ),
                        child: Text(
                          "Current: ${_tempUser!.weight.toStringAsFixed(1)} kg | Height: ${_tempUser!.height.toStringAsFixed(0)} cm",
                          style: TextStyle(
                            fontSize: 12,
                            color: _getBMIColor(bmi!),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      // BMI Range progress bar
                      if (range != null) ...[
                        const SizedBox(height: 16),
                        RangeProgressBar(
                          minValue: range[0],
                          maxValue: range[1],
                          currentValue: bmi!,
                          label: "Recommended BMI for $selectedGoal",
                          barColor: Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Goal options
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
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFF0D9)
                              : const Color(0xFFF7F9FB),
                          borderRadius: BorderRadius.circular(24),
                          border: isSelected
                              ? Border.all(color: Colors.orange.shade200, width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[800],
                                ),
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? Colors.orange : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
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
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Back"),
                  ),

                  // Next button
                  if (selectedGoal != null)
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await _saveTempData();
                          widget.onNext();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error saving data: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
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