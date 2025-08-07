import 'package:flutter/material.dart';
import 'Loading_Screen.dart'; // đảm bảo path đúng

class RecommendScreen extends StatefulWidget {
  final double height; // cm
  final double weight; // kg
  final String goal; // "Gain Weight", "Lose Weight", "Maintain Weight"

  const RecommendScreen({
    super.key,
    required this.height,
    required this.weight,
    required this.goal,
  });

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  late double bmi;
  late double minIdealWeight;
  late double maxIdealWeight;
  late double suggestedWeight;
  final TextEditingController _targetWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calculateRecommendation();
  }

  void _calculateRecommendation() {
    double heightInMeters = widget.height / 100;
    bmi = widget.weight / (heightInMeters * heightInMeters);

    minIdealWeight = 18.5 * heightInMeters * heightInMeters;
    maxIdealWeight = 24.9 * heightInMeters * heightInMeters;

    // Đề xuất cân nặng dựa theo mục tiêu
    switch (widget.goal.toLowerCase()) {
      case "weight gain":
        suggestedWeight = maxIdealWeight - 1;
        break;
      case "weight loss":
        suggestedWeight = minIdealWeight + 1;
        break;
      case "muscle building":
        suggestedWeight = minIdealWeight + 2;
        break;
      default: // maintain
        suggestedWeight = (minIdealWeight + maxIdealWeight) / 2;
        break;
    }

    // Làm tròn đến 1 chữ số
    suggestedWeight = double.parse(suggestedWeight.toStringAsFixed(1));
  }

  void _goToLoadingScreen() {
    double? targetWeight = double.tryParse(_targetWeightController.text);
    if (targetWeight == null || targetWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid target weight")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendation'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your BMI: ${bmi.toStringAsFixed(1)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "Ideal weight range for your height (${widget.height.toInt()} cm):",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "${minIdealWeight.toStringAsFixed(1)} kg – ${maxIdealWeight.toStringAsFixed(1)} kg",
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 24),
            Text(
              "Based on your goal (${widget.goal}):",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Suggested target weight: $suggestedWeight kg",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const Text(
              "Enter your desired target weight:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _targetWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "$suggestedWeight",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _goToLoadingScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
