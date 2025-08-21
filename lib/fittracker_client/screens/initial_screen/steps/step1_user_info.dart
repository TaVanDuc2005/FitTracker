import 'package:flutter/material.dart';
import '../../../services/user/user_service.dart';
import '../../../models/user.dart' as app_user;
import '../enter_name_screen.dart';

class Step1UserInfo extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const Step1UserInfo({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<Step1UserInfo> createState() => _Step1UserInfoState();
}

class _Step1UserInfoState extends State<Step1UserInfo> {
  String gender = '';
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  
  final UserService _userService = UserService();
  app_user.User? _tempUser;

  bool get isGenderSelected => gender.isNotEmpty;
  bool get isAgeEntered => ageController.text.isNotEmpty;
  bool get isHeightEntered => heightController.text.isNotEmpty;
  bool get isWeightEntered => weightController.text.isNotEmpty;
  bool get isAllCompleted =>
      isGenderSelected && isAgeEntered && isHeightEntered && isWeightEntered;

  @override
  void initState() {
    super.initState();
    ageController.addListener(() => setState(() {}));
    heightController.addListener(() => setState(() {}));
    weightController.addListener(() => setState(() {}));
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    // Lấy tên đã lưu từ step trước
    final savedName = await UserService.getName();
    
    // Tạo user tạm thời từ dữ liệu đã có
    _tempUser = await _userService.createUserFromTempData();
    
    // Nếu chưa có user tạm thời, tạo mới với tên đã lưu
    if (_tempUser == null && savedName != null) {
      _tempUser = app_user.User(name: savedName);
    }
    
    // Load dữ liệu vào UI nếu có
    if (_tempUser != null && mounted) {
      setState(() {
        gender = _tempUser!.gender;
        ageController.text = _tempUser!.age.toString();
        heightController.text = _tempUser!.height.toString();
        weightController.text = _tempUser!.weight.toString();
      });
    }
  }

  Future<void> _saveTempData() async {
    final age = int.tryParse(ageController.text);
    final height = double.tryParse(heightController.text);
    final weight = double.tryParse(weightController.text);

    if (age == null || height == null || weight == null) {
      throw Exception('Invalid input values');
    }

    // Cập nhật user tạm thời
    if (_tempUser != null) {
      _tempUser = _tempUser!.copyWith(
        gender: gender,
        age: age,
        height: height,
        weight: weight,
      );
    } else {
      // Tạo user mới nếu chưa có
      final savedName = await UserService.getName();
      _tempUser = app_user.User(
        name: savedName,
        gender: gender,
        age: age,
        height: height,
        weight: weight,
      );
    }

    // Backup tạm thời vào local storage
    await _userService.backupToLocal(_tempUser!);
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
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What is your gender?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: ["male", "female", "non_binary"].map((value) {
                  final isSelected = gender == value;
                  final displayName = value == "male" ? "Male" : 
                                    value == "female" ? "Female" : "Non binary";
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(displayName),
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

              if (isGenderSelected) ...[
                const SizedBox(height: 24),
                const Text(
                  "How old are you (years)?",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                _customInputField(
                  controller: ageController,
                  hintText: "Enter your age",
                ),
              ],
              if (isGenderSelected && isAgeEntered) ...[
                const SizedBox(height: 20),
                const Text(
                  "What is your height (cm)?",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                _customInputField(
                  controller: heightController,
                  hintText: "Enter your height",
                ),
              ],
              if (isGenderSelected && isAgeEntered && isHeightEntered) ...[
                const SizedBox(height: 20),
                const Text(
                  "What is your current weight (kg)?",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                _customInputField(
                  controller: weightController,
                  hintText: "Enter your weight",
                ),
              ],
            ],
          ),
        ),

        // Back button
        Positioned(
          left: 16,
          bottom: 30,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => EnterNameScreen()),
              );
            },
          ),
        ),

        // Next button
        if (isAllCompleted)
          Positioned(
            bottom: 30,
            right: 24,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await _saveTempData();
                  widget.onNext();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter valid numbers! Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
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
      ],
    );
  }

  Widget _customInputField({
    required TextEditingController controller, 
    String? hintText
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
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