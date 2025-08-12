import 'package:flutter/material.dart';
import 'package:fittracker_source/Screens/active_screen/journal/journal_screen.dart';
import '../../services/user_service.dart';
import 'Welcome_Screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isProcessing = true;
  Map<String, dynamic>? _userProfile;
  String _processingMessage = 'Analyzing your data...';

  @override
  void initState() {
    super.initState();
    _processUserData();
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

      // Step 1: Load user info
      setState(() {
        _processingMessage = 'Loading your profile...';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      final userInfo = await UserService.getUserInfo();
      if (userInfo == null) {
        print('❌ No user data found - redirecting to setup');

        setState(() {
          _processingMessage = 'Redirecting to setup...';
          _isProcessing = false;
        });

        // Navigate back to welcome screen after 2 seconds
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
        return;
      }

      print('✅ User data found! Processing...');

      // Step 2: Calculate BMI
      setState(() {
        _processingMessage = 'Calculating your BMI...';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      final bmi = await UserService.calculateBMI();

      // Step 3: Calculate daily calories
      setState(() {
        _processingMessage = 'Determining your calorie needs...';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      final dailyCalories = await UserService.calculateDailyCalories();

      // Step 4: Calculate macro targets
      setState(() {
        _processingMessage = 'Creating your macro targets...';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      final macroTargets = await UserService.calculateMacroTargets();

      // Step 5: Finalize
      setState(() {
        _processingMessage = 'Personalizing your program...';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      // Create complete profile
      _userProfile = {
        ...userInfo,
        'bmi': bmi,
        'dailyCalories': dailyCalories,
        'macroTargets': macroTargets,
      };

      // Debug output
      await UserService.printUserInfo();

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

    // Default positions
    double startY = size.height * 0.6;
    double targetY = size.height * 0.4;

    if (userWeight != null && targetWeight != null) {
      print(
        '🎨 Drawing personalized chart: ${userWeight}kg → ${targetWeight}kg',
      );

      // ✅ CẢI THIỆN: Better weight range calculation
      final weightDiff = (userWeight! - targetWeight!).abs();
      final maxDiff = weightDiff < 5
          ? 10.0
          : weightDiff * 1.5; // Minimum visible range

      final centerWeight = (userWeight! + targetWeight!) / 2;
      final minWeight = centerWeight - maxDiff;
      final maxWeight = centerWeight + maxDiff;

      // ✅ CẢI THIỆN: Ensure clear visual difference
      final chartHeight = size.height * 0.5; // Use 50% of chart height
      final chartTop = size.height * 0.25; // Start at 25% from top

      startY =
          chartTop +
          chartHeight *
              (1 - (userWeight! - minWeight) / (maxWeight - minWeight));
      targetY =
          chartTop +
          chartHeight *
              (1 - (targetWeight! - minWeight) / (maxWeight - minWeight));

      // ✅ CẢI THIỆN: Ensure minimum visual difference
      if ((startY - targetY).abs() < 20) {
        if (userWeight! > targetWeight!) {
          startY = size.height * 0.65;
          targetY = size.height * 0.35;
        } else {
          startY = size.height * 0.35;
          targetY = size.height * 0.65;
        }
      }

      print(
        '   📊 Chart positions: startY=${startY.toStringAsFixed(1)}, targetY=${targetY.toStringAsFixed(1)}',
      );
      print('   📊 Weight difference: ${weightDiff.toStringAsFixed(1)}kg');

      // ✅ CẢI THIỆN: Better path calculation
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

      // Generic program (always performs worse)
      final worstY = size.height * 0.8;
      pathGray = Path()
        ..moveTo(0, startY)
        ..quadraticBezierTo(
          size.width * 0.25,
          startY + 20, // Gets slightly worse
          size.width * 0.5,
          startY + 35,
        )
        ..quadraticBezierTo(size.width * 0.75, worstY - 15, size.width, worstY);
    } else {
      // Static fallback
      print('🎨 Drawing static chart (no user data)');

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
    }

    // Draw paths
    canvas.drawPath(pathGray, grayPaint);
    canvas.drawPath(pathGreen, greenPaint);

    // Dynamic labels
    if (userWeight != null && targetWeight != null) {
      // ✅ CẢI THIỆN: Better label positioning
      _drawLabel(
        canvas,
        'Start: ${userWeight!.toStringAsFixed(0)}kg',
        10,
        startY - 25,
        Colors.green,
      );

      _drawLabel(
        canvas,
        'Target: ${targetWeight!.toStringAsFixed(0)}kg',
        size.width - 120,
        targetY - 25,
        Colors.green,
      );

      _drawLabel(
        canvas,
        'Generic program',
        size.width - 110,
        size.height * 0.8 - 30,
        Colors.grey.shade500,
      );
    } else {
      // Static labels
      _drawLabel(canvas, 'Weight', 10, startY - 25, Colors.green);
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
        targetY,
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

    // ✅ CẢI THIỆN: Dynamic width based on text
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
