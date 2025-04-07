import 'package:common/exceptions.dart';
import 'package:uuid/uuid.dart';

String get _id => Uuid().v1().toString();

class Teacher {
  final String id;
  final String name;
  final int age;

  Teacher({String? id, required this.name, required this.age}) : id = id ?? _id;
  Teacher.zero()
      : id = _id,
        name = '',
        age = 0;

  Teacher copyWith({
    String? name,
    int? age,
  }) {
    return Teacher(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }

  Map<String, dynamic> serialize() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  Teacher copyWithData(Map<String, dynamic> data) {
    // Make sure data does not contain unrecognized fields
    if (data.keys.any((key) => !['id', 'name', 'age'].contains(key))) {
      throw InvalidFieldException('Invalid field data detected');
    }

    return Teacher(
      id: data['id']?.toString() ?? id,
      name: data['name'] ?? name,
      age: data['age'] ?? age,
    );
  }

  static Teacher deserialize(Map<String, dynamic> data) =>
      Teacher.zero().copyWithData(data);

  @override
  String toString() {
    return 'Teacher{name: $name, age: $age}';
  }
}
