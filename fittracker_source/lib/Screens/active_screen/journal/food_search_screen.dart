import 'package:flutter/material.dart';
import 'package:fittracker_source/models/food.dart';
import 'package:fittracker_source/Screens/active_screen/journal/Meal_Summary_Screen.dart';
import '../../../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Map macro chỉ số cho từng bữa
Future<Map<String, Map<String, int>>> getMealMacroTarget() async {
  final macroTargets = await UserService.calculateMacroTargets();
  if (macroTargets == null) {
    // fallback nếu chưa có dữ liệu
    return {
      "Breakfast": {
        "calories": 600,
        "protein": 40,
        "fat": 20,
        "carbs": 60,
        "fiber": 6,
      },
      "Lunch": {
        "calories": 800,
        "protein": 50,
        "fat": 25,
        "carbs": 100,
        "fiber": 8,
      },
      "Dinner": {
        "calories": 600,
        "protein": 40,
        "fat": 18,
        "carbs": 80,
        "fiber": 7,
      },
    };
  }
  // Chia macro cho từng bữa (30% sáng, 40% trưa, 30% tối)
  return {
    "Breakfast": {
      "calories": (macroTargets['calories']! * 0.3).round(),
      "protein": (macroTargets['protein']! * 0.3).round(),
      "fat": (macroTargets['fat']! * 0.3).round(),
      "carbs": (macroTargets['carbs']! * 0.3).round(),
      "fiber": (macroTargets['fiber']! * 0.3).round(),
    },
    "Lunch": {
      "calories": (macroTargets['calories']! * 0.4).round(),
      "protein": (macroTargets['protein']! * 0.4).round(),
      "fat": (macroTargets['fat']! * 0.4).round(),
      "carbs": (macroTargets['carbs']! * 0.4).round(),
      "fiber": (macroTargets['fiber']! * 0.4).round(),
    },
    "Dinner": {
      "calories": (macroTargets['calories']! * 0.3).round(),
      "protein": (macroTargets['protein']! * 0.3).round(),
      "fat": (macroTargets['fat']! * 0.3).round(),
      "carbs": (macroTargets['carbs']! * 0.3).round(),
      "fiber": (macroTargets['fiber']! * 0.3).round(),
    },
  };
}

enum MealType { breakfast, lunch, dinner }

class SearchFoodScreen extends StatefulWidget {
  final MealType mealType;

  const SearchFoodScreen({Key? key, required this.mealType}) : super(key: key);

  @override
  State<SearchFoodScreen> createState() => _SearchFoodScreenState();
}

class _SearchFoodScreenState extends State<SearchFoodScreen> {
  bool isSearchSelected = true;
  Map<Food, int> selectedFoodsWithQuantity = {};
  List<Food> _searchResults = [];
  bool _isLoading = false;
  String _searchKeyword = '';

  // Thêm vào class _SearchFoodScreenState:
  Future<Map<String, Map<String, int>>>? _mealMacroFuture;

  Future<void> _searchFoods(String keyword) async {
    setState(() {
      _isLoading = true;
      _searchKeyword = keyword;
    });

    try {
      final snapshot = await FirebaseFirestore.instance.collection('list_food').get();

      final results = snapshot.docs.map((doc) => Food.fromMap(doc.data())).where((food) {
        final lowerKeyword = keyword.toLowerCase();
        return food.name.toLowerCase().contains(lowerKeyword) ||
              food.description.toLowerCase().contains(lowerKeyword);
      }).toList();

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi tìm kiếm: $e");
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _mealMacroFuture = getMealMacroTarget();
  }

  String get _mealTitle {
    switch (widget.mealType) {
      case MealType.breakfast:
        return "Breakfast";
      case MealType.lunch:
        return "Lunch";
      case MealType.dinner:
        return "Dinner";
    }
  }

  String get _mealImage {
    switch (widget.mealType) {
      case MealType.breakfast:
        return 'Assets/Images/breakfast.png';
      case MealType.lunch:
        return 'Assets/Images/lunch.png';
      case MealType.dinner:
        return 'Assets/Images/dinner.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FD5C7),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(_mealImage, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // ...existing code...
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mealTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FutureBuilder<Map<String, Map<String, int>>>(
                          future: _mealMacroFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                "0 / ... Cal",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return const Text(
                                "0 / ... Cal",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              );
                            }
                            final target =
                                snapshot.data?[_mealTitle]?["calories"];
                            return Text(
                              "0 / ${target ?? "..."} Cal",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // ...existing code...
                  // Nút X để quay lại màn hình trước đó Journal
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),

            // ===== PROGRESS BAR =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: 0.0,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // ===== WHITE CONTENT AREA =====
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Navigation buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavButton(
                            "Search",
                            Icons.search,
                            isSearchSelected,
                            () => setState(() => isSearchSelected = true),
                          ),
                          _buildNavButton(
                            "Proposal",
                            Icons.stars,
                            !isSearchSelected,
                            () => setState(() => isSearchSelected = false),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Phần nội dung có thể cuộn
                      Expanded(
                        child: SingleChildScrollView(
                          child: isSearchSelected
                              ? _buildSearchContent()
                              : _buildProposalContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ===== NÚT CỐ ĐỊNH DƯỚI CÙNG =====
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.summarize),
          label: const Text(
            'View Meal Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: const Color.fromARGB(255, 10, 131, 107),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () async {
            final mealMacroTarget = await getMealMacroTarget();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealSummaryScreen(
                  mealName: _mealTitle,
                  targetCalories: mealMacroTarget[_mealTitle]!["calories"]!,
                  targetProtein: mealMacroTarget[_mealTitle]!["protein"]!,
                  targetFat: mealMacroTarget[_mealTitle]!["fat"]!,
                  targetCarbs: mealMacroTarget[_mealTitle]!["carbs"]!,
                  targetFiber: mealMacroTarget[_mealTitle]!["fiber"]!,
                  foodsWithQuantity: selectedFoodsWithQuantity,
                  onAddMore: () => Navigator.pop(context),
                  onExit: () => Navigator.popUntil(context, (r) => r.isFirst),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchContent() {
    List<Widget> content = [
      TextField(
        decoration: InputDecoration(
          hintText: "Search for a food",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF8FD5C7)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onChanged: (value) {
          if (value.trim().isNotEmpty) {
            _searchFoods(value.trim());
          } else {
            setState(() {
              _searchResults = [];
              _searchKeyword = '';
            });
          }
        },
      ),
      const SizedBox(height: 30),
    ];

    // Hiển thị ảnh minh họa nếu chưa có kết quả
    if (_searchKeyword.isEmpty && !_isLoading) {
      content.add(Center(
        child: Image.asset(
          'Assets/Images/imagePageSearch_2.png',
          width: 200,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
      content.add(const SizedBox(height: 20));
    }

    // Loading
    if (_isLoading) {
      content.add(const Center(child: CircularProgressIndicator()));
    }

    // Không tìm thấy kết quả
    else if (_searchKeyword.isNotEmpty && _searchResults.isEmpty) {
      content.add(const Center(child: Text("Không tìm thấy món ăn nào")));
    }

    // Có kết quả
    else if (_searchResults.isNotEmpty) {
      content.addAll(_searchResults.map((food) {
        return ListTile(
          leading: Image.network(food.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
          title: Text(food.name),
          subtitle: Text(
            "${food.calories} Cal" +
            (selectedFoodsWithQuantity.containsKey(food)
              ? " × ${selectedFoodsWithQuantity[food]}"
              : ""),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF8FD5C7)),
            onPressed: () {
              setState(() {
                if (selectedFoodsWithQuantity.containsKey(food)) {
                  selectedFoodsWithQuantity[food] = selectedFoodsWithQuantity[food]! + 1;
                } else {
                  selectedFoodsWithQuantity[food] = 1;
                }
              });
            },
          ),
        );
      }));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content,
    );
  }


  Widget _buildProposalContent() {
    return Center(
      child: Column(
        children: const [
          SizedBox(height: 100),
          Icon(Icons.lightbulb_outline, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            "Food Proposals",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Coming soon!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8FD5C7) : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
