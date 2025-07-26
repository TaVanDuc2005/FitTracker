import 'package:flutter/material.dart';
import 'Life_style_Screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  String gender = '';
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  // Theo dõi trạng thái hoàn thành
  bool get isGenderSelected => gender.isNotEmpty;
  bool get isAgeEntered => ageController.text.isNotEmpty;
  bool get isHeightEntered => heightController.text.isNotEmpty;
  bool get isWeightEntered => weightController.text.isNotEmpty;
  bool get isAllCompleted =>
      isGenderSelected && isAgeEntered && isHeightEntered && isWeightEntered;

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi trong text fields
    ageController.addListener(() => setState(() {}));
    heightController.addListener(() => setState(() {}));
    weightController.addListener(() => setState(() {}));
  }

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
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gender Selection - Luôn hiển thị
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

                // Age - Hiện sau khi chọn gender
                if (isGenderSelected) ...[
                  const SizedBox(height: 24),
                  const Text(
                    "How old are you?",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  _customInputField(controller: ageController),
                ],

                // Height - Hiện sau khi nhập age
                if (isGenderSelected && isAgeEntered) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "What is your height?",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  _customInputField(controller: heightController),
                ],

                // Weight - Hiện sau khi nhập height
                if (isGenderSelected && isAgeEntered && isHeightEntered) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "What is your current weight?",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  _customInputField(controller: weightController),
                ],
              ],
            ),
          ),

          // Next Button - Chỉ hiện khi tất cả đã hoàn thành
          if (isAllCompleted)
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: AnimatedOpacity(
                opacity: isAllCompleted ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LifestyleScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
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

  Widget _customInputField({required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFFF0D9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}
