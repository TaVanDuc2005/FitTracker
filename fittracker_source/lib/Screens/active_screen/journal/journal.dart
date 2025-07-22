import 'package:flutter/material.dart';
import 'food_search_screen.dart';
import '../profile/profile.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _selectedBottomIndex = 0; // 0: Journal, 1: Profile
  bool _isMacroExpanded = false; // Thêm biến này

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
      backgroundColor: const Color(0xFFE6EAF3),
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
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),

                  // Calories Left
                  Column(
                    children: const [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFFDDE3EC),
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
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Burned",
                            style: TextStyle(
                              fontSize: 16,
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

              // Macronutrients
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _SimpleMacroItem(label: "Fat"),
                  _SimpleMacroItem(label: "Protein"),
                  _SimpleMacroItem(label: "Carbs"),
                  _SimpleMacroItem(label: "Fiber"),
                ],
              ),

              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isMacroExpanded = !_isMacroExpanded;
                  });
                },
                child: Icon(
                  _isMacroExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 32,
                  color: Colors.black45,
                ),
              ),

              // Thêm phần này ngay sau icon:
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
                              children: const [
                                _MacroNutrientBar(
                                  label: "Fat",
                                  current: "0",
                                  target: "78g",
                                  color: Color(0xFFFFC107),
                                ),
                                _MacroNutrientBar(
                                  label: "Protein",
                                  current: "0",
                                  target: "246g",
                                  color: Color(0xFF8FD5C7),
                                ),
                                _MacroNutrientBar(
                                  label: "Carbs",
                                  current: "0",
                                  target: "440g",
                                  color: Color(0xFF9C27B0),
                                ),
                                _MacroNutrientBar(
                                  label: "Fiber",
                                  current: "0",
                                  target: "35g",
                                  color: Color(0xFFFF9800),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

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

// Thêm class mới cho simple macro view
class _SimpleMacroItem extends StatelessWidget {
  final String label;

  const _SimpleMacroItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Macro nutrient bar
class _MacroNutrientBar extends StatelessWidget {
  final String label;
  final String current;
  final String target;
  final Color color;

  const _MacroNutrientBar({
    required this.label,
    this.current = "0",
    this.target = "0g",
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circle với border màu
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 4),
            color: Colors.white,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  current,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "/$target",
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
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
        ),
      ],
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
