import 'package:flutter/material.dart';

enum MealType { breakfast, lunch, dinner }

class SearchFoodScreen extends StatefulWidget {
  final MealType mealType;

  const SearchFoodScreen({super.key, required this.mealType});

  @override
  State<SearchFoodScreen> createState() => _SearchFoodScreenState();
}

class _SearchFoodScreenState extends State<SearchFoodScreen> {
  bool isSearchSelected = true;

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
            // Header với meal info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Avatar meal
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        _mealImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Text info
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
                        const Text(
                          "0 / 1056 Cal",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // Close button
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

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: 0.0,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // White content area
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
                    children: [
                      // Navigation buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavButton(
                            "Search",
                            Icons.search,
                            isSearchSelected,
                            () {
                              setState(() {
                                isSearchSelected = true;
                              });
                            },
                          ),
                          _buildNavButton(
                            "Proposal",
                            Icons.stars,
                            !isSearchSelected,
                            () {
                              setState(() {
                                isSearchSelected = false;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Content based on selection
                      if (isSearchSelected) ...[
                        // Search bar
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Search for a food",
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
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
                              borderSide: const BorderSide(
                                color: Color(0xFF8FD5C7),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                          onChanged: (value) {
                            // TODO: Implement search functionality
                          },
                        ),

                        const SizedBox(height: 30),

                        // Avocado character
                        Image.asset(
                          'Assets/Images/imagePageSearch_2.png',
                          width: 200,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ] else ...[
                        // Proposal content
                        const Center(
                          child: Column(
                            children: [
                              SizedBox(height: 100),
                              Icon(
                                Icons.lightbulb_outline,
                                size: 80,
                                color: Colors.grey,
                              ),
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
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
