import 'package:flutter/material.dart';
import '../../../services/user/user_service.dart';
import '../../../models/user.dart' as app_user;

class Step4ListDietaryRestrictions extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const Step4ListDietaryRestrictions({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<Step4ListDietaryRestrictions> createState() =>
      _Step4ListDietaryRestrictionsState();
}

class _Step4ListDietaryRestrictionsState
    extends State<Step4ListDietaryRestrictions> {
  List<String> selectedRestrictions = [];
  final UserService _userService = UserService();
  app_user.User? _tempUser;

  final List<String> options = [
    "Veganism",
    "Vegetarianism", 
    "Pescetarianism",
    "Gluten-Free",
    "Lactose intolerant",
    "Nut allergy",
    "Seafood or Shellfish",
    "Other",
    "None",
  ];

  bool get hasRestrictions => selectedRestrictions.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      // Thử restore từ backup local trước
      _tempUser = await _userService.restoreFromLocal();
      
      // Nếu không có backup, tạo từ temp data
      if (_tempUser == null) {
        _tempUser = await _userService.createUserFromTempData();
      }
      
      // Nếu vẫn không có, tạo user mới với tên đã lưu
      if (_tempUser == null) {
        final savedName = await UserService.getName();
        if (savedName != null) {
          _tempUser = app_user.User(name: savedName);
        }
      }
      
      if (_tempUser != null && mounted) {
        final restrictionsList = _tempUser!.dietaryRestrictionsList;
        if (restrictionsList.isNotEmpty) {
          setState(() {
            selectedRestrictions = restrictionsList
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }

  Future<void> _saveTempData() async {
    if (_tempUser == null) return;
    
    final restrictionsString = selectedRestrictions.join(', ');
    final hasDietaryRestrictions = selectedRestrictions.isEmpty || 
                                  selectedRestrictions.contains('None') ? 'no' : 'yes';
    
    _tempUser = _tempUser!.copyWith(
      hasDietaryRestrictions: hasDietaryRestrictions,
      dietaryRestrictionsList: restrictionsString,
    );
    
    // Backup to local storage
    await _userService.backupToLocal(_tempUser!);
    print('✅ Saved dietary restrictions: $restrictionsString');
  }

  void _handleRestrictionToggle(String item) {
    setState(() {
      // Nếu chọn "None", xóa hết các lựa chọn khác
      if (item == "None") {
        if (selectedRestrictions.contains("None")) {
          selectedRestrictions.clear();
        } else {
          selectedRestrictions.clear();
          selectedRestrictions.add("None");
        }
      } else {
        // Nếu chọn restriction khác, xóa "None" nếu có
        selectedRestrictions.remove("None");
        
        if (selectedRestrictions.contains(item)) {
          selectedRestrictions.remove(item);
        } else {
          selectedRestrictions.add(item);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dietary Restrictions",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Which restrictions/allergies do you have?",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Selected: ${selectedRestrictions.length}",
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: options.map((item) {
                    final isSelected = selectedRestrictions.contains(item);
                    final isNone = item == "None";
                    
                    return GestureDetector(
                      onTap: () => _handleRestrictionToggle(item),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFF0D9)
                              : const Color(0xFFF7F9FB),
                          borderRadius: BorderRadius.circular(24),
                          border: isSelected
                              ? Border.all(color: Colors.orange.shade200, width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[800],
                                ),
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isNone ? Colors.blue : Colors.orange)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected 
                                      ? (isNone ? Colors.blue : Colors.orange)
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: widget.onBack,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    onPressed: !hasRestrictions
                        ? null
                        : () async {
                            try {
                              await _saveTempData();
                              widget.onNext();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error saving data: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasRestrictions ? Colors.black87 : Colors.grey,
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