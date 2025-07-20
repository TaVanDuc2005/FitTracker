import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  int _selectedBottomIndex = 2; // Profile
  int _selectedDayRange = 0; // 0: 7, 1: 30, 2: 90

  // Bạn gắn dữ liệu động vào các biến này
  final String userName = "Minh";
  final String goal = "Gain muscle";
  final int caloriesPerDay = 3518;
  final double startWeight = 228.0;
  final double currentWeight = 228.0;
  final double goalWeight = 229.0;

  // Dữ liệu mẫu chart (sau này thay bằng dữ liệu động)
  final List<double> weightHistory = [228.0];
  final List<String> weightDates = ["15/07"];
  final List<double> calHistory = [3518, 3518, 3518, 3518, 3518, 3518, 3518];
  final List<String> calDates = [
    "12/07",
    "13/07",
    "14/07",
    "15/07",
    "16/07",
    "17/07",
    "18/07",
  ];

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
                              CircleAvatar(
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
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    // TODO: Edit avatar
                                  },
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
                                    onTap: () {
                                      // TODO: Edit profile info
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
                          // TODO: Setting
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
            // TODO: Điều hướng sang màn khác nếu cần
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notification",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // Tab Weight
  Widget _buildWeightTab() {
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
              onPressed: () {
                // TODO: Thêm entry cân nặng
              },
              child: const Text(
                "Add a weight entry",
                style: TextStyle(fontSize: 17),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Biểu đồ cân nặng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Weight",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Container(
            height: 210,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: LineChart(
              LineChartData(
                minY: (weightHistory.isNotEmpty)
                    ? weightHistory.reduce((a, b) => a < b ? a : b) - 2
                    : 0,
                maxY: (weightHistory.isNotEmpty)
                    ? weightHistory.reduce((a, b) => a > b ? a : b) + 2
                    : 10,
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
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 2),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= weightDates.length)
                          return Container();
                        return Text(weightDates[value.toInt()]);
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true, horizontalInterval: 2),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab Nutrition
  Widget _buildNutritionTab() {
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
              "Goal (Cal)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            height: 210,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: caloriesPerDay + 500,
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
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1000),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= calDates.length)
                          return Container();
                        return Text(calDates[value.toInt()]);
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true, horizontalInterval: 1000),
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
}
