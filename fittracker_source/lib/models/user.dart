class User {
  final int id; // Luôn là 1 (chỉ có 1 user)
  final String name;
  final int age;
  final double height;
  final double weight;
  final String gender;
  final String activityLevel;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.activityLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'activityLevel': activityLevel,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
      gender: map['gender'],
      activityLevel: map['activityLevel'],
    );
  }
}
