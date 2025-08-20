/// tdee_entry.dart
/// Đại diện cho một bản ghi TDEE (tính toán năng lượng tiêu hao hàng ngày)

class TDEEEntry {
  final String date;       // ISO string: "2025-08-20"
  final double weight;     // cân nặng (kg)
  final double height;     // chiều cao (cm)
  final int age;           // tuổi
  final String gender;     // "male" | "female"
  final double activity;   // hệ số hoạt động (1.2 - 1.9)
  final double tdee;       // TDEE tính ra

  TDEEEntry({
    required this.date,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activity,
    required this.tdee,
  });

  /// Parse từ JSON
  factory TDEEEntry.fromJson(Map<String, dynamic> json) {
    return TDEEEntry(
      date: json['date'] as String,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      age: json['age'] as int,
      gender: json['gender'] as String,
      activity: (json['activity'] as num).toDouble(),
      tdee: (json['tdee'] as num).toDouble(),
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'activity': activity,
      'tdee': tdee,
    };
  }
}
