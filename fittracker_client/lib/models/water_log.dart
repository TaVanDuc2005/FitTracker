import 'package:uuid/uuid.dart';

class WaterLog {
  final String id;        // ID duy nhất cho mỗi lượt uống
  final int amount;       // Lượng nước uống (ml)
  final DateTime time;    // Thời gian uống

  WaterLog({
    required this.id,
    required this.amount,
    required this.time,
  });

  // Tạo một log mới với id tự động
  factory WaterLog.create({required int amount, DateTime? time}) {
    return WaterLog(
      id: const Uuid().v4(),
      amount: amount,
      time: time ?? DateTime.now(),
    );
  }

  // Dùng khi lấy từ SQLite
  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      id: map['id'],
      amount: map['amount'],
      time: DateTime.parse(map['time']),
    );
  }

  // Dùng khi lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'time': time.toIso8601String(),
    };
  }

  // Lấy ngày (YYYY-MM-DD) để gom nhóm theo ngày
  String get dateKey => '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
}
