import 'package:flutter/material.dart';
import 'package:fittracker_source/Screens/active_screen/journal/journal_screen.dart';
import '../../services/user_service.dart';
import 'Welcome_Screen.dart';
import '../../services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isProcessing = true;
  Map<String, dynamic>? _userProfile;
  String? _uid;
  String _processingMessage = 'Analyzing your data...';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_uid == null) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      _uid = args?['userid']; // 🔹 Lấy uid từ arguments
      _syncUserData();
      _processUserData();
    }
  }

  Future<void> _syncUserData() async {
    // Lấy uid từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('userid');
    if (uid == null || uid.isEmpty) {
      _isProcessing = false;
      _processingMessage = 'Error: No UID found.';
      return;
    }

    // Lấy các field đã lưu từ SharedPreferences
    final username = await UserService.getName();
    final gender = await UserService.getGender();
    final age = await UserService.getAge();
    final height = await UserService.getHeight();
    final weight = await UserService.getWeight();
    final lifestyle = await UserService.getLifestyle();
    final hasDietaryRestrictions =
        await UserService.getHasDietaryRestrictions();
    String? dietaryRestrictionsList;
    if (hasDietaryRestrictions != null && hasDietaryRestrictions == 'Yes') {
      dietaryRestrictionsList = await UserService.getDietaryRestrictionsList();
    }
    final goal = await UserService.getGoal();
    final targetWeight = await UserService.getTargetWeight();

    // Map dữ liệu chỉ lưu field nào khác null
    final Map<String, dynamic> dataToUpdate = {};
    if (username != null && username.isNotEmpty)
      dataToUpdate['name'] = username;
    if (gender != null && gender.isNotEmpty) dataToUpdate['gender'] = gender;
    if (age != null) dataToUpdate['age'] = age;
    if (height != null) dataToUpdate['height'] = height;
    if (weight != null) dataToUpdate['weight'] = weight;
    if (lifestyle != null && lifestyle.isNotEmpty)
      dataToUpdate['lifestyle'] = lifestyle;
    if (hasDietaryRestrictions != null)
      dataToUpdate['hasDietaryRestrictions'] = hasDietaryRestrictions;
    if (dietaryRestrictionsList != null && dietaryRestrictionsList.isNotEmpty)
      dataToUpdate['dietaryRestrictionsList'] = dietaryRestrictionsList;
    if (goal != null && goal.isNotEmpty) dataToUpdate['healthGoal'] = goal;
    if (targetWeight != null) dataToUpdate['targetWeight'] = targetWeight;

    // Nếu có dữ liệu thì chỉ update vào document uid (KHÔNG tạo uid mới)
    if (dataToUpdate.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid) // dùng đúng uid làm document ID
          .set(
            dataToUpdate,
            SetOptions(merge: true),
          ); // chỉ cập nhật các field có dữ liệu
      // Đánh dấu setup đã hoàn thành trên Firebase
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isSetupComplete': true,
      });
    }

    // XÓA HẾT DỮ LIỆU LOCAL
    await UserService.clearUserInfo();

    setState(() {});
  }

  // THÊM: Debug method để kiểm tra từng field
  Future<void> _debugUserData() async {
    print('\n🔍 DEBUG: Checking individual fields...');

    final name = await UserService.getName();
    final gender = await UserService.getGender();
    final age = await UserService.getAge();
    final height = await UserService.getHeight();
    final weight = await UserService.getWeight();
    final lifestyle = await UserService.getLifestyle();
    final hasDietaryRestrictions =
        await UserService.getHasDietaryRestrictions();
    final dietaryRestrictionsList =
        await UserService.getDietaryRestrictionsList();
    final goal = await UserService.getGoal();
    final targetWeight = await UserService.getTargetWeight();
    final isSetupComplete = await UserService.isSetupComplete();

    print('   👤 Name: $name');
    print('   🚻 Gender: $gender');
    print('   🎂 Age: $age');
    print('   📏 Height: $height');
    print('   ⚖️ Weight: $weight');
    print('   🏃 Lifestyle: $lifestyle');
    print('   🍎 Has Dietary Restrictions: $hasDietaryRestrictions');
    print('   📝 Dietary Restrictions List: $dietaryRestrictionsList');
    print('   🎯 Goal: $goal');
    print('   🎯 Target Weight: $targetWeight');
    print('   ✅ Setup Complete: $isSetupComplete');
    print('═══════════════════════════════\n');

    // THÊM: Nếu thiếu data, tự động complete setup
    if (!isSetupComplete &&
        gender != null &&
        age != null &&
        height != null &&
        weight != null &&
        lifestyle != null &&
        goal != null) {
      print('🔧 Auto-completing setup with available data...');

      final success = await UserService.saveUserInfo(
        name: name,
        gender: gender,
        age: age,
        height: height,
        weight: weight,
        lifestyle: lifestyle,
        hasDietaryRestrictions: hasDietaryRestrictions ?? 'No',
        dietaryRestrictionsList: dietaryRestrictionsList ?? 'None',
        goal: goal,
        targetWeight: targetWeight ?? weight, // Fallback to current weight
      );

      if (success) {
        print('✅ Setup completed automatically!');
      }
    }
  }

  Future<void> _processUserData() async {
    try {
      // Step 0: Debug check
      await _debugUserData();

      // Step 1: Load user info từ Firebase (KHÔNG dùng local nữa)
      setState(() {
        _processingMessage = 'Loading your profile...';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      // Lấy uid từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userid');
      if (uid == null || uid.isEmpty) {
        setState(() {
          _processingMessage = 'Error: No UID found.';
          _isProcessing = false;
        });
        return;
      }

      // Lấy dữ liệu user từ Firebase
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!doc.exists) {
        print('❌ No user data found on Firebase - redirecting to setup');
        setState(() {
          _processingMessage = 'Redirecting to setup...';
          _isProcessing = false;
        });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
        return;
      }

      final userInfo = doc.data();
      print('✅ User data found on Firebase! Processing...');

      // Step 2: Calculate BMI
      setState(() {
        _processingMessage = 'Calculating your BMI...';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      final height = (userInfo?['height'] as num?)?.toDouble();
      final weight = (userInfo?['weight'] as num?)?.toDouble();
      double? bmi;
      if (height != null && weight != null && height > 0) {
        bmi = weight / ((height / 100) * (height / 100));
      }

      // Step 3: Calculate daily calories
      setState(() {
        _processingMessage = 'Determining your calorie needs...';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      int? dailyCalories;
      {
        final gender = userInfo?['gender']?.toString().toLowerCase();
        final age = (userInfo?['age'] as num?)?.toInt();
        final lifestyle = userInfo?['lifestyle']?.toString().toLowerCase();
        if (gender != null && age != null && height != null && weight != null) {
          double bmr;
          if (gender == 'male') {
            bmr = 10 * weight + 6.25 * height - 5 * age + 5;
          } else {
            bmr = 10 * weight + 6.25 * height - 5 * age - 161;
          }
          double activityFactor;
          switch (lifestyle) {
            case 'student':
            case 'not employed':
            case 'retired':
              activityFactor = 1.2;
              break;
            case 'employed part-time':
              activityFactor = 1.375;
              break;
            case 'employed full-time':
              activityFactor = 1.55;
              break;
            default:
              activityFactor = 1.2;
          }
          dailyCalories = (bmr * activityFactor).round();
        }
      }

      // Step 4: Calculate macro targets
      setState(() {
        _processingMessage = 'Creating your macro targets...';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      Map<String, int>? macroTargets;
      if (dailyCalories != null) {
        macroTargets = {
          'calories': dailyCalories,
          'protein': (dailyCalories * 0.15 / 4).round(),
          'fat': (dailyCalories * 0.25 / 9).round(),
          'carbs': (dailyCalories * 0.60 / 4).round(),
          'fiber': 25,
        };
      }

      // Step 5: Finalize
      setState(() {
        _processingMessage = 'Personalizing your program...';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      // Create complete profile
      _userProfile = {
        ...?userInfo,
        'bmi': bmi,
        'dailyCalories': dailyCalories,
        'macroTargets': macroTargets,
      };

      print('✅ Loading Screen: User data processed successfully!');
      print('   📊 BMI: ${bmi?.toStringAsFixed(1)}');
      print('   🔥 Daily Calories: $dailyCalories');
      print('   🎯 Protein: ${macroTargets?['protein']}g');

      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      print('❌ Error processing user data: $e');
      setState(() {
        _isProcessing = false;
        _processingMessage = 'Error processing data - Please restart setup';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F5F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                // Processing indicator
                if (_isProcessing)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _processingMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Error state - THÊM
                if (!_isProcessing &&
                    _userProfile == null &&
                    _processingMessage.contains('Error'))
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error, size: 48, color: Colors.red.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _processingMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WelcomeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Restart Setup',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                // User summary (after processing) - GIỮ NGUYÊN CODE CŨ
                if (!_isProcessing && _userProfile != null)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Hello ${_userProfile!['name'] ?? 'there'}! 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your personalized nutrition plan is ready',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stats grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              'BMI',
                              '${_userProfile!['bmi']?.toStringAsFixed(1) ?? 'N/A'}',
                              '📊',
                              Colors.blue.shade100,
                            ),
                            _buildStatCard(
                              'Daily Calories',
                              '${_userProfile!['dailyCalories'] ?? 'N/A'}',
                              '🔥',
                              Colors.orange.shade100,
                            ),
                            _buildStatCard(
                              'Protein Target',
                              '${_userProfile!['macroTargets']?['protein'] ?? 'N/A'}g',
                              '💪',
                              Colors.green.shade100,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // Rest of UI - GIỮ NGUYÊN CODE CŨ
                const Text(
                  'There is no 1-size-fits-all diet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomPaint(
                    painter: _ChartPainter(
                      userWeight: _userProfile?['weight']?.toDouble(),
                      targetWeight: _userProfile?['targetWeight']?.toDouble(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'FitTracker finds what works for you to reach your personal goals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),

                const SizedBox(height: 40),

                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F5F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'Assets/Images/imagePage9.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: (_isProcessing || _userProfile == null)
                      ? null
                      : () {
                          print(
                            '🚀 Navigating to main app with processed data',
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const JournalScreen(),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isProcessing ? Colors.grey : Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Start Your Journey',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String icon,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

// GIỮ NGUYÊN _ChartPainter CLASS
class _ChartPainter extends CustomPainter {
  final double? userWeight;
  final double? targetWeight;

  _ChartPainter({this.userWeight, this.targetWeight});

  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final grayPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    Path pathGreen;
    Path pathGray;

    // Nếu có dữ liệu cân nặng
    if (userWeight != null && targetWeight != null) {
      // Tính vị trí Y cho cân nặng bắt đầu và cân nặng mục tiêu
      final minWeight = (userWeight! < targetWeight!)
          ? userWeight!
          : targetWeight!;
      final maxWeight = (userWeight! > targetWeight!)
          ? userWeight!
          : targetWeight!;
      final chartHeight = size.height * 0.5;
      final chartTop = size.height * 0.25;

      // Tính tỷ lệ vị trí
      double startY =
          chartTop +
          chartHeight *
              (1 - (userWeight! - minWeight) / (maxWeight - minWeight + 1));
      double targetY =
          chartTop +
          chartHeight *
              (1 - (targetWeight! - minWeight) / (maxWeight - minWeight + 1));

      // Đảm bảo khoảng cách tối thiểu
      if ((startY - targetY).abs() < 20) {
        if (userWeight! > targetWeight!) {
          startY = size.height * 0.65;
          targetY = size.height * 0.35;
        } else {
          startY = size.height * 0.35;
          targetY = size.height * 0.65;
        }
      }

      // Vẽ đường biểu đồ FitTracker (từ userWeight đến targetWeight)
      pathGreen = Path()
        ..moveTo(0, startY)
        ..quadraticBezierTo(
          size.width * 0.25,
          startY + (targetY - startY) * 0.2,
          size.width * 0.5,
          startY + (targetY - startY) * 0.6,
        )
        ..quadraticBezierTo(
          size.width * 0.75,
          startY + (targetY - startY) * 0.9,
          size.width,
          targetY,
        );

      // Vẽ đường biểu đồ generic (tham khảo)
      final worstY = chartTop + chartHeight * 0.9;
      pathGray = Path()
        ..moveTo(0, startY)
        ..quadraticBezierTo(
          size.width * 0.25,
          startY + 20,
          size.width * 0.5,
          startY + 35,
        )
        ..quadraticBezierTo(size.width * 0.75, worstY - 15, size.width, worstY);

      // Vẽ đường
      canvas.drawPath(pathGray, grayPaint);
      canvas.drawPath(pathGreen, greenPaint);

      double labelOffset = 25;

      // Nếu đường xanh hướng từ trên xuống
      if (startY < targetY) {
        // Start ở dưới trái, Target ở trên phải
        _drawLabel(
          canvas,
          'Start: ${userWeight!.toStringAsFixed(0)}kg',
          10,
          startY + labelOffset,
          Colors.green,
        );
        _drawLabel(
          canvas,
          'Target: ${targetWeight!.toStringAsFixed(0)}kg',
          size.width - 120,
          targetY - labelOffset,
          Colors.green,
        );
      } else {
        // Start ở trên trái, Target ở dưới phải
        _drawLabel(
          canvas,
          'Start: ${userWeight!.toStringAsFixed(0)}kg',
          10,
          startY - labelOffset,
          Colors.green,
        );
        _drawLabel(
          canvas,
          'Target: ${targetWeight!.toStringAsFixed(0)}kg',
          size.width - 120,
          targetY + labelOffset,
          Colors.green,
        );
      }

      final midX = size.width / 2;
      final t = midX / size.width;
      double grayY;
      if (t < 0.5) {
        grayY = startY + 20 * t * 2;
      } else {
        grayY = startY + 35 + (worstY - (startY + 35)) * (t - 0.5) * 2;
      }
      const labelWidth = 110;
      const labelHeight = 22;

      // Dịch label "Generic program" xuống dưới đường vẽ
      _drawLabel(
        canvas,
        'Generic program',
        midX - labelWidth / 2, // căn giữa ngang
        grayY - labelHeight / 2, // căn giữa dọc
        Colors.grey.shade500,
      );
    } else {
      // Static fallback
      pathGreen = Path()
        ..moveTo(0, size.height * 0.6)
        ..quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.3,
          size.width * 0.5,
          size.height * 0.5,
        )
        ..quadraticBezierTo(
          size.width * 0.75,
          size.height * 0.7,
          size.width,
          size.height * 0.4,
        );

      pathGray = Path()
        ..moveTo(0, size.height * 0.4)
        ..quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.6,
          size.width * 0.5,
          size.height * 0.7,
        )
        ..quadraticBezierTo(
          size.width * 0.75,
          size.height * 0.85,
          size.width,
          size.height * 0.95,
        );

      canvas.drawPath(pathGray, grayPaint);
      canvas.drawPath(pathGreen, greenPaint);

      _drawLabel(canvas, 'Weight', 10, size.height * 0.6 - 25, Colors.green);
      _drawLabel(
        canvas,
        'Generic program',
        size.width - 110,
        size.height * 0.95 - 30,
        Colors.grey.shade500,
      );
      _drawLabel(
        canvas,
        'Your FitTracker program',
        size.width - 160,
        size.height * 0.4,
        Colors.green,
      );
    }
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    double x,
    double y,
    Color bgColor,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, textPainter.width + 12, 22),
      const Radius.circular(11),
    );

    canvas.drawRRect(rect, Paint()..color = bgColor);
    textPainter.paint(canvas, Offset(x + 6, y + 5));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
