import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fittracker_source/Screens/active_screen/journal/journal_screen.dart';
import '../../../services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fittracker_source/Screens/active_screen/profile/Setting_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ====== Hàm sinh ngày "chuẩn lịch" ======
List<String> generateDateLabels(int days) {
  DateTime now = DateTime.now();
  return List.generate(days, (i) {
    DateTime date = now.subtract(Duration(days: days - 1 - i));
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    return "$day/$month";
  });
}

// ========== PROFILE SCREEN ==========
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0; // Weight | Nutrition
  int _selectedBottomIndex = 1; // Journal | Profile (Profile là mặc định)
  int _selectedDayRange = 0; // 0: 7 ngày, 1: 30 ngày, 2: 90 ngày

  //Thông tin từ UserService
  String userName = "";
  String goal = "";
  int caloriesPerDay = 0;
  double startWeight = 0.0;
  double currentWeight = 0.0;
  double goalWeight = 0.0;
  double? currentBMI; // Thêm BMI
  Map<String, dynamic>? userInfo;
  bool _isLoading = true;
  DateTime? accountCreatedDate;

  File? _avatarFile;

  Map<String, double> weightHistoryMap = {};

  //Dữ liệu history từ UserService - giữ nguyên format cũ
  List<double> weightHistory7 = [];
  List<double> weightHistory30 = [];
  List<double> weightHistory90 = [];

  List<double> calHistory7 = [];
  List<double> calHistory30 = [];
  List<double> calHistory90 = [];

  // ====== Lịch sử ngày dùng biến late, cập nhật realtime ======
  late List<String> weightDates7;
  late List<String> weightDates30;
  late List<String> weightDates90;

  @override
  void initState() {
    super.initState();
    weightDates7 = generateDateLabels(7);
    weightDates30 = generateDateLabels(30);
    weightDates90 = generateDateLabels(90);
    _loadUserData();
  }

  // Load dữ liệu từ Firebase thay vì UserService
  Future<void> _loadUserData() async {
    try {
      print('📊 Loading user data for Profile...');

      // Lấy uid từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userid');
      if (uid == null || uid.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Lấy dữ liệu user từ Firebase
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      userInfo = doc.data();
      if (userInfo == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Thêm đoạn này ngay sau khi lấy userInfo
      if (userInfo!['registeredAt'] != null) {
        final ts = userInfo!['registeredAt'];
        if (ts is Timestamp) {
          accountCreatedDate = ts.toDate();
        } else if (ts is String) {
          accountCreatedDate = DateTime.tryParse(ts);
        }
      }

      // Tính toán calories và BMI từ dữ liệu Firebase
      double? height = (userInfo!['height'] as num?)?.toDouble();
      double? weight = (userInfo!['weight'] as num?)?.toDouble();
      int? age = (userInfo!['age'] as num?)?.toInt();
      String? gender = userInfo!['gender']?.toString().toLowerCase();

      double bmi = 0;
      if (height != null && weight != null && height > 0) {
        bmi = weight / ((height / 100) * (height / 100));
      }

      double dailyCalories = 2000;
      if (height != null && weight != null && age != null && gender != null) {
        double bmr;
        if (gender == 'male') {
          bmr = 10 * weight + 6.25 * height - 5 * age + 5;
        } else {
          bmr = 10 * weight + 6.25 * height - 5 * age - 161;
        }
        String? lifestyle = userInfo!['lifestyle']?.toString().toLowerCase();
        double activityFactor;
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
        dailyCalories = bmr * activityFactor;
      }

      setState(() {
        // Basic info từ Firebase
        userName = userInfo!['name'] ?? 'User';
        goal = _getGoalText(
          userInfo!['healthGoal'] ?? userInfo!['goal'] ?? 'maintain weight',
        );
        caloriesPerDay = dailyCalories.toInt();
        currentBMI = bmi;

        // Weight info - lấy từ Firebase
        double weightInKg = weight ?? 70.0;
        startWeight = _kgToLbs(weightInKg); // startWeight là weight từ Firebase
        currentWeight = startWeight; // currentWeight ban đầu = startWeight

        // Goal weight là targetWeight từ Firebase
        double? targetWeightKg = (userInfo!['targetWeight'] as num?)
            ?.toDouble();
        goalWeight = targetWeightKg != null
            ? _kgToLbs(targetWeightKg)
            : startWeight;

        _generateHistoryData();
        _isLoading = false;
      });

      print('✅ Profile data loaded from Firebase:');
      print('   Name: $userName');
      print('   Goal: $goal');
      print('   Calories: $caloriesPerDay');
      print('   BMI: ${currentBMI?.toStringAsFixed(1) ?? 'N/A'}');
      print('   Current Weight: ${currentWeight.toStringAsFixed(1)} lbs');
      print('   Start Weight: ${startWeight.toStringAsFixed(1)} lbs');
      print('   Goal Weight: ${goalWeight.toStringAsFixed(1)} lbs');
    } catch (e) {
      print('❌ Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Thêm method để get BMI category
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  // Convert kg to lbs
  double _kgToLbs(double kg) {
    return kg * 2.20462;
  }

  // Convert lbs to kg
  double _lbsToKg(double lbs) {
    return lbs / 2.20462;
  }

  // Get goal text in English
  String _getGoalText(String goal) {
    switch (goal.toLowerCase()) {
      case 'weight loss':
        return 'Weight Loss';
      case 'weight gain':
        return 'Weight Gain';
      case 'muscle building':
        return 'Muscle Building';
      case 'maintain weight':
        return 'Maintain Weight';
      default:
        return 'Maintain Weight';
    }
  }

  // Calculate goal weight based on current goal
  double _calculateGoalWeight(double current, String goal) {
    switch (goal.toLowerCase()) {
      case 'lose weight':
        return current - 10; // Target to lose 10 lbs
      case 'gain weight':
        return current + 10; // Target to gain 10 lbs
      case 'maintain weight':
      case 'maintain':
      default:
        return current; // Maintain current weight
    }
  }

  // Generate history data based on UserService info
  // Generate history data based on UserService info - COMPLETE VERSION
  void _generateHistoryData() async {
    String userGoal = userInfo!['goal'] ?? 'maintain weight';
    final prefs = await SharedPreferences.getInstance();

    // Load weight history map from SharedPreferences
    String? savedJson = prefs.getString('weight_history_map_json');
    if (savedJson != null) {
      try {
        Map<String, dynamic> tempMap = {};
        // Simple parsing for key:value pairs (format: "28/07:165.2|29/07:164.8")
        savedJson.split('|').forEach((pair) {
          var parts = pair.split(':');
          if (parts.length == 2) {
            tempMap[parts[0]] = double.parse(parts[1]);
          }
        });

        weightHistoryMap = tempMap.map(
          (key, value) => MapEntry(key, value.toDouble()),
        );
        print(
          '🔄 Loaded weight history map: ${weightHistoryMap.length} entries',
        );
      } catch (e) {
        print('Error parsing weight history map: $e');
        weightHistoryMap = {};
      }
    } else {
      print('🆕 First time: Creating weight history map...');
      weightHistoryMap = {};
    }

    // Generate data cho các ngày thiếu - từ startWeight đến currentWeight
    DateTime now = DateTime.now();

    // Generate cho 90 ngày (bao gồm cả 7 và 30 ngày)
    for (int i = 0; i < 90; i++) {
      DateTime date = now.subtract(Duration(days: 90 - 1 - i));
      String dateKey =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
    }

    // Update ngày hôm nay với current weight (luôn accurate)
    String todayKey =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}";
    weightHistoryMap[todayKey] = currentWeight;
    print(
      '✅ Updated today ($todayKey) weight: ${currentWeight.toStringAsFixed(1)} lbs',
    );

    // Cleanup old data (optional - giữ data trong 1 năm)
    DateTime cutoffDate = now.subtract(Duration(days: 365));
    List<String> keysToRemove = [];

    weightHistoryMap.forEach((key, value) {
      try {
        List<String> parts = key.split('/');
        if (parts.length == 2) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = now.year;

          // Handle year rollover (nếu tháng > current month thì là năm trước)
          if (month > now.month) {
            year = now.year - 1;
          }

          DateTime entryDate = DateTime(year, month, day);
          if (entryDate.isBefore(cutoffDate)) {
            keysToRemove.add(key);
          }
        }
      } catch (e) {
        // Skip invalid date keys
      }
    });

    // Remove old entries
    for (String key in keysToRemove) {
      weightHistoryMap.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      print('🗑️ Cleaned up ${keysToRemove.length} old weight entries');
    }

    // Save updated map to SharedPreferences
    String mapJson = weightHistoryMap.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');
    await prefs.setString('weight_history_map_json', mapJson);

    // Generate arrays từ map cho UI
    _generateArraysFromMap();

    print('✅ History data loaded: Map has ${weightHistoryMap.length} entries');
    print('   Start Weight: ${startWeight.toStringAsFixed(1)} lbs');
    print('   Current Weight: ${currentWeight.toStringAsFixed(1)} lbs');
    print('   Goal: $userGoal');
    print('   Generated realistic progression from start to current weight');
  }

  // Generate arrays từ map dựa trên current date
  void _generateArraysFromMap() {
    DateTime now = DateTime.now();
    DateTime? firstEntryDate = accountCreatedDate;

    // 7 ngày
    weightHistory7 = [];
    calHistory7 = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = now.subtract(Duration(days: 6 - i));
      String dateKey =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
      if (firstEntryDate != null && date.isBefore(firstEntryDate)) {
        weightHistory7.add(0);
        calHistory7.add(0);
      } else {
        weightHistory7.add(weightHistoryMap[dateKey] ?? startWeight);
        calHistory7.add(caloriesPerDay.toDouble());
      }
    }

    // 30 ngày
    weightHistory30 = [];
    calHistory30 = [];
    for (int i = 0; i < 30; i++) {
      DateTime date = now.subtract(Duration(days: 29 - i));
      String dateKey =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
      if (firstEntryDate != null && date.isBefore(firstEntryDate)) {
        weightHistory30.add(0);
        calHistory30.add(0);
      } else {
        weightHistory30.add(weightHistoryMap[dateKey] ?? startWeight);
        calHistory30.add(caloriesPerDay.toDouble());
      }
    }

    // 90 ngày
    weightHistory90 = [];
    calHistory90 = [];
    for (int i = 0; i < 90; i++) {
      DateTime date = now.subtract(Duration(days: 89 - i));
      String dateKey =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
      if (firstEntryDate != null && date.isBefore(firstEntryDate)) {
        weightHistory90.add(0);
        calHistory90.add(0);
      } else {
        weightHistory90.add(weightHistoryMap[dateKey] ?? startWeight);
        calHistory90.add(caloriesPerDay.toDouble());
      }
    }

    print(
      '✅ Arrays generated: 7d=${weightHistory7.length}, 30d=${weightHistory30.length}, 90d=${weightHistory90.length}',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5FBF8),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.teal[600]),
              SizedBox(height: 16),
              Text(
                'Loading your profile...',
                style: TextStyle(fontSize: 16, color: Colors.teal[700]),
              ),
            ],
          ),
        ),
      );
    }

    // Show error if no data
    if (userInfo == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5FBF8),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              SizedBox(height: 16),
              Text(
                'Unable to load profile data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _loadUserData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                ),
                child: Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    // Giữ nguyên giao diện cũ, chỉ thay data source
    return Scaffold(
      backgroundColor: const Color(0xFFF5FBF8),
      body: SafeArea(
        child: Column(
          children: [
            // Header profile - giữ nguyên
            Container(
              color: const Color(0xFFE5F6F4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row top: Avatar, Name, Settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              _avatarFile == null
                                  ? CircleAvatar(
                                      radius: 36,
                                      backgroundColor: Colors.teal[400],
                                      child: Text(
                                        userName.isNotEmpty
                                            ? userName[0].toUpperCase()
                                            : "",
                                        style: const TextStyle(
                                          fontSize: 38,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 36,
                                      backgroundImage: FileImage(_avatarFile!),
                                    ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _pickAvatar,
                                  child: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.edit,
                                      size: 15,
                                      color: Colors.teal[400],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () async {
                                      // Giữ nguyên edit profile functionality
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfileScreen(
                                                name: userName,
                                                goal: goal,
                                                calories: caloriesPerDay,
                                                startWeight: startWeight,
                                                currentWeight: currentWeight,
                                                goalWeight: goalWeight,
                                              ),
                                        ),
                                      );
                                      if (result != null) {
                                        await _updateUserData(result);
                                      }
                                    },
                                    child: const Icon(Icons.edit, size: 18),
                                  ),
                                ],
                              ),
                              Text(
                                goal,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.teal[900],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Text(
                          '$caloriesPerDay Cal / d',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // BMI display
                      if (currentBMI != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.teal[50],
                          ),
                          child: Text(
                            'BMI ${currentBMI!.toStringAsFixed(1)} (${_getBMICategory(currentBMI!)})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Tab Weight/Nutrition - giữ nguyên
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 0
                                    ? Colors.teal
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Text(
                            'Weight',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedTabIndex == 0
                                  ? Colors.teal[900]
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 1
                                    ? Colors.teal
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Text(
                            'Nutrition',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedTabIndex == 1
                                  ? Colors.teal[900]
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Nội dung từng tab - giữ nguyên
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildWeightTab()
                  : _buildNutritionTab(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        selectedItemColor: Colors.teal[800],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() => _selectedBottomIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const JournalScreen()),
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

  // Update user data với UserService
  Future<void> _updateUserData(Map<String, dynamic> newData) async {
    try {
      print('🔄 Updating user data...');
      final prefs = await SharedPreferences.getInstance();

      // Update name
      if (newData['name'] != null && newData['name'] != userName) {
        await UserService.updateName(newData['name']);
        print('✅ Name updated: ${newData['name']}');
      }

      // Update goal
      if (newData['goal'] != null && newData['goal'] != goal) {
        String goalForService = _mapGoalToService(newData['goal']);
        await UserService.updateGoal(goalForService);
        print('✅ Goal updated: ${newData['goal']}');
      }

      // Update weight (convert lbs to kg) - chỉ update current weight
      if (newData['currentWeight'] != null &&
          newData['currentWeight'] != currentWeight) {
        double weightInKg = _lbsToKg(newData['currentWeight']);
        await UserService.updateWeight(weightInKg);
        print(
          '✅ Weight updated: ${newData['currentWeight']} lbs (${weightInKg.toStringAsFixed(1)} kg)',
        );

        // Update weight history arrays
        setState(() {
          currentWeight = newData['currentWeight'];

          // Update only the last point (today) in weight history arrays
          if (weightHistory7.isNotEmpty) {
            weightHistory7[weightHistory7.length - 1] = currentWeight;
          }
          if (weightHistory30.isNotEmpty) {
            weightHistory30[weightHistory30.length - 1] = currentWeight;
          }
          if (weightHistory90.isNotEmpty) {
            weightHistory90[weightHistory90.length - 1] = currentWeight;
          }
        });
      }

      // State update - FIXED: Update SharedPreferences
      setState(() {
        userName = newData['name'] ?? userName;
        goal = newData['goal'] ?? goal;
        caloriesPerDay = newData['calories'] ?? caloriesPerDay;

        // Update SharedPreferences
        if (newData['startWeight'] != null) {
          startWeight = newData['startWeight'];
          prefs.setDouble('profile_start_weight', startWeight);
          print(
            '💾 Updated persistent start weight = ${startWeight.toStringAsFixed(1)} lbs',
          );
        }
        if (newData['currentWeight'] != null) {
          currentWeight = newData['currentWeight'];
        }
        if (newData['goalWeight'] != null) {
          goalWeight = newData['goalWeight'];
          prefs.setDouble('profile_goal_weight', goalWeight);
          print(
            '💾 Updated persistent goal weight = ${goalWeight.toStringAsFixed(1)} lbs',
          );
        }
      });

      print('✅ User data updated successfully');
    } catch (e) {
      print('❌ Error updating user data: $e');
    }
  }

  // Map goal text về format UserService
  String _mapGoalToService(String displayGoal) {
    switch (displayGoal.toLowerCase()) {
      case 'lose weight':
        return 'lose weight';
      case 'gain weight':
        return 'gain weight';
      default:
        return 'maintain weight';
    }
  }

  // ----- WEIGHT TAB - giữ nguyên hoàn toàn -----
  Widget _buildWeightTab() {
    final weightHistory = _selectedDayRange == 0
        ? weightHistory7
        : _selectedDayRange == 1
        ? weightHistory30
        : weightHistory90;
    final weightDates = _selectedDayRange == 0
        ? weightDates7
        : _selectedDayRange == 1
        ? weightDates30
        : weightDates90;

    double maxWeight = (weightHistory.isNotEmpty)
        ? weightHistory.reduce((a, b) => a > b ? a : b)
        : 1;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Thông tin cân nặng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _weightInfoBlock("Start weight", startWeight),
                _weightInfoBlock("Current weight", currentWeight),
                _weightInfoBlock("Goal weight", goalWeight),
              ],
            ),
          ),
          // Nút Add weight entry
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[900],
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _showAddWeightDialog,
              child: const Text(
                "Add a weight entry",
                style: TextStyle(
                  fontSize: 17,
                  color: Color.fromARGB(255, 253, 251, 251),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Switch day range
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            child: Row(
              children: [
                _dayRangeButton("7 days", 0),
                const SizedBox(width: 10),
                _dayRangeButton("30 days", 1),
                const SizedBox(width: 10),
                _dayRangeButton("90 days", 2),
              ],
            ),
          ),
          // Biểu đồ cân nặng - giữ nguyên
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Weight History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Container(
            height: 300,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxWeight,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          touchedSpot.y.toStringAsFixed(
                            2,
                          ), // Giữ nguyên format cũ
                          const TextStyle(
                            color: Color.fromARGB(
                              255,
                              247,
                              248,
                              248,
                            ), // Giữ nguyên màu cũ
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < weightHistory.length; i++)
                        FlSpot(i.toDouble(), weightHistory[i]),
                    ],
                    isCurved: false, // Đường thẳng nối các điểm, kể cả điểm 0
                    barWidth: 3,
                    color: Colors.teal[700],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (spot.y == 0) {
                          return FlDotCirclePainter(
                            radius: 0,
                            color: Colors.transparent,
                            strokeWidth: 0,
                            strokeColor: Colors.transparent,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.teal[700]!,
                          strokeWidth: 0,
                          strokeColor: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.teal.withOpacity(0.12),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        if ((value - 0).abs() < 0.1) {
                          return Text(
                            "0",
                            style: const TextStyle(fontSize: 13),
                          );
                        }
                        if ((value - maxWeight).abs() < 0.1) {
                          return Text(
                            maxWeight.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 13),
                          );
                        }
                        return Container();
                      },
                      interval: maxWeight,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0 || value < 0) return Container();
                        if (_selectedDayRange == 0) {
                          if (value < 0 || value >= weightDates.length)
                            return Container();
                          return Text(
                            weightDates[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        } else if (_selectedDayRange == 1) {
                          if (value == 0 ||
                              value == 9 ||
                              value == 19 ||
                              value == 29) {
                            return Text(
                              weightDates[value.toInt()],
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return Container();
                        } else {
                          if (value == 0 ||
                              value == 29 ||
                              value == 59 ||
                              value == 89) {
                            return Text(
                              weightDates[value.toInt()],
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true, verticalInterval: 1),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- NUTRITION TAB - giữ nguyên hoàn toàn -----
  Widget _buildNutritionTab() {
    final calHistory = _selectedDayRange == 0
        ? calHistory7
        : _selectedDayRange == 1
        ? calHistory30
        : calHistory90;
    final calDates = _selectedDayRange == 0
        ? weightDates7
        : _selectedDayRange == 1
        ? weightDates30
        : weightDates90;

    double maxCal = (calHistory.isNotEmpty)
        ? calHistory.reduce((a, b) => a > b ? a : b)
        : 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Switch day range
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            child: Row(
              children: [
                _dayRangeButton("7 days", 0),
                const SizedBox(width: 10),
                _dayRangeButton("30 days", 1),
                const SizedBox(width: 10),
                _dayRangeButton("90 days", 2),
              ],
            ),
          ),
          // Biểu đồ calo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
            child: const Text(
              "Calories History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            height: 300,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxCal,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          touchedSpot.y.toStringAsFixed(
                            2,
                          ), // Giữ nguyên format cũ
                          const TextStyle(
                            color: Color.fromARGB(
                              255,
                              247,
                              248,
                              248,
                            ), // Giữ nguyên màu cũ
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < calHistory.length; i++)
                        FlSpot(i.toDouble(), calHistory[i]),
                    ],
                    isCurved: false, // Đường thẳng nối các điểm, kể cả điểm 0
                    barWidth: 3,
                    color: Colors.teal[700],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (spot.y == 0) {
                          return FlDotCirclePainter(
                            radius: 0,
                            color: Colors.transparent,
                            strokeWidth: 0,
                            strokeColor: Colors.transparent,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.teal[700]!,
                          strokeWidth: 0,
                          strokeColor: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.teal.withOpacity(0.12),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 54,
                      getTitlesWidget: (value, meta) {
                        if ((value - 0).abs() < 0.1) {
                          return Text(
                            "0",
                            style: const TextStyle(fontSize: 13),
                          );
                        }
                        if ((value - maxCal).abs() < 0.1) {
                          return Text(
                            maxCal.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 13),
                          );
                        }
                        return Container();
                      },
                      interval: maxCal,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0 || value < 0) return Container();
                        if (_selectedDayRange == 0) {
                          if (value < 0 || value >= calDates.length)
                            return Container();
                          return Text(
                            calDates[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        } else if (_selectedDayRange == 1) {
                          if (value == 0 ||
                              value == 9 ||
                              value == 19 ||
                              value == 29) {
                            return Text(
                              calDates[value.toInt()],
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return Container();
                        } else {
                          if (value == 0 ||
                              value == 29 ||
                              value == 59 ||
                              value == 89) {
                            return Text(
                              calDates[value.toInt()],
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true, verticalInterval: 1),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          // Meal Grade
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: const Text(
              "Meal Grade",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "No meal grade yet.",
                  style: TextStyle(fontSize: 17, color: Colors.teal),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget nút chọn day range - giữ nguyên
  Widget _dayRangeButton(String label, int value) {
    return GestureDetector(
      onTap: () => setState(() => _selectedDayRange = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _selectedDayRange == value ? Colors.teal[400] : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.teal[200]!, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: _selectedDayRange == value ? Colors.white : Colors.teal[900],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Widget block info cân nặng - giữ nguyên
  Widget _weightInfoBlock(String label, double value) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1) + " lbs",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // ======= Xử lý chọn ảnh avatar - giữ nguyên =======
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatarFile = File(image.path);
      });
    }
  }

  // ======= Dialog nhập cân nặng mới - giữ nguyên logic + UserService =======
  void _showAddWeightDialog() {
    double tempWeight = currentWeight;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new weight entry'),
          content: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Weight (lbs)'),
            onChanged: (value) {
              tempWeight = double.tryParse(value) ?? currentWeight;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final prefs = await SharedPreferences.getInstance();

                  // Save to UserService
                  double weightInKg = _lbsToKg(tempWeight);
                  await UserService.updateWeight(weightInKg);

                  // Recalculate calories và BMI
                  final updatedCalories =
                      await UserService.calculateDailyCalories();
                  final updatedBMI = await UserService.calculateBMI();

                  setState(() {
                    currentWeight = tempWeight;
                    caloriesPerDay = updatedCalories?.toInt() ?? caloriesPerDay;
                    currentBMI = updatedBMI;

                    // Update map với today's date
                    DateTime now = DateTime.now();
                    String todayKey =
                        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}";
                    weightHistoryMap[todayKey] = tempWeight;

                    // Regenerate arrays từ updated map
                    _generateArraysFromMap();
                  });

                  // Save updated map
                  String mapJson = weightHistoryMap.entries
                      .map((e) => '${e.key}:${e.value}')
                      .join('|');
                  await prefs.setString('weight_history_map_json', mapJson);

                  _generateArraysFromMap();

                  Navigator.pop(context);
                  print(
                    '✅ Weight updated for today: ${tempWeight.toStringAsFixed(1)} lbs',
                  );
                  print('✅ Previous days data preserved in map');
                } catch (e) {
                  print('❌ Error updating weight: $e');
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// ========== EDIT PROFILE SCREEN - giữ nguyên hoàn toàn ==========
class EditProfileScreen extends StatefulWidget {
  final String name;
  final String goal;
  final int calories;
  final double startWeight;
  final double currentWeight;
  final double goalWeight;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.goal,
    required this.calories,
    required this.startWeight,
    required this.currentWeight,
    required this.goalWeight,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController goalCtrl;
  late TextEditingController caloriesCtrl;
  late TextEditingController startWeightCtrl;
  late TextEditingController currentWeightCtrl;
  late TextEditingController goalWeightCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.name);
    goalCtrl = TextEditingController(text: widget.goal);
    caloriesCtrl = TextEditingController(text: widget.calories.toString());
    startWeightCtrl = TextEditingController(
      text: widget.startWeight.toString(),
    );
    currentWeightCtrl = TextEditingController(
      text: widget.currentWeight.toString(),
    );
    goalWeightCtrl = TextEditingController(text: widget.goalWeight.toString());
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    goalCtrl.dispose();
    caloriesCtrl.dispose();
    startWeightCtrl.dispose();
    currentWeightCtrl.dispose();
    goalWeightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.teal[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: goalCtrl,
              decoration: const InputDecoration(
                labelText: "Goal (e.g. Gain muscle)",
              ),
            ),
            TextField(
              controller: caloriesCtrl,
              decoration: const InputDecoration(labelText: "Calories per day"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: startWeightCtrl,
              decoration: const InputDecoration(
                labelText: "Start Weight (lbs)",
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: currentWeightCtrl,
              decoration: const InputDecoration(
                labelText: "Current Weight (lbs)",
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: goalWeightCtrl,
              decoration: const InputDecoration(labelText: "Goal Weight (lbs)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameCtrl.text,
                  'goal': goalCtrl.text,
                  'calories': int.tryParse(caloriesCtrl.text),
                  'startWeight': double.tryParse(startWeightCtrl.text),
                  'currentWeight': double.tryParse(currentWeightCtrl.text),
                  'goalWeight': double.tryParse(goalWeightCtrl.text),
                });
              },
              child: const Text(
                "Save",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 251, 251, 251),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
