import 'package:flutter/material.dart';
import 'Loading_Screen.dart';
import '../../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Step6IdealWeight extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step6IdealWeight({
    Key? key,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  State<Step6IdealWeight> createState() => _Step6IdealWeightState();
}

class _Step6IdealWeightState extends State<Step6IdealWeight> {
  double? bmi;
  double? minIdealWeight;
  double? maxIdealWeight;
  double? suggestedWeight;
  double? height;
  double? weight;
  String? goal;
  String? _uid;
  bool _loading = true;

  final TextEditingController _targetWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_uid == null) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      _uid = args?['userid']; // 🔹 Lấy uid từ arguments
      _loadUserDataAndCalculate();
    }
  }

  Future<void> _loadUserDataAndCalculate() async {
    setState(() => _loading = true);

    try {
      // 🔹 Ưu tiên lấy dữ liệu từ Firebase
      if (_uid != null && _uid!.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .get();

        if (doc.exists) {
          final data = doc.data() ?? {};
          height = (data['height'] != null)
              ? double.tryParse(data['height'].toString())
              : null;
          weight = (data['weight'] != null)
              ? double.tryParse(data['weight'].toString())
              : null;
          goal = data['goal'] as String?;
        }
      }

      // 🔹 Nếu Firebase không có thì fallback sang local UserService
      if (height == null) {
        final h = await UserService.getHeight();
        height = h ?? height;
      }
      if (weight == null) {
        final w = await UserService.getWeight();
        weight = w ?? weight;
      }
      if (goal == null) {
        final g = await UserService.getGoal();
        goal = g ?? goal;
      }

      // 🔹 Tính toán BMI và Ideal Weight
      if (height != null && weight != null && height! > 0 && goal != null) {
        double heightInMeters = height! / 100;
        bmi = weight! / (heightInMeters * heightInMeters);

        minIdealWeight = 18.5 * heightInMeters * heightInMeters;
        maxIdealWeight = 24.9 * heightInMeters * heightInMeters;

        switch (goal!.toLowerCase()) {
          case "weight gain":
            suggestedWeight = maxIdealWeight! - 1;
            break;
          case "weight loss":
            suggestedWeight = minIdealWeight! + 1;
            break;
          case "muscle building":
            suggestedWeight = minIdealWeight! + 2;
            break;
          default:
            suggestedWeight = (minIdealWeight! + maxIdealWeight!) / 2;
            break;
        }

        suggestedWeight = double.parse(suggestedWeight!.toStringAsFixed(1));
      }
    } catch (e) {
      print("❌ Error loading data in Step6: $e");
    }

    setState(() => _loading = false);
  }

  void _goToNext() {
    double? targetWeight = double.tryParse(_targetWeightController.text);
    if (targetWeight == null || targetWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid target weight")),
      );
      return;
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orangePrimary = Colors.orange;
    final orangeLight = Colors.orange.shade50;
    final orangeDarker = Colors.orange.shade800;
    final greenLight = Colors.green.shade50;
    final greenDark = Colors.green.shade800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideal Weight'),
        centerTitle: true,
        backgroundColor: orangeLight,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BMI Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: orangeLight,
              shadowColor: orangePrimary.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    Icon(Icons.monitor_weight, size: 48, color: orangePrimary),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your BMI",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: orangeDarker,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            bmi != null ? bmi!.toStringAsFixed(1) : "--",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: orangePrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Ideal Weight Range
            Text(
              "Ideal weight range for your height (${height != null ? height!.toInt() : '--'} cm):",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: greenLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                minIdealWeight != null && maxIdealWeight != null
                    ? "${minIdealWeight!.toStringAsFixed(1)} kg – ${maxIdealWeight!.toStringAsFixed(1)} kg"
                    : "-- kg – -- kg",
                style: theme.textTheme.titleLarge?.copyWith(
                  color: greenDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Suggested Target Weight
            Text(
              "Based on your goal (${goal ?? "--"}):",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: orangeLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.flag, color: orangePrimary),
                  const SizedBox(width: 16),
                  Text(
                    "Suggested target weight: ",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    suggestedWeight != null ? "$suggestedWeight kg" : "-- kg",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: orangeDarker,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Input target weight
            Text(
              "Enter your desired target weight:",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetWeightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: suggestedWeight != null ? "$suggestedWeight" : "",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: orangePrimary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 24,
                ),
                suffixText: "kg",
                suffixStyle: TextStyle(color: Colors.grey.shade600),
              ),
            ),

            const SizedBox(height: 56),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: widget.onPrevious,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _goToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
