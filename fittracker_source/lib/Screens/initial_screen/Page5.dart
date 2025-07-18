import 'package:flutter/material.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  String selectedLifestyle = "Student";

  final List<String> options = [
    "Student",
    "Employed part-time",
    "Employed full-time",
    "Not employed",
    "Retired",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your daily life affects your weight.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "How would you describe your lifestyle?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Danh sách lựa chọn
              Column(
                children: options.map((item) {
                  final isSelected = selectedLifestyle == item;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLifestyle = item;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFF0D9)
                            : const Color(0xFFF7F9FB),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.black : Colors.grey[800],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      // Nút quay lại
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
