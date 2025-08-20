// lib/fittracker_client/model/weight_history.dart

class WeightHistory {
  final String? id;        // ID, có thể null khi tạo mới
  final double weight;     // cân nặng (kg)
  final DateTime date;     // ngày ghi nhận

  WeightHistory({
    this.id,
    required this.weight,
    required this.date,
  });

  // Chuyển WeightHistory sang JSON để gửi lên server
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'weight': weight,
      'date': date.toIso8601String(),
    };
  }

  // Tạo WeightHistory từ JSON nhận từ server
  factory WeightHistory.fromJson(Map<String, dynamic> json) {
    return WeightHistory(
      id: json['id'],
      weight: (json['weight'] as num).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
}
