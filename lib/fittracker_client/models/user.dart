class User {
  String? name;
  String gender;
  int age;
  double height;
  double weight;
  String lifestyle;
  String hasDietaryRestrictions;
  String dietaryRestrictionsList;
  String goal;
  double targetWeight;

  User({
    this.name,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.lifestyle,
    required this.hasDietaryRestrictions,
    required this.dietaryRestrictionsList,
    required this.goal,
    required this.targetWeight,
  });

  /// Parse từ JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      lifestyle: json['lifestyle'] ?? '',
      hasDietaryRestrictions: json['hasDietaryRestrictions'] ?? 'No',
      dietaryRestrictionsList: json['dietaryRestrictionsList'] ?? '',
      goal: json['goal'] ?? '',
      targetWeight: (json['targetWeight'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'lifestyle': lifestyle,
      'hasDietaryRestrictions': hasDietaryRestrictions,
      'dietaryRestrictionsList': dietaryRestrictionsList,
      'goal': goal,
      'targetWeight': targetWeight,
    };
  }
}
