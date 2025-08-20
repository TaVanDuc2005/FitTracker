import 'package:flutter/material.dart';

// Model WaterLog
class WaterLog {
  final String? id;      // ID duy nhất, có thể null khi tạo mới
  final int amount;      // ml
  final DateTime time;   // thời gian uống

  WaterLog({
    this.id,             // bỏ required
    required this.amount,
    required this.time,
  });

  // Chuyển WaterLog sang JSON (để gửi lên server)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,  // chỉ gửi id nếu có
      'amount': amount,
      'time': time.toIso8601String(),
    };
  }

  // Tạo WaterLog từ JSON (nhận từ server)
  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      id: json['id'],
      amount: json['amount'],
      time: DateTime.parse(json['time']),
    );
  }
}

// Demo tạo WaterLog
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tạo WaterLog mẫu (không id)
    WaterLog log = WaterLog(
      amount: 250,
      time: DateTime.now(),
    );

    print('WaterLog ID: ${log.id}'); // sẽ null
    print('Amount: ${log.amount} ml');
    print('Time: ${log.time}');

    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Check console for WaterLog output'),
        ),
      ),
    );
  }
}
