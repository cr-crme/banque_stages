import '/common/models/person.dart';

class Teacher extends Person {
  Teacher({
    super.id,
    required super.firstName,
    super.middleName,
    required super.lastName,
    super.dateBirth,
    super.phone,
    required super.email,
    super.address,
  });

  Teacher.fromSerialized(map) : super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return super.serializedMap()..addAll({});
  }

  @override
  Teacher copyWith({
    String? id,
    String? firstName,
    String? middleName,
    String? lastName,
    DateTime? dateBirth,
    String? email,
    String? phone,
    String? address,
  }) =>
      Teacher(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        lastName: lastName ?? this.lastName,
        dateBirth: dateBirth ?? this.dateBirth,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
      );
}
