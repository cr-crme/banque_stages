import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('Teacher', () {
    test('"copyWith" changes the requested elements', () {
      final teacher = dummyTeacher();

      final teacherSame = teacher.copyWith();
      expect(teacherSame.id, teacher.id);
      expect(teacherSame.firstName, teacher.firstName);
      expect(teacherSame.middleName, teacher.middleName);
      expect(teacherSame.lastName, teacher.lastName);
      expect(teacherSame.schoolId, teacher.schoolId);
      expect(teacherSame.groups, teacher.groups);
      expect(teacherSame.email, teacher.email);
      expect(teacherSame.phone, teacher.phone);

      expect(teacherSame.address, isNull);
      expect(teacherSame.dateBirth, isNull);

      final teacherDifferent = teacher.copyWith(
        id: 'newId',
        firstName: 'newFirstName',
        middleName: 'newMiddleName',
        lastName: 'newLastName',
        schoolId: 'newSchoolId',
        groups: ['newGroup'],
        email: 'newEmail',
        phone: PhoneNumber.fromString('866-666-6666'),
      );

      expect(teacherDifferent.id, 'newId');
      expect(teacherDifferent.firstName, 'newFirstName');
      expect(teacherDifferent.middleName, 'newMiddleName');
      expect(teacherDifferent.lastName, 'newLastName');
      expect(teacherDifferent.schoolId, 'newSchoolId');
      expect(teacherDifferent.groups, ['newGroup']);
      expect(teacherDifferent.email, 'newEmail');
      expect(teacherDifferent.phone.toString(), '(866) 666-6666');

      // Expect throw on changes
      expect(
          () => teacher.copyWith(address: dummyAddress()), throwsArgumentError);
      expect(
          () => teacher.copyWith(dateBirth: DateTime(0)), throwsArgumentError);
    });

    test('serialization and deserialization works', () {
      final teacher = dummyTeacher();
      final serialized = teacher.serialize();
      final deserialized = Teacher.fromSerialized(serialized);

      expect(serialized, {
        'id': teacher.id,
        'school_board_id': teacher.schoolBoardId,
        'school_id': teacher.schoolId,
        'first_name': teacher.firstName,
        'middle_name': teacher.middleName,
        'last_name': teacher.lastName,
        'groups': teacher.groups,
        'email': teacher.email,
        'phone': teacher.phone?.serialize(),
        'date_birth': null,
        'address': teacher.address?.serialize(),
        'itineraries': [],
      });

      expect(deserialized.id, teacher.id);
      expect(deserialized.schoolBoardId, teacher.schoolBoardId);
      expect(deserialized.schoolId, teacher.schoolId);
      expect(deserialized.firstName, teacher.firstName);
      expect(deserialized.middleName, teacher.middleName);
      expect(deserialized.lastName, teacher.lastName);
      expect(deserialized.groups, teacher.groups);
      expect(deserialized.email, teacher.email);
      expect(deserialized.phone?.toString(), dummyPhoneNumber().toString());
      expect(deserialized.dateBirth, isNull);
      expect(deserialized.address, isNull);
      expect(deserialized.itineraries, []);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Teacher.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.schoolBoardId, '-1');
      expect(emptyDeserialized.firstName, 'Unnamed');
      expect(emptyDeserialized.middleName, isNull);
      expect(emptyDeserialized.lastName, 'Unnamed');
      expect(emptyDeserialized.schoolId, '-1');
      expect(emptyDeserialized.groups, []);
      expect(emptyDeserialized.email, isNull);
      expect(emptyDeserialized.phone, isNull);
      expect(emptyDeserialized.dateBirth, isNull);
      expect(emptyDeserialized.address, isNull);
      expect(emptyDeserialized.itineraries, []);
    });
  });
}
