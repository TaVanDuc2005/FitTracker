  import 'package:flutter/material.dart';
  import 'Page7.dart';

  class DietaryRestrictionsScreen6 extends StatefulWidget {
    const DietaryRestrictionsScreen6({super.key});

    @override
    State<DietaryRestrictionsScreen6> createState() =>
        _DietaryRestrictionsScreenState();
  }

  class _DietaryRestrictionsScreenState extends State<DietaryRestrictionsScreen6> {
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
              // Back & Next buttons
              Positioned(
                bottom: 30,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Quay về Page 5
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
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DietaryRestrictionsScreen7(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.black87,
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(color: Colors.white),
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
