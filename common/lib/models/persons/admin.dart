import 'package:common/exceptions.dart';
import 'package:common/models/generic/access_level.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/generic/serializable_elements.dart';
import 'package:common/models/persons/person.dart';

class Admin extends Person {
  final String authenticationId;
  final String schoolBoardId;
  final AccessLevel accessLevel;

  Admin({
    super.id,
    required this.authenticationId,
    required super.firstName,
    required super.middleName,
    required super.lastName,
    required this.schoolBoardId,
    required super.email,
    required this.accessLevel,
  }) : super(dateBirth: null, phone: null, address: null);

  static Admin get empty => Admin(
        authenticationId: '',
        firstName: '',
        middleName: null,
        lastName: '',
        schoolBoardId: '-1',
        email: null,
        accessLevel: AccessLevel.teacher,
      );

  bool get isEmpty => firstName.isEmpty && lastName.isEmpty;

  Admin.fromSerialized(super.map)
      : authenticationId = StringExt.from(map['authentication_id']) ?? '',
        schoolBoardId = StringExt.from(map['school_board_id']) ?? '-1',
        accessLevel = AccessLevel.fromSerialized(map['access_level']),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => super.serializedMap()
    ..addAll({
      'authentication_id': authenticationId.serialize(),
      'school_board_id': schoolBoardId.serialize(),
      'access_level': accessLevel.serialize(),
    });

  @override
  Admin copyWith({
    String? id,
    String? authenticationId,
    String? firstName,
    String? middleName,
    String? lastName,
    String? schoolBoardId,
    String? email,
    PhoneNumber? phone,
    Address? address,
    DateTime? dateBirth,
    AccessLevel? accessLevel,
  }) =>
      Admin(
        id: id ?? this.id,
        authenticationId: authenticationId ?? this.authenticationId,
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        lastName: lastName ?? this.lastName,
        schoolBoardId: schoolBoardId ?? this.schoolBoardId,
        email: email ?? this.email,
        accessLevel: accessLevel ?? this.accessLevel,
      );

  @override
  Admin copyWithData(Map<String, dynamic> data) {
    // Make sure data does not contain unrecognized fields
    if (data.keys.any((key) => ![
          'id',
          'first_name',
          'middle_name',
          'last_name',
          'school_board_id',
          'email'
              'authentication_id',
          'access_level',
        ].contains(key))) {
      throw InvalidFieldException('Invalid field data detected');
    }
    return Admin(
      id: StringExt.from(data['id']) ?? id,
      authenticationId:
          StringExt.from(data['authentication_id']) ?? authenticationId,
      firstName: StringExt.from(data['first_name']) ?? firstName,
      middleName: StringExt.from(data['middle_name']) ?? middleName,
      lastName: StringExt.from(data['last_name']) ?? lastName,
      schoolBoardId: StringExt.from(data['school_board_id']) ?? schoolBoardId,
      email: StringExt.from(data['email']) ?? email,
      accessLevel: AccessLevel.fromSerialized(data['access_level']),
    );
  }

  @override
  String toString() {
    return 'Teacher{${super.toString()}, schoolBoardId: $schoolBoardId}';
  }
}
