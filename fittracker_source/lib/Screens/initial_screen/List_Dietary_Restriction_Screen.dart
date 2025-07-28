import 'package:flutter/material.dart';
import 'Health_Goal_Screen.dart';
import '../../services/user_service.dart';

class listDietaryRestrictionsScreen extends StatefulWidget {
  const listDietaryRestrictionsScreen({super.key});

  @override
  State<listDietaryRestrictionsScreen> createState() =>
      _DietaryRestrictionsScreenState();
}

class _DietaryRestrictionsScreenState
    extends State<listDietaryRestrictionsScreen> {
  List<String> selectedRestrictions = [];

  final List<String> options = [
    "Veganism",
    "Vegetarianism",
    "Pescetarianism",
    "Gluten-Free",
    "Lactose intolerant",
    "Nut allergy",
    "Seafood or Shellfish",
    "Other",
    "None",
  ];

  @override
  void initState() {
    // THÊM initState
    super.initState();
    _loadSavedRestrictions();
  }

  // THÊM: Load dietary restrictions đã lưu
  Future<void> _loadSavedRestrictions() async {
    final savedRestrictions = await UserService.getDietaryRestrictionsList();
    if (savedRestrictions != null && savedRestrictions.isNotEmpty) {
      if (mounted) {
        setState(() {
          selectedRestrictions = savedRestrictions
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        });
      }
    }
  }

  // THÊM: Lưu dietary restrictions
  Future<void> _saveRestrictions() async {
    if (selectedRestrictions.isNotEmpty) {
      final restrictionsString = selectedRestrictions.join(', ');
      final success = await UserService.updateDietaryRestrictionsList(
        restrictionsString,
      ); // SỬA METHOD
      if (success) {
        print('✅ Dietary restrictions list saved: $restrictionsString');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Text positioned at top
            Container(
              padding: const EdgeInsets.fromLTRB(30, 60, 30, 20),
              child: const Text(
                "Which restrictions/allergies do you have?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),

            // Options list - scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: options.map((item) {
                    final isSelected = selectedRestrictions.contains(item);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedRestrictions.remove(item);
                          } else {
                            selectedRestrictions.add(item);
                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFF0D9)
                              : const Color(0xFFF7F9FB),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[800],
                                ),
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),

                  // Next button - only show if something is selected
                  if (selectedRestrictions.isNotEmpty)
                    ElevatedButton(
                      onPressed: () async {
                        // LƯU DIETARY RESTRICTIONS TRƯỚC KHI CHUYỂN TRANG
                        await _saveRestrictions();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const healthGoalsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
