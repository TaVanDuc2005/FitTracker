import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fittracker_source/Screens/active_screen/journal/journal_screen.dart';

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

// ====== Dữ liệu giả lập ======
List<double> weightHistory7 = [228.0, 227.8, 227.5, 227.0, 227.3, 227.0, 228.0];
List<double> weightHistory30 = List.generate(30, (i) => 228 - i * 0.1);
List<double> weightHistory90 = List.generate(90, (i) => 228 - i * 0.05);

List<double> calHistory7 = [3200, 3350, 3500, 3518, 3600, 3400, 3518];
List<double> calHistory30 = List.generate(30, (i) => 3200 + (i % 7) * 50.0);
List<double> calHistory90 = List.generate(90, (i) => 3300 + (i % 14) * 25.0);

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

  // Thông tin cá nhân (có thể load từ backend sau này)
  String userName = "Minh";
  String goal = "Gain muscle";
  int caloriesPerDay = 3518;
  double startWeight = 228.0;
  double currentWeight = 228.0;
  double goalWeight = 229.0;

  File? _avatarFile;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FBF8),
      body: SafeArea(
        child: Column(
          children: [
            // Header profile
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
                                      // Chuyển sang màn hình chỉnh sửa profile
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
                                        setState(() {
                                          userName = result['name'] ?? userName;
                                          goal = result['goal'] ?? goal;
                                          caloriesPerDay =
                                              result['calories'] ??
                                              caloriesPerDay;
                                          startWeight =
                                              result['startWeight'] ??
                                              startWeight;
                                          currentWeight =
                                              result['currentWeight'] ??
                                              currentWeight;
                                          goalWeight =
                                              result['goalWeight'] ??
                                              goalWeight;
                                        });
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Tab Weight/Nutrition
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = 0;
                          });
                        },
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
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = 1;
                          });
                        },
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
            // Nội dung từng tab
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
          setState(() {
            _selectedBottomIndex = index;
          });
          // Điều hướng sang màn khác
          if (index == 0) {
            // Chuyển sang Journal
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const JournalScreen()),
            );
          }
          // index == 1 là Profile (màn hình hiện tại), không cần làm gì
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ----- WEIGHT TAB -----
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
          // Biểu đồ cân nặng
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
                          touchedSpot.y.toStringAsFixed(2),
                          const TextStyle(
                            color: Color.fromARGB(
                              255,
                              247,
                              248,
                              248,
                            ), // ĐỔI MÀU CHỮ Ở ĐÂY
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
                    spots: List.generate(
                      weightHistory.length,
                      (i) => FlSpot(i.toDouble(), weightHistory[i]),
                    ),
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.teal[700],
                    dotData: FlDotData(show: true),
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
                          // 7 ngày: hiện đủ 7 mốc
                          if (value < 0 || value >= weightDates.length)
                            return Container();
                          return Text(
                            weightDates[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        } else if (_selectedDayRange == 1) {
                          // 30 ngày: 4 mốc 0, 9, 19, 29
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
                          // 90 ngày: 4 mốc 0, 29, 59, 89
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

  // ----- NUTRITION TAB -----
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
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      calHistory.length,
                      (i) => FlSpot(i.toDouble(), calHistory[i]),
                    ),
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.teal[600],
                    dotData: FlDotData(show: true),
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
          // Meal Grade (có thể gắn dữ liệu thật sau)
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

  // Widget nút chọn day range
  Widget _dayRangeButton(String label, int value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDayRange = value;
        });
      },
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

  // Widget block info cân nặng
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

  // ======= Xử lý chọn ảnh avatar =======
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatarFile = File(image.path);
      });
    }
  }

  // ======= Dialog nhập cân nặng mới =======
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  currentWeight = tempWeight;
                  // Thêm vào lịch sử 7 ngày (giả lập thêm ở cuối)
                  weightHistory7.removeAt(0);
                  weightHistory7.add(tempWeight);
                  // Update cho chart các mốc dài hơn nếu cần
                  weightHistory30.removeAt(0);
                  weightHistory30.add(tempWeight);
                  weightHistory90.removeAt(0);
                  weightHistory90.add(tempWeight);
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// ========== EDIT PROFILE SCREEN ==========
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

// ========== SETTINGS SCREEN ==========
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.teal[300],
      ),
      body: const Center(
        child: Text(
          "Settings Content Demo",
          style: TextStyle(fontSize: 20, color: Colors.teal),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
