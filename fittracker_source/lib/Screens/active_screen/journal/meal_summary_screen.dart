import 'package:flutter/material.dart';
import 'package:fittracker_source/models/food.dart';
import 'package:fittracker_source/Screens/active_screen/journal/journal_screen.dart';

class MealSummaryScreen extends StatefulWidget {
  final String mealName;
  final int targetCalories;
  final int targetProtein;
  final int targetFat;
  final int targetCarbs;
  final int targetFiber;
  final List<Food> foods;
  final VoidCallback? onAddMore;
  final VoidCallback? onExit;

  const MealSummaryScreen({
    super.key,
    required this.mealName,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetFat,
    required this.targetCarbs,
    required this.targetFiber,
    required this.foods,
    this.onAddMore,
    this.onExit,
  });

  @override
  State<MealSummaryScreen> createState() => _MealSummaryScreenState();
}

class _MealSummaryScreenState extends State<MealSummaryScreen> {
  late List<Food> foods;

  @override
  void initState() {
    super.initState();
    foods = List.from(widget.foods);
  }

  int get totalCalories => foods.fold(0, (sum, food) => sum + (food.calories));
  int get totalProtein => (totalCalories * 0.15 ~/ 4);
  int get totalFat => (totalCalories * 0.25 ~/ 9);
  int get totalCarbs => (totalCalories * 0.55 ~/ 4);
  int get totalFiber => (foods.length * 2);

  void removeFood(int index) {
    setState(() {
      foods.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Add more food
                  GestureDetector(
                    onTap:
                        widget.onAddMore ??
                        () {
                          Navigator.of(context).pop();
                        },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22313F),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Add more food",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Close (X)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => JournalScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Meal title + calories
            Text(
              widget.mealName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF22313F),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${totalCalories} / ${widget.targetCalories} Cal",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
              child: LinearProgressIndicator(
                value: widget.targetCalories == 0
                    ? 0
                    : (totalCalories / widget.targetCalories).clamp(0.0, 1.0),
                color: const Color(0xFF8FD5C7),
                backgroundColor: const Color(0xFFE6ECEA),
                minHeight: 7,
              ),
            ),
            // Macro row
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _macroCircle(
                    "Protein",
                    totalProtein,
                    widget.targetProtein,
                    Colors.redAccent,
                  ),
                  _macroCircle("Fat", totalFat, widget.targetFat, Colors.amber),
                  _macroCircle(
                    "Carbs",
                    totalCarbs,
                    widget.targetCarbs,
                    Colors.blueAccent,
                  ),
                  _macroCircle(
                    "Fiber",
                    totalFiber,
                    widget.targetFiber,
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Hiển thị danh sách món ăn hoặc empty
            Expanded(
              child: foods.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "There is nothing here yet! Try to add some food",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Image.asset(
                          'Assets/Images/imagePageSearch_2.png',
                          width: 180,
                          height: 180,
                        ),
                      ],
                    )
                  : ListView.separated(
                      itemCount: foods.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: food.imageUrl.isNotEmpty
                                ? Image.network(
                                    food.imageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 48,
                                    height: 48,
                                    color: Colors.grey[200],
                                  ),
                          ),
                          title: Text(
                            food.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${food.calories} Cal • ${food.description}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => removeFood(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroCircle(String label, int value, int target, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(
                value: target == 0 ? 0 : (value / target).clamp(0.0, 1.0),
                color: color,
                backgroundColor: color.withOpacity(0.13),
                strokeWidth: 5,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$value",
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "/$target${label == "Fat" ? "g" : "g"}",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
