import 'package:flutter/material.dart';
import 'food_search_screen.dart';
import '../profile/profile_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fittracker_source/Screens/initial_screen/AI_agent_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fittracker_source/models/food.dart';

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
  int _selectedBottomIndex = 0;
  bool _isMacroExpanded = false;

  // State variables từ user data
  double _targetCalories = 0.0;
  double _targetBreakfast = 0.0;
  double _targetLunch = 0.0;
  double _targetDinner = 0.0;
  List<MacroData> macroData = [];
  bool _isLoading = true;

  Map<MealType, List<String>> mealFoodNames = {
    MealType.breakfast: [],
    MealType.lunch: [],
    MealType.dinner: [],
  };

  // Thêm biến này để lưu calories đã ăn cho từng bữa
  Map<MealType, int> mealCaloriesEaten = {
    MealType.breakfast: 0,
    MealType.lunch: 0,
    MealType.dinner: 0,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      print('📊 Loading user data for Journal...');

      // Lấy uid từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userid');
      if (uid == null || uid.isEmpty) {
        print('❌ No UID found');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Tải dữ liệu user từ Firebase
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!doc.exists) {
        print('❌ No user data found on Firebase');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final userInfo = doc.data();

      // TÍNH TOÁN TRỰC TIẾP TỪ DỮ LIỆU FIREBASE
      double? height = (userInfo?['height'] as num?)?.toDouble();
      double? weight = (userInfo?['weight'] as num?)?.toDouble();
      int? age = (userInfo?['age'] as num?)?.toInt();
      String? gender = userInfo?['gender']?.toString().toLowerCase();
      String? lifestyle = userInfo?['lifestyle']?.toString().toLowerCase();

      // Tính BMR
      double bmr = 0;
      if (height != null && weight != null && age != null && gender != null) {
        if (gender == 'male') {
          bmr = 10 * weight + 6.25 * height - 5 * age + 5;
        } else {
          bmr = 10 * weight + 6.25 * height - 5 * age - 161;
        }
      }

      // Tính hệ số hoạt động
      double activityFactor = 1.2;
      switch (lifestyle) {
        case 'student':
        case 'not employed':
        case 'retired':
          activityFactor = 1.2;
          break;
        case 'employed part-time':
          activityFactor = 1.375;
          break;
        case 'employed full-time':
          activityFactor = 1.55;
          break;
        default:
          activityFactor = 1.2;
      }

      // Tính calories
      double dailyCalories = bmr * activityFactor;

      // Tính macro targets
      Map<String, double> macroTargets = {
        'protein': dailyCalories * 0.15 / 4,
        'fat': dailyCalories * 0.25 / 9,
        'carbs': dailyCalories * 0.60 / 4,
        'fiber': 25,
      };

      // Lấy tên món ăn từng bữa từ Firebase
      final meals = userInfo?['meals'] as Map<String, dynamic>? ?? {};
      final foodSnapshot = await FirebaseFirestore.instance
          .collection('list_food')
          .get();
      final allFoods = foodSnapshot.docs
          .map((doc) => Food.fromMap(doc.data()))
          .toList();

      mealFoodNames = {
        MealType.breakfast: [],
        MealType.lunch: [],
        MealType.dinner: [],
      };

      for (final mealKey in ['breakfast', 'lunch', 'dinner']) {
        final mealFoods = meals[mealKey] as Map<String, dynamic>? ?? {};
        final names = <String>[];
        mealFoods.forEach((foodId, qty) {
          final found = allFoods.where((f) => f.id == foodId);
          if (found.isNotEmpty) {
            names.add("${found.first.name} x$qty");
          }
        });
        switch (mealKey) {
          case 'breakfast':
            mealFoodNames[MealType.breakfast] = names;
            break;
          case 'lunch':
            mealFoodNames[MealType.lunch] = names;
            break;
          case 'dinner':
            mealFoodNames[MealType.dinner] = names;
            break;
        }
      }

      Map<MealType, int> mealCaloriesEaten = {
        MealType.breakfast: 0,
        MealType.lunch: 0,
        MealType.dinner: 0,
      };

      for (final mealKey in ['breakfast', 'lunch', 'dinner']) {
        final mealFoods = meals[mealKey] as Map<String, dynamic>? ?? {};
        int totalCal = 0;
        mealFoods.forEach((foodId, qty) {
          final found = allFoods.where((f) => f.id == foodId);
          if (found.isNotEmpty) {
            totalCal += (found.first.calories ?? 0) * (qty as int);
          }
        });
        switch (mealKey) {
          case 'breakfast':
            mealCaloriesEaten[MealType.breakfast] = totalCal;
            break;
          case 'lunch':
            mealCaloriesEaten[MealType.lunch] = totalCal;
            break;
          case 'dinner':
            mealCaloriesEaten[MealType.dinner] = totalCal;
            break;
        }
      }

      // Tính tổng macro đã ăn
      double totalFat = 0.0;
      double totalProtein = 0.0;
      double totalCarbs = 0.0;
      double totalFiber = 0.0;

      for (final mealKey in ['breakfast', 'lunch', 'dinner']) {
        final mealFoods = meals[mealKey] as Map<String, dynamic>? ?? {};
        mealFoods.forEach((foodId, qty) {
          final found = allFoods.where((f) => f.id == foodId);
          if (found.isNotEmpty) {
            final food = found.first;
            final quantity = qty as int;
            totalFat += (food.fat ?? 0) * quantity;
            totalProtein += (food.protein ?? 0) * quantity;
            totalCarbs += (food.carb ?? 0) * quantity;
            totalFiber += (food.fiber ?? 0) * quantity;
          }
        });
      }

      setState(() {
        _targetCalories = dailyCalories;
        _targetBreakfast = _targetCalories * 0.30;
        _targetLunch = _targetCalories * 0.40;
        _targetDinner = _targetCalories * 0.30;

        macroData = [
          MacroData(
            label: "Fat",
            currentValue: totalFat,
            targetValue: macroTargets['fat'] ?? 0,
            unit: "g",
            color: Color(0xFFFFC107),
          ),
          MacroData(
            label: "Protein",
            currentValue: totalProtein,
            targetValue: macroTargets['protein'] ?? 0,
            unit: "g",
            color: Color(0xFF8FD5C7),
          ),
          MacroData(
            label: "Carbs",
            currentValue: totalCarbs,
            targetValue: macroTargets['carbs'] ?? 0,
            unit: "g",
            color: Color(0xFF9C27B0),
          ),
          MacroData(
            label: "Fiber",
            currentValue: totalFiber,
            targetValue: macroTargets['fiber'] ?? 0,
            unit: "g",
            color: Color(0xFFFF9800),
          ),
        ];

        this.mealCaloriesEaten = mealCaloriesEaten; // Đúng!
        _isLoading = false;
      });

      print('✅ User data loaded from Firebase and calculated:');
      print('   Target Calories: ${_targetCalories.toInt()}');
      print('   Breakfast: ${_targetBreakfast.toInt()} cal');
      print('   Lunch: ${_targetLunch.toInt()} cal');
      print('   Dinner: ${_targetDinner.toInt()} cal');
      print('   Protein: ${macroTargets['protein']?.toStringAsFixed(0)}g');
      print('   Fat: ${macroTargets['fat']?.toStringAsFixed(0)}g');
      print('   Carbs: ${macroTargets['carbs']?.toStringAsFixed(0)}g');
      print('   Fiber: ${macroTargets['fiber']?.toStringAsFixed(0)}g');
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen nếu đang load data
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 193, 225, 218),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                color: Color.fromARGB(255, 143, 178, 171),
              ),
              SizedBox(height: 16),
              Text(
                'Loading your profile...',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    // Show error nếu không có data
    if (_targetCalories == 0.0 || macroData.isEmpty) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 193, 225, 218),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              SizedBox(height: 16),
              Text(
                'Unable to load your profile data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please complete your profile setup',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _loadUserData(); // Retry loading
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 143, 178, 171),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final List<Meal> mealList = [
      Meal(
        icon: Icons.free_breakfast,
        name: 'Breakfast',
        calories:
            '${mealCaloriesEaten[MealType.breakfast] ?? 0} / ${_targetBreakfast.toInt()} Cal',
        mealType: MealType.breakfast,
        foodNames: mealFoodNames[MealType.breakfast] ?? [],
      ),
      Meal(
        icon: Icons.lunch_dining,
        name: 'Lunch',
        calories:
            '${mealCaloriesEaten[MealType.lunch] ?? 0} / ${_targetLunch.toInt()} Cal',
        mealType: MealType.lunch,
        foodNames: mealFoodNames[MealType.lunch] ?? [],
      ),
      Meal(
        icon: Icons.dinner_dining,
        name: 'Dinner',
        calories:
            '${mealCaloriesEaten[MealType.dinner] ?? 0} / ${_targetDinner.toInt()} Cal',
        mealType: MealType.dinner,
        foodNames: mealFoodNames[MealType.dinner] ?? [],
      ),
    ];

    // TÍNH TỔNG CALORIES ĐÃ ĂN
    final int totalCaloriesEaten = mealCaloriesEaten.values.fold(
      0,
      (a, b) => a + b,
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 193, 225, 218),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thêm nút AI Agent ở đầu màn hình
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.black87,
                  ),
                  tooltip: 'Open AI Agent',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIAgentScreen(),
                      ),
                    );
                  },
                ),
              ),
              // Calories Overview với dữ liệu từ UserService
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Calories Eaten
                  Column(
                    children: [
                      Text(
                        "$totalCaloriesEaten",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Eaten",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  // Calories Left với target từ UserService
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Color.fromARGB(255, 143, 178, 171),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Builder(
                              builder: (context) {
                                final calLeft =
                                    (_targetCalories - totalCaloriesEaten)
                                        .toInt();
                                if (calLeft >= 0) {
                                  return Column(
                                    children: [
                                      Text(
                                        "$calLeft",
                                        style: const TextStyle(
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
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      Text(
                                        "${calLeft.abs()}",
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      Text(
                                        "Cal",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      Text(
                                        "In Excess",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
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
                        top: -40,
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

              // Macronutrients với dữ liệu từ UserService
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
                ),
              ),

              // Detailed view với dữ liệu từ UserService
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

              // White container với meal calories từ UserService
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

                    // Meal items với calories từ UserService
                    Column(
                      children: mealList
                          .map(
                            (meal) => MealItem(
                              imageAsset: meal.icon,
                              mealName: meal.name,
                              calories: meal.calories,
                              mealType: meal.mealType,
                              foodNames: meal.foodNames,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Water Challenge section
              const WaterChallengeCard(),

              // ✅ NEW: Reset Food Journey Button
              const SizedBox(height: 40),
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

          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// Rest of the classes remain the same...
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
      width: 70,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

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
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.2), width: 4),
                    color: Colors.white,
                  ),
                ),
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 4,
                  ),
                ),
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
                        style: TextStyle(
                          fontSize: 9,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w500,
                        ),
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

class Meal {
  final IconData icon;
  final String name;
  final String calories;
  final MealType mealType;
  final List<String> foodNames;

  Meal({
    required this.icon,
    required this.name,
    required this.calories,
    required this.mealType,
    required this.foodNames,
  });
}

class MealItem extends StatelessWidget {
  final IconData imageAsset;
  final String mealName;
  final String calories;
  final MealType mealType;
  final List<String> foodNames;

  const MealItem({
    super.key,
    required this.imageAsset,
    required this.mealName,
    required this.calories,
    required this.mealType,
    required this.foodNames,
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
                  if (foodNames.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: foodNames
                          .map(
                            (name) => Text(
                              name,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.teal,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchFoodScreen(mealType: mealType),
                ),
              );
              // Sau khi trở về từ SearchFoodScreen, cập nhật lại dữ liệu
              if (result != null) {
                // Gọi lại hàm load dữ liệu
                if (context.mounted) {
                  final state = context
                      .findAncestorStateOfType<_JournalScreenState>();
                  state?._loadUserData();
                }
              } else {
                // Nếu không trả về gì vẫn reload để đảm bảo dữ liệu mới nhất
                if (context.mounted) {
                  final state = context
                      .findAncestorStateOfType<_JournalScreenState>();
                  state?._loadUserData();
                }
              }
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

void _showWaterCupSelector(
  BuildContext context,
  int selectedCups,
  Function(int) onSelected,
) {
  showDialog(
    context: context,
    builder: (ctx) {
      int tempCups = selectedCups;
      double cupVolume = 0.21;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select number of cups'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$tempCups cups = ${(tempCups * cupVolume).toStringAsFixed(2)} L',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Slider(
                  value: tempCups.toDouble(),
                  min: 4,
                  max: 12,
                  divisions: 8,
                  label: '$tempCups',
                  onChanged: (value) {
                    setState(() {
                      tempCups = value.round();
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onSelected(tempCups);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}

// Sử dụng trong WaterChallengeCard
class WaterChallengeCard extends StatefulWidget {
  const WaterChallengeCard({super.key});

  @override
  State<WaterChallengeCard> createState() => _WaterChallengeCardState();
}

class _WaterChallengeCardState extends State<WaterChallengeCard> {
  double goalLit = 3.0;
  int get totalCups => (goalLit / cupVolume).ceil();
  int cupsDrank = 0;
  double cupVolume = 0.21;
  double get goalWater => totalCups * cupVolume;

  List<double> fillPercents = [];

  void _showGoalLitSelector(BuildContext context) {
    if (goalLit > 3.0) {
      setState(() {
        goalLit = 3.0;
      });
    }
    showModalBottomSheet(
      context: context,
      builder: (_) {
        double tempGoal = goalLit;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: tempGoal,
                  min: 1.0,
                  max: 3.0,
                  divisions: 20,
                  label: "${tempGoal.toStringAsFixed(2)} L",
                  onChanged: (value) {
                    setModalState(() => tempGoal = value);
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      goalLit = tempGoal;
                      fillPercents = List.filled(totalCups, 0.0);
                      if (cupsDrank > totalCups) cupsDrank = totalCups;
                    });
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fillPercents = List.filled(totalCups, 0.0);
  }

  void _fillCup(int index, bool isFilled) async {
    if (isFilled) {
      // Hiệu ứng nước rút từ từ cho các cốc từ index đến cuối
      for (double p = 1.0; p >= 0.0; p -= 0.05) {
        await Future.delayed(const Duration(milliseconds: 20));
        setState(() {
          for (int i = index; i < totalCups; i++) {
            fillPercents[i] = p;
          }
        });
      }
      setState(() {
        cupsDrank = index;
        for (int i = index; i < totalCups; i++) {
          fillPercents[i] = 0.0;
        }
      });
    } else {
      setState(() {
        cupsDrank = index + 1;
        for (int i = 0; i <= index; i++) {
          fillPercents[i] = 0.0;
        }
      });
      // Tất cả các cốc từ 0 đến index cùng lên nước đồng thời
      for (double p = 0.0; p <= 1.0; p += 0.05) {
        await Future.delayed(const Duration(milliseconds: 20));
        setState(() {
          for (int i = 0; i <= index; i++) {
            fillPercents[i] = p;
          }
        });
      }
      setState(() {
        for (int i = 0; i <= index; i++) {
          fillPercents[i] = 1.0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (fillPercents.length != totalCups) {
      List<double> newPercents = List.filled(totalCups, 0.0);
      for (int i = 0; i < cupsDrank && i < totalCups; i++) {
        newPercents[i] = 1.0;
      }
      fillPercents = newPercents;
      if (cupsDrank > totalCups) cupsDrank = totalCups;
    }

    double waterDrank = cupsDrank * cupVolume;

    return Column(
      children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Water Challenge",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showGoalLitSelector(context),
                    child: const Icon(Icons.more_horiz),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Water",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        "Goal : ${goalWater.toStringAsFixed(2)} L",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${waterDrank.toStringAsFixed(2)} / ${goalWater.toStringAsFixed(2)} L",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: List.generate(totalCups, (index) {
                  bool isFilled = index < cupsDrank;
                  return GestureDetector(
                    onTap: () {
                      _fillCup(index, isFilled);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isFilled
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          GlassCupWidget(
                            isFilled: isFilled,
                            fillPercent: fillPercents[index],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GlassCupWidget extends StatelessWidget {
  final bool isFilled;
  final double fillPercent;

  const GlassCupWidget({
    super.key,
    required this.isFilled,
    this.fillPercent = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 48,
      child: CustomPaint(
        painter: _GlassCupPainter(isFilled: isFilled, fillPercent: fillPercent),
      ),
    );
  }
}

class _GlassCupPainter extends CustomPainter {
  final bool isFilled;
  final double fillPercent;

  _GlassCupPainter({required this.isFilled, required this.fillPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final paintCup = Paint()
      ..color = const Color.fromARGB(255, 214, 220, 223)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Vẽ outline cốc
    Path cupPath = Path();
    cupPath.moveTo(size.width * 0.1, 0);
    cupPath.lineTo(size.width * 0.25, size.height * 0.85);
    cupPath.lineTo(size.width * 0.75, size.height * 0.85);
    cupPath.lineTo(size.width * 0.9, 0);
    cupPath.close();
    canvas.drawPath(cupPath, paintCup);

    if (isFilled && fillPercent > 0) {
      double waterHeight = size.height * 0.85 * fillPercent;
      double waterBottom = size.height * 0.85;
      double waterTop = waterBottom - waterHeight;

      // Tính điểm trái/phải theo fillPercent (điểm nằm trên cạnh cốc)
      double leftStartX = size.width * 0.25;
      double rightStartX = size.width * 0.75;
      // Tính lại: điểm miệng nước nằm trên cạnh cốc (từ đáy lên miệng)
      double leftTopX =
          size.width * 0.25 +
          (size.width * 0.1 - size.width * 0.25) *
              ((waterBottom - waterTop) / (waterBottom));
      double rightTopX =
          size.width * 0.75 +
          (size.width * 0.9 - size.width * 0.75) *
              ((waterBottom - waterTop) / (waterBottom));

      Path waterPath = Path();
      waterPath.moveTo(leftStartX, waterBottom); // Đáy trái
      waterPath.lineTo(leftTopX, waterTop); // Miệng trái
      waterPath.lineTo(rightTopX, waterTop); // Miệng phải
      waterPath.lineTo(rightStartX, waterBottom); // Đáy phải
      waterPath.close();

      final paintWater = Paint()
        ..color = const Color.fromARGB(255, 120, 241, 241)!.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawPath(waterPath, paintWater);
    } else {
      // Vẽ nước màu xám phủ kín ly khi chưa đầy
      final paintGray = Paint()
        ..color = const Color.fromARGB(255, 233, 231, 231)!.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawPath(cupPath, paintGray);

      // Vẽ dấu cộng ở giữa cốc
      final double centerX = size.width / 2;
      final double centerY = size.height * 0.5;
      final paintPlus = Paint()
        ..color = const Color.fromARGB(255, 161, 161, 161)!
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(centerX - 6, centerY),
        Offset(centerX + 6, centerY),
        paintPlus,
      );
      canvas.drawLine(
        Offset(centerX, centerY - 6),
        Offset(centerX, centerY + 6),
        paintPlus,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
