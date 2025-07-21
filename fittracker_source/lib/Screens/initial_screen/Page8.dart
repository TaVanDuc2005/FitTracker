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
    "Hypertension or high blood pressure",
    "Diabetes",
    "Depression",
    "Eating disorders (Anorexia, Bulimia)",
    "Other",
    "None",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Text positioned at top
            Positioned(
              top: 60,
              left: 30,
              right: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Have you ever had any of the following conditions?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Options list positioned in middle - vertical list
            Positioned(
              top: 120,
              left: 24,
              right: 24,
              bottom: 100,
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
                                color: isSelected ? Colors.green : Colors.grey,
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

            // Bottom buttons
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor: Colors.white,
                    elevation: 2,
                    heroTag: "back",
                    child: const Icon(Icons.arrow_back, color: Colors.black),
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
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
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
