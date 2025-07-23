import 'package:flutter/material.dart';
import 'food_search_screen.dart';
import '../profile/profile_screen.dart';

// Tạo class MacroData để quản lý dữ liệu
class MacroData {
  final String label;
  final double currentValue;
  final double targetValue;
  final String unit;
  final Color color;

  MacroData({
    required this.label,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.color,
  });

  String get currentString => currentValue.toStringAsFixed(0);
  String get targetString => "${targetValue.toStringAsFixed(0)}$unit";
  double get progress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
}

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _selectedBottomIndex = 0; // 0: Journal, 1: Profile
  bool _isMacroExpanded = false;

  // Dữ liệu macro chung
  List<MacroData> macroData = [
    MacroData(
      label: "Fat",
      currentValue: 20.0, // Dữ liệu ví dụ
      targetValue: 78,
      unit: "g",
      color: Color(0xFFFFC107),
    ),
    MacroData(
      label: "Protein",
      currentValue: 32.0, // Dữ liệu ví dụ
      targetValue: 246,
      unit: "g",
      color: Color(0xFF8FD5C7),
    ),
    MacroData(
      label: "Carbs",
      currentValue: 24.0, // Dữ liệu ví dụ
      targetValue: 440,
      unit: "g",
      color: Color(0xFF9C27B0),
    ),
    MacroData(
      label: "Fiber",
      currentValue: 13.0, // Dữ liệu ví dụ
      targetValue: 35,
      unit: "g",
      color: Color(0xFFFF9800),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Meal> mealList = [
      Meal(
        icon: Icons.free_breakfast,
        name: 'Breakfast',
        calories: '0 / 608 Cal',
        mealType: MealType.breakfast,
      ),
      Meal(
        icon: Icons.lunch_dining,
        name: 'Lunch',
        calories: '0 / 608 Cal',
        mealType: MealType.lunch,
      ),
      Meal(
        icon: Icons.dinner_dining,
        name: 'Dinner',
        calories: '0 / 608 Cal',
        mealType: MealType.dinner,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 193, 225, 218),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Calories Overview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Calories Eaten
                  Column(
                    children: const [
                      Text(
                        "0",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Eaten",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ],
                  ),

                  // Calories Left
                  Column(
                    children: const [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Color.fromARGB(255, 143, 178, 171),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "2025",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Cal",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "left",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Calories Burned + Fire Icon
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: const [
                          Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Burned",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const Positioned(
                        top: -65,
                        right: -10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            border: Border.fromBorderSide(
                              BorderSide(color: Color(0xFFDDDDDD), width: 1),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "0",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Macronutrients - Simple view (sử dụng dữ liệu chung)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: macroData
                    .map(
                      (macro) => _SimpleMacroItem(
                        label: macro.label,
                        currentValue: macro.currentValue,
                        targetValue: macro.targetValue,
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isMacroExpanded = !_isMacroExpanded;
                  });
                },
                child: Center( 
                  child: Icon(
                  _isMacroExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 32,
                  color: Colors.black45,
                  ),
                )
              ),

              // Detailed view (sử dụng dữ liệu chung)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isMacroExpanded ? null : 0,
                child: _isMacroExpanded
                    ? Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Macronutrients",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: macroData
                                  .map(
                                    (macro) => _MacroNutrientBar(
                                      label: macro.label,
                                      current: macro.currentString,
                                      target: macro.targetString,
                                      color: macro.color,
                                      progress: macro.progress,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // White container with rounded corners
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Today header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.calendar_today, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Today",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Meal items
                    Column(
                      children: mealList
                          .map(
                            (meal) => MealItem(
                              imageAsset: meal.icon,
                              mealName: meal.name,
                              calories: meal.calories,
                              mealType: meal.mealType,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Water Challenge section
              const WaterChallengeCard(),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        selectedItemColor: Colors.teal[800],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });

          // Điều hướng sang màn khác
          if (index == 1) {
            // Chuyển sang Profile
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
          // index == 0 là Journal (màn hình hiện tại), không cần làm gì
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// Cập nhật _SimpleMacroItem
class _SimpleMacroItem extends StatelessWidget {
  final String label;
  final double currentValue;
  final double targetValue;

  const _SimpleMacroItem({
    required this.label,
    required this.currentValue,
    required this.targetValue,
  });

  @override
  Widget build(BuildContext context) {
    double progress = targetValue > 0
        ? (currentValue / targetValue).clamp(0.0, 1.0)
        : 0.0;

    return SizedBox(
      width: 70, // Fixed width giống detailed view
      child: Column(
        children: [
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Container(
                  width: 60 * progress,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center, // Center align text
          ),
        ],
      ),
    );
  }
}

// Cập nhật _MacroNutrientBar
class _MacroNutrientBar extends StatelessWidget {
  final String label;
  final String current;
  final String target;
  final Color color;
  final double progress;

  const _MacroNutrientBar({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                // Background circle (vòng tròn nhạt)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.2), // Màu nhạt hơn
                      width: 4,
                    ),
                    color: Colors.white,
                  ),
                ),
                // Progress circle - đặt chính xác trên background
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 4, // Cùng độ dày với border
                  ),
                ),
                // Center text
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        current,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "/$target",
                        style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Meal data model
class Meal {
  final IconData icon;
  final String name;
  final String calories;
  final MealType mealType;

  Meal({
    required this.icon,
    required this.name,
    required this.calories,
    required this.mealType,
  });
}

// Meal item widget
class MealItem extends StatelessWidget {
  final IconData imageAsset;
  final String mealName;
  final String calories;
  final MealType mealType;

  const MealItem({
    super.key,
    required this.imageAsset,
    required this.mealName,
    required this.calories,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDDE0E3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 24,
                child: Icon(imageAsset, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    calories,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchFoodScreen(mealType: mealType),
                ),
              );
            },
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black87,
              child: Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class WaterChallengeCard extends StatelessWidget {
  const WaterChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Water Challenge card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Water Challenge",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(Icons.more_horiz),
                ],
              ),
              const SizedBox(height: 8),

              // Subtitles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Water",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        "Goal : 1,50 L",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  Text(
                    "0,00 L",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Water cups row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  return Container(
                    width: 36,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F6FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, size: 20, color: Colors.grey),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // Customize Button
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            side: const BorderSide(color: Colors.black87),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {},
          child: const Text(
            "Customize my diary",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
