import 'package:flutter/material.dart';
import 'package:fittracker_source/models/food.dart';
import 'package:fittracker_source/Screens/active_screen/journal/Journal_Screen.dart';

class MealSummaryScreen extends StatefulWidget {
  final String mealName;
  final int targetCalories;
  final int targetProtein;
  final int targetFat;
  final int targetCarbs;
  final int targetFiber;
  final Map<Food, int> foodsWithQuantity;
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
    required this.foodsWithQuantity,
    this.onAddMore,
    this.onExit,
  });

  @override
  State<MealSummaryScreen> createState() => _MealSummaryScreenState();
}

class _MealSummaryScreenState extends State<MealSummaryScreen> {
  late Map<Food, int> foodsWithQuantity;

  @override
  void initState() {
    super.initState();
    foodsWithQuantity = Map.from(widget.foodsWithQuantity);
  }

  int get totalCalories => foodsWithQuantity.entries
      .map((e) => e.key.calories * e.value)
      .fold(0, (a, b) => a + b);

  int get totalProtein => (totalCalories * 0.15 ~/ 4);
  int get totalFat => (totalCalories * 0.25 ~/ 9);
  int get totalCarbs => (totalCalories * 0.55 ~/ 4);
  int get totalFiber => foodsWithQuantity.entries
    .map((e) => (e.key.fiber * e.value).toInt())
    .fold<int>(0, (a, b) => a + b);

  void increaseQuantity(Food food) {
    setState(() {
      foodsWithQuantity[food] = (foodsWithQuantity[food] ?? 0) + 1;
    });
  }

  void decreaseQuantity(Food food) {
    setState(() {
      final current = foodsWithQuantity[food] ?? 0;
      if (current > 1) {
        foodsWithQuantity[food] = current - 1;
      } else {
        foodsWithQuantity.remove(food);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = foodsWithQuantity.isEmpty;

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
                  GestureDetector(
                    onTap: widget.onAddMore ?? () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22313F),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 22),
                          SizedBox(width: 6),
                          Text("Add more food",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
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
            Text(widget.mealName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF22313F))),
            const SizedBox(height: 6),
            Text("${totalCalories} / ${widget.targetCalories} Cal",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black54)),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _macroCircle("Protein", totalProtein, widget.targetProtein, Colors.redAccent),
                  _macroCircle("Fat", totalFat, widget.targetFat, Colors.amber),
                  _macroCircle("Carbs", totalCarbs, widget.targetCarbs, Colors.blueAccent),
                  _macroCircle("Fiber", totalFiber, widget.targetFiber, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Text("There is nothing here yet! Try to add some food",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black45),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        Image.asset('Assets/Images/imagePageSearch_2.png', width: 180, height: 180),
                      ],
                    )
                  : ListView.separated(
                      itemCount: foodsWithQuantity.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = foodsWithQuantity.entries.elementAt(index);
                        final food = entry.key;
                        final quantity = entry.value;

                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: food.imageUrl.isNotEmpty
                                ? Image.network(food.imageUrl, width: 48, height: 48, fit: BoxFit.cover)
                                : Container(width: 48, height: 48, color: Colors.grey[200]),
                          ),
                          title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${food.calories} Cal × $quantity • ${food.description}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () => decreaseQuantity(food),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF8FD5C7)),
                                onPressed: () => increaseQuantity(food),
                              ),
                            ],
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
              children: [
                Text("$value", style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
                Text("/$target g", style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
