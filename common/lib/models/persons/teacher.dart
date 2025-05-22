import 'package:common/exceptions.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/generic/serializable_elements.dart';
import 'package:common/models/itineraries/itinerary.dart';
import 'package:common/models/persons/person.dart';

class Teacher extends Person {
  final String schoolBoardId;
  final String schoolId;
  final List<String> groups;
  final List<Itinerary> itineraries;

  Teacher({
    super.id,
    required super.firstName,
    required super.middleName,
    required super.lastName,
    required this.schoolBoardId,
    required this.schoolId,
    required this.groups,
    required super.email,
    required super.phone,
    required super.address,
    required super.dateBirth,
    required this.itineraries,
  }) {
    if (dateBirth != null) {
      throw ArgumentError('Date of birth should not be set for a teacher');
    }
  }

  static Teacher get empty => Teacher(
        firstName: '',
        middleName: null,
        lastName: '',
        schoolBoardId: '-1',
        schoolId: '-1',
        groups: [],
        email: null,
        phone: null,
        address: null,
        dateBirth: null,
        itineraries: [],
      );

  Teacher.fromSerialized(super.map)
      : schoolBoardId = StringExt.from(map['school_board_id']) ?? '-1',
        schoolId = StringExt.from(map['school_id']) ?? '-1',
        groups = ListExt.from(map['groups'],
                deserializer: (e) => StringExt.from(e) ?? '-1') ??
            [],
        itineraries = ListExt.from(map['itineraries'],
                deserializer: Itinerary.fromSerialized) ??
            [],
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => super.serializedMap()
    ..addAll({
      'school_board_id': schoolBoardId.serialize(),
      'school_id': schoolId.serialize(),
      'groups': groups.serialize(),
      'itineraries': itineraries.serialize(),
    });

  @override
  Teacher copyWith({
    String? id,
    String? firstName,
    String? middleName,
    String? lastName,
    String? schoolBoardId,
    String? schoolId,
    List<String>? groups,
    String? email,
    PhoneNumber? phone,
    Address? address,
    DateTime? dateBirth,
    List<Itinerary>? itineraries,
  }) =>
      Teacher(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        lastName: lastName ?? this.lastName,
        schoolBoardId: schoolBoardId ?? this.schoolBoardId,
        schoolId: schoolId ?? this.schoolId,
        groups: groups ?? this.groups,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        dateBirth: dateBirth ?? this.dateBirth,
        address: address ?? this.address,
        itineraries: itineraries ?? this.itineraries,
      );

  @override
  Teacher copyWithData(Map<String, dynamic> data) {
    // Make sure data does not contain unrecognized fields
    if (data.keys.any((key) => ![
          'id',
          'first_name',
          'middle_name',
          'last_name',
          'school_board_id',
          'school_id',
          'groups',
          'phone',
          'email',
          'date_birth',
          'address',
          'itineraries',
        ].contains(key))) {
      throw InvalidFieldException('Invalid field data detected');
    }
    return Teacher(
      id: StringExt.from(data['id']) ?? id,
      firstName: StringExt.from(data['first_name']) ?? firstName,
      middleName: StringExt.from(data['middle_name']) ?? middleName,
      lastName: StringExt.from(data['last_name']) ?? lastName,
      schoolBoardId: StringExt.from(data['school_board_id']) ?? schoolBoardId,
      schoolId: StringExt.from(data['school_id']) ?? schoolId,
      groups: ListExt.from(data['groups'],
              deserializer: (e) => StringExt.from(e) ?? '-1') ??
          groups,
      phone: PhoneNumber.from(data['phone']) ?? phone,
      email: StringExt.from(data['email']) ?? email,
      dateBirth: null,
      address: Address.from(data['address']) ?? address,
      itineraries: ListExt.from(data['itineraries'],
              deserializer: Itinerary.fromSerialized) ??
          itineraries,
    );
  }

  @override
  String toString() {
    return 'Teacher{${super.toString()}, schoolId: $schoolId, groups: $groups}';
  }
}
