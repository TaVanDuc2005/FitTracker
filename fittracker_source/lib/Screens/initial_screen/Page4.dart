import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String gender = 'Male';
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What is your gender?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  children: ["Male", "Female", "Non binary"].map((value) {
                    final isSelected = gender == value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(value),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            gender = value;
                          });
                        },
                        selectedColor: const Color(0xFFFFF0D9),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                const Text("How old are you?", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                _customInputField(controller: ageController),

                const SizedBox(height: 20),
                const Text("What is your height?", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                _customInputField(controller: heightController),

                const SizedBox(height: 20),
                const Text("What is your current weight?", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                _customInputField(controller: weightController),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Chuyển sang màn hình tiếp theo hoặc xử lý logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Next", style: TextStyle(fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }

  Widget _customInputField({
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFFF0D9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}
