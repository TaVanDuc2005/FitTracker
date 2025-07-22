import 'package:flutter/material.dart';
import 'Page9.dart';

class DietaryRestrictionsScreen8 extends StatefulWidget {
  const DietaryRestrictionsScreen8({super.key});

  @override
  State<DietaryRestrictionsScreen8> createState() =>
      _DietaryRestrictionsScreenState();
}

class _DietaryRestrictionsScreenState
    extends State<DietaryRestrictionsScreen8> {
  List<String> selectedRestrictions = [];

  final List<String> options = [
    "Weight loss",
    "Weight gain",
    "Muscle building",
    "General health",
    "Energy boost",
    "Better sleep",
    "Digestive health",
    "Other",
  ];

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
                "What are your health goals?",
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FoodvisorIntro(),
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
