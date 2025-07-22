import 'package:flutter/material.dart';
import 'package:fittracker_source/Screens/active_screen/journal/journal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FoodvisorIntro(),
    );
  }
}

class FoodvisorIntro extends StatelessWidget {
  const FoodvisorIntro({super.key});

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
                  child: CustomPaint(painter: _ChartPainter()),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Foodvisor finds what works for you to reach your personal goals.',
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
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JournalScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Next', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
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

    final pathGreen = Path()
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

    final pathGray = Path()
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

    // Draw both paths
    canvas.drawPath(pathGray, grayPaint);
    canvas.drawPath(pathGreen, greenPaint);

    // Draw tags (labels)
    final textPainter1 = TextPainter(
      text: const TextSpan(
        text: 'Weight',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textPainter2 = TextPainter(
      text: const TextSpan(
        text: 'Generic program',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textPainter3 = TextPainter(
      text: const TextSpan(
        text: 'Your Foodvisor program',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Draw background rectangles for tags
    final weightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, size.height * 0.6 - 25, 60, 20),
      const Radius.circular(10),
    );
    canvas.drawRRect(weightRect, Paint()..color = Colors.green);
    textPainter1.paint(canvas, Offset(15, size.height * 0.6 - 23));

    final genericRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 110, size.height * 0.95 - 30, 100, 20),
      const Radius.circular(10),
    );
    canvas.drawRRect(genericRect, Paint()..color = Colors.grey.shade500);
    textPainter2.paint(
      canvas,
      Offset(size.width - 105, size.height * 0.95 - 28),
    );

    final foodvisorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 160, size.height * 0.4, 140, 20),
      const Radius.circular(10),
    );
    canvas.drawRRect(foodvisorRect, Paint()..color = Colors.green);
    textPainter3.paint(canvas, Offset(size.width - 155, size.height * 0.4 + 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
