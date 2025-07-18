import 'package:common/models/school_boards/school_board.dart';
import 'package:common_flutter/providers/school_boards_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/program_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import '../utils.dart';

void _initializeTeacher(BuildContext context) {
  SchoolBoardsProvider.of(context, listen: false).add(SchoolBoard(
    id: 'SchoolBoardId',
    name: 'Test SchoolBoard',
    logo: null,
    schools: [dummySchool(id: 'SchoolId')],
    cnesstNumber: '1234567890',
  ));

  final teachers = TeachersProvider.of(context, listen: false);
  teachers.add(dummyTeacher(
      id: 'MockedTeacherId',
      schoolBoardId: 'SchoolBoardId',
      schoolId: 'SchoolId'));
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
      _initializeTeacher(context);

      final schoolBoards =
          SchoolBoardsProvider.of(context, listen: false).mySchoolBoard;
      expect(schoolBoards, isNotNull);
    });

    testWidgets('can get "mySchoolOf" context without listen', (tester) async {
      final context = await tester.contextWithNotifiers(
          withSchools: true, withTeachers: true);
      _initializeTeacher(context);

      final school = SchoolBoardsProvider.of(context, listen: false).mySchool;
      expect(school, isNotNull);
    });
  });
}
