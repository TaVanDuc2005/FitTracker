class BmiEntry {
  final int id;
  final double height;
  final double weight;
  final double bmi;
  final DateTime date;

  BmiEntry({
    required this.id,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.date,
  });

  factory BmiEntry.fromJson(Map<String, dynamic> json) {
    return BmiEntry(
      id: json['id'],
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'date': date.toIso8601String(),
    };
  }
}
