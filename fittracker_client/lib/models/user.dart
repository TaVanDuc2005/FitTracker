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

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      height: map['height']?.toDouble() ?? 0,
      weight: map['weight']?.toDouble() ?? 0,
      lifestyle: map['lifestyle'] ?? '',
      hasDietaryRestrictions: map['hasDietaryRestrictions'] ?? 'No',
      dietaryRestrictionsList: map['dietaryRestrictionsList'] ?? '',
      goal: map['goal'] ?? '',
      targetWeight: map['targetWeight']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
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
