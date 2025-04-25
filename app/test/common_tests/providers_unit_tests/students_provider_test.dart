import 'package:crcrme_banque_stages/common/models/internship_extension.dart';
import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import '../utils.dart';

void main() {
  group('StudentsProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    testWidgets('"studentsInMyGroups" works', (tester) async {
      // Prepare the StudentsProvider
      final context = await tester.contextWithNotifiers(
          withStudents: true, withTeachers: true);
      final auth = AuthProvider(mockMe: true);
      final teachers = TeachersProvider.of(context, listen: false);
      teachers.initializeAuth(auth);
      teachers.add(dummyTeacher(id: auth.currentUser!.uid));
      final students = StudentsProvider.instance(context, listen: false);
      students.initializeAuth(auth);

      // Add random students (my groups are 101 and 102)
      students.add(dummyStudent(group: '101'));
      students.add(dummyStudent(group: '101'));
      students.add(dummyStudent(group: '102'));
      students.add(dummyStudent(group: '103'));

      expect(StudentsProvider.studentsInMyGroups(context, listen: false).length,
          3);
    });

    testWidgets('"mySupervizedStudents" works', (tester) async {
      // Prepare the StudentsProvider
      final context = await tester.contextWithNotifiers(
          withStudents: true, withTeachers: true, withInternships: true);
      final auth = AuthProvider(mockMe: true);
      final teachers = TeachersProvider.of(context, listen: false);
      teachers.initializeAuth(auth);
      teachers.add(dummyTeacher(id: auth.currentUser!.uid));
      final students = StudentsProvider.instance(context, listen: false);
      students.initializeAuth(auth);

      students.add(dummyStudent(id: 'myStudent1', group: '101'));
      students.add(dummyStudent(id: 'myStudent2', group: '101'));
      students.add(dummyStudent(id: 'myStudent3', group: '102'));
      students.add(dummyStudent(id: 'notYetMyStudent', group: '101'));
      students.add(dummyStudent(id: 'neverMyStudent1', group: '102'));
      students.add(dummyStudent(id: 'neverMyStudent2', group: '103'));

      expect(
          StudentsProvider.mySupervizedStudents(context, listen: false).length,
          0);

      // Add internship to all of the students
      final internships = InternshipsProvider.of(context, listen: false);
      final teacherId = TeachersProvider.of(context).currentTeacherId;
      for (int i = 0; i < students.length; i++) {
        final student = students[i];
        internships.add(dummyInternship(
            studentId: student.id,
            teacherId: i >= 3 ? 'anotherTeacherId' : teacherId));
      }
      expect(
          StudentsProvider.mySupervizedStudents(context, listen: false).length,
          3);

      // Add the fourth student to the supervising list of the teacher
      internships
          .firstWhere((e) => e.studentId == 'notYetMyStudent')
          .addSupervisingTeacher(context,
              teacherId: TeachersProvider.of(context).currentTeacherId);
      expect(
          StudentsProvider.mySupervizedStudents(context, listen: false).length,
          4);

      // Terminate one of the internships
      final internship = internships
          .firstWhere((e) => e.studentId == 'myStudent1')
          .copyWith(endDate: DateTime(0));
      internships.replace(internship);
      expect(
          StudentsProvider.mySupervizedStudents(context,
                  listen: false, activeOnly: false)
              .length,
          4);
      expect(
          StudentsProvider.mySupervizedStudents(context,
                  listen: false, activeOnly: true)
              .length,
          3);

      // Try to add a student that is not on the right group
      expect(
          () => internships
              .firstWhere((e) => e.studentId == 'neverMyStudent2')
              .addSupervisingTeacher(context,
                  teacherId: TeachersProvider.of(context).currentTeacherId),
          throwsException);
      expect(
          StudentsProvider.mySupervizedStudents(context, listen: false).length,
          4);
    });

    test('deserializeItem works', () {
      final students =
          StudentsProvider(uri: Uri.parse('ws://localhost'), mockMe: true);
      final student = students.deserializeItem({
        'firstName': 'NotPierre',
        'middleName': 'NotJean',
        'lastName': 'NotJacques',
        'group': '10101',
      });

      expect(student.firstName, 'NotPierre');
      expect(student.middleName, 'NotJean');
      expect(student.lastName, 'NotJacques');
      expect(student.group, '10101');
    });
  });
}
