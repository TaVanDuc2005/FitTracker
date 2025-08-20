class BmrEntry {
  final int id;
  final double bmr;
  final DateTime date;

  BmrEntry({
    required this.id,
    required this.bmr,
    required this.date,
  });

  factory BmrEntry.fromJson(Map<String, dynamic> json) {
    return BmrEntry(
      id: json['id'],
      bmr: (json['bmr'] as num).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bmr': bmr,
      'date': date.toIso8601String(),
    };
  }
}
