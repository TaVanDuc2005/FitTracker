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
      name: map['name'] is String ? map['name'] as String : null,
      gender: map['gender']?.toString() ?? '',
      age: map['age'] is int ? map['age'] as int : int.tryParse(map['age'].toString()) ?? 0,
      height: map['height'] is double
          ? map['height'] as double
          : double.tryParse(map['height'].toString()) ?? 0.0,
      weight: map['weight'] is double
          ? map['weight'] as double
          : double.tryParse(map['weight'].toString()) ?? 0.0,
      lifestyle: map['lifestyle']?.toString() ?? '',
      hasDietaryRestrictions: map['hasDietaryRestrictions']?.toString() ?? 'No',
      dietaryRestrictionsList: map['dietaryRestrictionsList']?.toString() ?? '',
      goal: map['goal']?.toString() ?? '',
      targetWeight: map['targetWeight'] is double
          ? map['targetWeight'] as double
          : double.tryParse(map['targetWeight'].toString()) ?? 0.0,
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
