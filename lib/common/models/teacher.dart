import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';

List<String> _stringListFromSerialized(List? list) =>
    (list ?? []).map<String>((e) => e).toList();

class Teacher extends Person {
  final String schoolId;
  final List<String> groups;

  Teacher({
    super.id,
    required super.firstName,
    super.middleName,
    required super.lastName,
    required this.schoolId,
    required this.groups,
    super.dateBirth,
    super.phone,
    required super.email,
  });

  Teacher.fromSerialized(map)
      : schoolId = map['schoolId'],
        groups = _stringListFromSerialized(map['groups']),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return super.serializedMap()
      ..addAll({
        'schoolId': schoolId,
        'groups': groups,
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
          List<String>? groups,
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
        groups: groups ?? this.groups,
        phone: phone ?? this.phone,
        email: email ?? this.email,
      );
}
