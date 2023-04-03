import '/common/models/address.dart';
import '/common/models/person.dart';
import '/common/models/phone_number.dart';

class Teacher extends Person {
  final String schoolId;

  Teacher({
    super.id,
    required super.firstName,
    super.middleName,
    required super.lastName,
    required this.schoolId,
    super.dateBirth,
    super.phone,
    required super.email,
  });

  Teacher.fromSerialized(map)
      : schoolId = map['schoolId'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return super.serializedMap()
      ..addAll({
        'schoolId': schoolId,
      });
  }

  @override
  Teacher copyWith(
          {String? id,
          String? firstName,
          String? middleName,
          String? lastName,
          DateTime? dateBirth,
          String? schoolId,
          String? email,
          PhoneNumber? phone,
          Address? address}) =>
      Teacher(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        lastName: lastName ?? this.lastName,
        dateBirth: dateBirth ?? this.dateBirth,
        schoolId: schoolId ?? this.schoolId,
        phone: phone ?? this.phone,
        email: email ?? this.email,
      );
}
