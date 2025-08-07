import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class Step3DietaryRestriction extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(int) onSkipToStep;

  const Step3DietaryRestriction({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkipToStep,
  });

  @override
  State<Step3DietaryRestriction> createState() => _Step3GoalState();
}

class _Step3GoalState extends State<Step3DietaryRestriction> {
  String selectedRestriction = "";
  final List<String> options = ["Yes", "No"];

  bool get isOptionSelected => selectedRestriction.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadSavedRestriction();
  }

  Future<void> _loadSavedRestriction() async {
    final savedRestriction =
        await UserService.getHasDietaryRestrictions();
    if (savedRestriction != null && savedRestriction.isNotEmpty) {
      setState(() {
        selectedRestriction = savedRestriction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Stack(
        children: [
          // Nội dung chính
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'Assets/Images/imagePage6.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                "Do you have any dietary restrictions or food allergies?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              Row(
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
            ],
          ),

          // Nút Back
          Positioned(
            bottom: 20,
            left: 0,
            child: ElevatedButton(
              onPressed: widget.onBack,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Back",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),

          // Nút Next (chỉ hiện nếu đã chọn)
          if (isOptionSelected)
            Positioned(
              bottom: 20,
              right: 0,
              child: ElevatedButton(
                onPressed: () async {
                  await UserService.updateHasDietaryRestrictions(
                      selectedRestriction);

                  if (selectedRestriction == "Yes") {
                    widget.onNext(); // Sang Step 4
                  } else {
                    widget.onSkipToStep(5); // Bỏ qua Step 4 -> tới Step 5
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
