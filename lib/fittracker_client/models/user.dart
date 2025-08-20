// models/user_model.dart

class User {
  String? name;
  String gender;
  int age;
  double height; // cm
  double weight; // kg
  String lifestyle;
  String hasDietaryRestrictions;
  String dietaryRestrictionsList;
  String goal;
  double targetWeight; // kg
  String? profileImageUrl;

  User({
    this.name,
    this.gender = 'male',
    this.age = 25,
    this.height = 170.0,
    this.weight = 70.0,
    this.lifestyle = 'moderately_active',
    this.hasDietaryRestrictions = 'no',
    this.dietaryRestrictionsList = '',
    this.goal = 'maintain_weight',
    this.targetWeight = 70.0,
    this.profileImageUrl,
  });

  // Convert User object to JSON
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
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      gender: json['gender'] ?? 'male',
      age: json['age'] ?? 25,
      height: (json['height'] ?? 170.0).toDouble(),
      weight: (json['weight'] ?? 70.0).toDouble(),
      lifestyle: json['lifestyle'] ?? 'moderately_active',
      hasDietaryRestrictions: json['hasDietaryRestrictions'] ?? 'no',
      dietaryRestrictionsList: json['dietaryRestrictionsList'] ?? '',
      goal: json['goal'] ?? 'maintain_weight',
      targetWeight: (json['targetWeight'] ?? 70.0).toDouble(),
      profileImageUrl: json['profileImageUrl'],
    );
  }

  // Copy with method để update một số field
  User copyWith({
    String? name,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? lifestyle,
    String? hasDietaryRestrictions,
    String? dietaryRestrictionsList,
    String? goal,
    double? targetWeight,
    String? profileImageUrl,
  }) {
    return User(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      lifestyle: lifestyle ?? this.lifestyle,
      hasDietaryRestrictions: hasDietaryRestrictions ?? this.hasDietaryRestrictions,
      dietaryRestrictionsList: dietaryRestrictionsList ?? this.dietaryRestrictionsList,
      goal: goal ?? this.goal,
      targetWeight: targetWeight ?? this.targetWeight,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  String toString() {
    return 'User(name: $name, age: $age, weight: $weight, goal: $goal)';
  }
}