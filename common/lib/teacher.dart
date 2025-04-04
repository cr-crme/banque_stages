class Teacher {
  String name;
  int age;

  Teacher({required this.name, required this.age});

  Teacher copyWith({
    String? name,
    int? age,
  }) {
    return Teacher(
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }

  Map<String, dynamic> serialize() {
    return {
      'name': name,
      'age': age,
    };
  }

  void mergeDeserialized(Map<String, dynamic> data) {
    if (data['name'] != null) {
      name = data['name'];
    }
    if (data['age'] != null) {
      age = data['age'];
    }
  }

  static Teacher deserialize(Map<String, dynamic> data) {
    return Teacher(
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'Teacher{name: $name, age: $age}';
  }
}
