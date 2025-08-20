import 'package:flutter/material.dart';
import '../../services/user_service.dart';

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

  Future<void> _saveGoal() async {
    if (selectedGoal != null && selectedGoal!.isNotEmpty) {
      final success = await UserService.updateGoal(selectedGoal!);
      if (!success) {
        print('❌ Failed to save health goal');
      } else {
        print('✅ Health goal saved: $selectedGoal');
      }
    }
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Map<String, List<double>> bmiRanges = {
    "Weight loss": [18.5, 24.9],
    "Weight gain": [25.0, 29.9],
    "Muscle building": [20.0, 30.0],
    "Maintain weight": [18.5, 24.9],
  };

  @override
  Widget build(BuildContext context) {
    final range = selectedGoal != null ? bmiRanges[selectedGoal!] : null;

    return Column(
      children: [
        // Title
        Container(
          padding: const EdgeInsets.fromLTRB(30, 60, 30, 20),
          child: const Text(
            "What are your health goals?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),

        // BMI, gender, age info card
        if (bmi != null && gender != null && age != null)
          Card(
            elevation: 3,
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
                      _infoItem("Gender", gender!),
                      _infoItem("Age", age.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Thanh range progress bar cho BMI dựa theo goal
                  if (range != null)
                    RangeProgressBar(
                      minValue: range[0],
                      maxValue: range[1],
                      currentValue: bmi!,
                      label: "BMI Range for $selectedGoal",
                      barColor: Colors.orange,
                    ),
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
                ),
                child: const Text(
                  "Back",
                  style: TextStyle(color: Colors.black),
                ),
              ),

              // Next button
              if (selectedGoal != null)
                ElevatedButton(
                  onPressed: () async {
                    await _saveGoal();
                    widget.onNext();
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
    );
  }
}
