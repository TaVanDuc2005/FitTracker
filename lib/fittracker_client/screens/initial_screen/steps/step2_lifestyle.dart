import 'package:flutter/material.dart';
import '../../../services/user/user_service.dart';
import '../../../models/user.dart' as app_user;

class Step2Lifestyle extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const Step2Lifestyle({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<Step2Lifestyle> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<Step2Lifestyle> {
  String selectedLifestyle = "";
  final UserService _userService = UserService();
  app_user.User? _tempUser;

  final Map<String, String> lifestyleMapping = {
    "Student": "sedentary",
    "Employed part-time": "lightly_active", 
    "Employed full-time": "moderately_active",
    "Not employed": "sedentary",
    "Retired": "lightly_active",
  };

  final List<String> options = [
    "Student",
    "Employed part-time", 
    "Employed full-time",
    "Not employed",
    "Retired",
  ];

  bool get isLifestyleSelected => selectedLifestyle.isNotEmpty;

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
        // Tìm lifestyle option phù hợp với giá trị đã lưu
        final savedLifestyle = _tempUser!.lifestyle;
        String? matchingOption;
        
        for (var entry in lifestyleMapping.entries) {
          if (entry.value == savedLifestyle) {
            matchingOption = entry.key;
            break;
          }
        }
        
        setState(() {
          selectedLifestyle = matchingOption ?? "";
        });
      }
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }

  Future<void> _saveTempData() async {
    if (_tempUser == null) return;
    
    // Map UI option to model value
    final lifestyleValue = lifestyleMapping[selectedLifestyle] ?? "moderately_active";
    
    _tempUser = _tempUser!.copyWith(lifestyle: lifestyleValue);
    
    // Backup to local storage
    await _userService.backupToLocal(_tempUser!);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
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
                                  color: isSelected ? Colors.black : Colors.grey[800],
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Colors.orange.shade600,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Nút Back và Next
            Row(
              children: [
                TextButton(
                  onPressed: widget.onBack,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    "Back", 
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const Spacer(),
                if (isLifestyleSelected)
                  ElevatedButton(
                    onPressed: () async {
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
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                    ),
                    child: const Text("Next", style: TextStyle(fontSize: 16)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}