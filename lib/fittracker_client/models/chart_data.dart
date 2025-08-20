// lib/models/chart_data.dart

class ChartData {
  final DateTime date;   // ngày (x-axis)
  final double value;    // giá trị (y-axis)
  final String? label;   // nhãn (vd: "Calories", "Protein", ...)

  ChartData({
    required this.date,
    required this.value,
    this.label,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'label': label,
    };
  }

  /// Convert from JSON
  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      label: json['label'] as String?,
    );
  }
}
