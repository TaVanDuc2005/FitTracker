import 'package:flutter/material.dart';
import 'Page6.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  String selectedLifestyle = "";

  final List<String> options = [
    "Student",
    "Employed part-time",
    "Employed full-time",
    "Not employed",
    "Retired",
  ];

  // Kiểm tra đã chọn lifestyle chưa
  bool get isLifestyleSelected => selectedLifestyle.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                100,
              ), // Thêm bottom padding cho button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your daily life affects your weight.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "How would you describe your lifestyle?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),

                  // Danh sách lựa chọn
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
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
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nút Next - Chỉ hiện khi đã chọn lifestyle
          if (isLifestyleSelected)
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: AnimatedOpacity(
                opacity: isLifestyleSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const DietaryRestrictionsScreen6(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
