import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:crcrme_banque_stages/common/providers/school_boards_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../../utils.dart';

void _initializeTeachersProvider(BuildContext context) {
  final teachers = TeachersProvider.of(context, listen: false);

  final baseId = 'my_temporary_id';
  var uuid = Uuid();
  final namespace = UuidValue.fromNamespace(Namespace.dns);
  final teacherId = uuid.v5(namespace.toString(), baseId);

  teachers.add(Teacher(
    id: teacherId,
    firstName: 'Mocked',
    middleName: null,
    lastName: 'Teacher',
    address: Address.empty,
    dateBirth: null,
    phone: PhoneNumber.empty,
    schoolBoardId: 'SchoolBoardId',
    schoolId: 'SchoolId',
    email: 'mocked.teacher@my_school.qc',
    groups: [],
    itineraries: [],
  ));

  TeachersProvider.of(context, listen: false).currentTeacherId = baseId;
}

void main() {
  group('SchoolsProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    ProgramInitializer.initialize(mockMe: true);

    test('deserializeItem works', () {
      final schoolBoards =
          SchoolBoardsProvider(uri: Uri.parse('ws://localhost'), mockMe: true);
      final schoolBoard = schoolBoards.deserializeItem({'name': 'Test School'});
      expect(schoolBoard.name, 'Test School');
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withSchools: true);
      final schoolBoards = SchoolBoardsProvider.of(context, listen: false);
      expect(schoolBoards, isNotNull);
    });

    testWidgets('can get "mySchoolBoardOf"', (tester) async {
      final context = await tester.contextWithNotifiers(
          withSchools: true, withTeachers: true);
      _initializeTeachersProvider(context);
      SchoolBoardsProvider.of(context, listen: false).add(SchoolBoard(
          id: 'SchoolBoardId', name: 'Test SchoolBoard', schools: []));

      final schoolBoards =
          await SchoolBoardsProvider.mySchoolBoardOf(context, listen: false);
      expect(schoolBoards, isNotNull);
    });

    testWidgets('can get "mySchoolOf" context without listen', (tester) async {
      final context = await tester.contextWithNotifiers(
          withSchools: true, withTeachers: true);
      _initializeTeachersProvider(context);
      final teacher =
          TeachersProvider.of(context, listen: false).currentTeacher;
      SchoolBoardsProvider.of(context, listen: false).add(SchoolBoard(
          id: 'SchoolBoardId',
          name: 'Test SchoolBoard',
          schools: [
            School(
                id: teacher.schoolId,
                name: 'Test School',
                address: Address.empty)
          ]));

      final school =
          await SchoolBoardsProvider.mySchoolOf(context, listen: false);
      expect(school, isNotNull);
    });
  });
}
