import 'package:flutter/material.dart';
import 'food_search_screen.dart';
import '../profile/profile_Screen.dart';
import '../../../services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fittracker_source/Screens/initial_screen/Welcome_Screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      print('📊 Loading user data for Journal...');

      // Lấy thông tin user
      final userInfo = await UserService.getUserInfo();
      if (userInfo == null) {
        print('❌ No user data found');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Tính toán calories và macros từ UserService
      final dailyCalories = await UserService.calculateDailyCalories();
      final macroTargets = await UserService.calculateMacroTargets();

      if (dailyCalories != null && macroTargets != null) {
        setState(() {
          _targetCalories = dailyCalories.toDouble();

          // Chia calories cho các bữa ăn (30% breakfast, 40% lunch, 30% dinner)
          _targetBreakfast = _targetCalories * 0.30;
          _targetLunch = _targetCalories * 0.40;
          _targetDinner = _targetCalories * 0.30;

          // Tạo macro data từ calculated targets
          macroData = [
            MacroData(
              label: "Fat",
              currentValue: 0.0, // Sẽ được cập nhật từ food tracking
              targetValue: macroTargets['fat']!.toDouble(),
              unit: "g",
              color: Color(0xFFFFC107),
            ),
            MacroData(
              label: "Protein",
              currentValue: 0.0,
              targetValue: macroTargets['protein']!.toDouble(),
              unit: "g",
              color: Color(0xFF8FD5C7),
            ),
            MacroData(
              label: "Carbs",
              currentValue: 0.0,
              targetValue: macroTargets['carbs']!.toDouble(),
              unit: "g",
              color: Color(0xFF9C27B0),
            ),
            MacroData(
              label: "Fiber",
              currentValue: 0.0,
              targetValue: macroTargets['fiber']!.toDouble(),
              unit: "g",
              color: Color(0xFFFF9800),
            ),
          ];

          _isLoading = false;
        });

        print('✅ User data loaded successfully:');
        print('   Target Calories: ${_targetCalories.toInt()}');
        print('   Breakfast: ${_targetBreakfast.toInt()} cal');
        print('   Lunch: ${_targetLunch.toInt()} cal');
        print('   Dinner: ${_targetDinner.toInt()} cal');
        print('   Protein: ${macroTargets['protein']}g');
        print('   Fat: ${macroTargets['fat']}g');
        print('   Carbs: ${macroTargets['carbs']}g');
        print('   Fiber: ${macroTargets['fiber']}g');
      } else {
        print('❌ Failed to calculate targets');
        setState(() {
          _isLoading = false;
        });
      }
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
        calories: '0 / ${_targetBreakfast.toInt()} Cal',
        mealType: MealType.breakfast,
      ),
      Meal(
        icon: Icons.lunch_dining,
        name: 'Lunch',
        calories: '0 / ${_targetLunch.toInt()} Cal',
        mealType: MealType.lunch,
      ),
      Meal(
        icon: Icons.dinner_dining,
        name: 'Dinner',
        calories: '0 / ${_targetDinner.toInt()} Cal',
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
              // Calories Overview với dữ liệu từ UserService
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
                            Text(
                              "${_targetCalories.toInt()}",
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
              const SizedBox(height: 20),
              _buildResetFoodJourneyButton(),
              const SizedBox(height: 40), // Extra bottom padding
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

  // ✅ NEW: Reset Food Journey Button Widget - MOVED INSIDE CLASS
  Widget _buildResetFoodJourneyButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          // Divider line
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(vertical: 20),
          ),

          // Reset button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showResetConfirmationDialog,
              icon: const Icon(
                Icons.restore_rounded,
                color: Colors.white,
                size: 22,
              ),
              label: const Text(
                "Complete Journey Reset",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 3,
                shadowColor: Colors.red.withOpacity(0.3),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Description text
          Text(
            "Clear all data and restart your fitness journey",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Show confirmation dialog before reset - MOVED INSIDE CLASS
  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                "Complete Reset",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "This will COMPLETELY RESET your entire fitness journey!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "This will:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                "• Delete ALL your profile data",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                "• Clear all weight history",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                "• Reset all food entries",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                "• Return to initial setup",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 12),
              Text(
                "You will need to set up your profile again from scratch.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performFoodJourneyReset();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Complete Reset",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ NEW: Perform the actual reset - MOVED INSIDE CLASS
  void _performFoodJourneyReset() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(
                  color: Color.fromARGB(255, 143, 178, 171),
                ),
                SizedBox(height: 16),
                Text(
                  "Resetting your entire journey...",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );

      // ✅ COMPLETE RESET: Clear ALL UserService data
      await UserService.clearAllUserData();

      // ✅ Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // ✅ Reset all local state
      setState(() {
        _targetCalories = 0.0;
        _targetBreakfast = 0.0;
        _targetLunch = 0.0;
        _targetDinner = 0.0;
        macroData.clear();
        _isLoading = false;
      });

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // ✅ Show success message then navigate to setup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.refresh, color: Colors.white),
              SizedBox(width: 12),
              Text(
                "Journey reset! Redirecting to setup...",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // ✅ Wait then navigate to first setup screen
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }

      print('✅ Complete journey reset and redirect to setup');
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('❌ Error resetting complete journey: $e');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text(
                "Failed to reset journey. Please try again.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  Meal({
    required this.icon,
    required this.name,
    required this.calories,
    required this.mealType,
  });
}

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
