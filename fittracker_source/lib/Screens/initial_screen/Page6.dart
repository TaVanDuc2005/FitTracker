import 'package:flutter/material.dart';

class DietaryRestrictionsScreen extends StatefulWidget {
  const DietaryRestrictionsScreen({super.key});

  @override
  State<DietaryRestrictionsScreen> createState() =>
      _DietaryRestrictionsScreenState();
}

class _DietaryRestrictionsScreenState extends State<DietaryRestrictionsScreen> {
  String selectedRestriction = "None";

  final List<String> options = ["Yes", "No"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Image positioned at top
            Positioned(
              top: 20,
              left: 30,
              child: Image.asset(
                'Assets/Images/imagePage6.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),

            // Text positioned below image
            Positioned(
              top: 160,
              left: 30,
              right: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Do you have any dietary restrictions or food allergies?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Options list positioned in middle
            Positioned(
              top: 240,
              left: 24,
              right: 24,
              child: Row(
                children: options.map((item) {
                  final isSelected = selectedRestriction == item;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRestriction = item;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          right: item == "Yes" ? 8 : 0,
                          left: item == "No" ? 8 : 0,
                        ),
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
                        child: Center(
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
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.arrow_back, color: Colors.black),
      ),
    );
  }
}
