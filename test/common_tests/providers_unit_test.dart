import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/itineraries_provider.dart';
import 'package:crcrme_banque_stages/common/providers/schools_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';
import 'utils.dart';

void main() {
  group('AuthProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('can sign in and out', () {
      final authProvider =
          AuthProvider(mockMe: true, automaticallySignInIfMocked: false);
      expect(authProvider.isSignedIn(), isFalse);

      authProvider.signInWithEmailAndPassword(
          email: 'my.email@test.ca', password: 'no password');
      expect(authProvider.isSignedIn(), isTrue);
      expect(authProvider.currentUser?.uid, 'Mock User');

      authProvider.signOut();
      expect(authProvider.isSignedIn(), isFalse);
      expect(authProvider.currentUser?.uid, isNull);
    });

    testWidgets('can get "of" context', (tester) async {
      final context =
          await tester.contextWithNotifiers(withAuthentication: true);

      final authProvider = AuthProvider.of(context);
      expect(authProvider.isSignedIn(), isTrue);
    });
  });

  group('EnterprisesProvider', () {
    test('"replaceJob" works', () {
      final enterprises = EnterprisesProvider(mockMe: true);
      enterprises.add(Enterprise(
        name: 'Test Enterprise',
        activityTypes: {},
        recrutedBy: 'Nobody',
        shareWith: 'Noone',
        jobs: JobList()..add(dummyJob()),
        contact: Person(firstName: 'Not', middleName: 'A', lastName: 'Person'),
      ));

      final enterprise = enterprises[0];
      expect(enterprise.jobs[0].minimumAge, 12);
      enterprises.replaceJob(
          enterprise, enterprise.jobs[0].copyWith(minimumAge: 2));
      expect(enterprise.jobs[0].minimumAge, 2);
    });

    test('"deserializeItem" works', () {
      final enterprises = EnterprisesProvider(mockMe: true);
      final enterprise =
          enterprises.deserializeItem({'name': 'Test Enterprise'});
      expect(enterprise.name, 'Test Enterprise');
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withEnterprises: true);
      final enterprises = EnterprisesProvider.of(context, listen: false);
      expect(enterprises, isNotNull);
    });
  });

  group('InternshipsProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('"byStudentId" return the right student', () {
      final internships = InternshipsProvider(mockMe: true);
      internships.add(dummyInternship(studentId: '123'));
      internships.add(dummyInternship(studentId: '123'));
      internships.add(dummyInternship(studentId: '456'));

      expect(internships.byStudentId('123').length, 2);
      expect(internships.byStudentId('123')[0].studentId, '123');
      expect(internships.byStudentId('123')[1].studentId, '123');
      expect(internships.byStudentId('456').length, 1);
      expect(internships.byStudentId('456')[0].studentId, '456');
      expect(internships.byStudentId('789').length, 0);
    });

    test('deserializeItem works', () {
      final internships = InternshipsProvider(mockMe: true);
      final internship = internships.deserializeItem({
        'student': '123',
        'enterprise': '456',
        'priority': 0,
      });
      expect(internship.studentId, '123');
      expect(internship.enterpriseId, '456');
      expect(internship.visitingPriority, VisitingPriority.low);
    });

    test('can replace priority', () {
      final internships = InternshipsProvider(mockMe: true);
      internships.add(dummyInternship());

      expect(internships[0].visitingPriority, VisitingPriority.low);
      internships.replacePriority(
          internships[0].studentId, VisitingPriority.high);
      expect(internships[0].visitingPriority, VisitingPriority.high);
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withInternships: true);
      final internships = InternshipsProvider.of(context, listen: false);
      expect(internships, isNotNull);
    });
  });

  group('ItinerariesProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('"add" works', () {
      final itineraries = ItinerariesProvider(mockMe: true);
      itineraries.initializeAuth(AuthProvider(mockMe: true));

      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 1)));
      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 2)));
      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 3)));

      expect(itineraries.length, 3);
      expect(itineraries[0].date, DateTime(2021, 1, 1));
      expect(itineraries[1].date, DateTime(2021, 1, 2));
      expect(itineraries[2].date, DateTime(2021, 1, 3));
    });

    test('"replace" works', () {
      final itineraries = ItinerariesProvider(mockMe: true);
      itineraries.initializeAuth(AuthProvider(mockMe: true));

      itineraries
          .add(dummyItinerary(id: 'itineraryId', date: DateTime(2021, 1, 1)));
      itineraries
          .add(dummyItinerary(id: 'itineraryId2', date: DateTime(2021, 1, 2)));
      itineraries
          .add(dummyItinerary(id: 'itineraryId3', date: DateTime(2021, 1, 3)));

      expect(itineraries.length, 3);
      expect(itineraries[0].length, 2);
      expect(itineraries[1].length, 2);
      expect(itineraries[2].length, 2);

      // This is an indirect call to replace
      itineraries.add(itineraries[0].copyWith(waypoints: []));
      expect(itineraries.length, 3);
      expect(itineraries[0].length, 0);
      expect(itineraries[1].length, 2);
      expect(itineraries[2].length, 2);

      // This is a direct call to replace
      itineraries
          .replace(itineraries[0].copyWith(waypoints: [dummyWaypoint()]));
      expect(itineraries.length, 3);
      expect(itineraries[0].length, 1);
      expect(itineraries[1].length, 2);
      expect(itineraries[2].length, 2);
    });

    test('"hasDate" works', () {
      final itineraries = ItinerariesProvider(mockMe: true);
      itineraries.initializeAuth(AuthProvider(mockMe: true));

      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 1)));
      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 2)));
      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 3)));

      expect(itineraries.hasDate(DateTime(2021, 1, 1)), isTrue);
      expect(itineraries.hasDate(DateTime(2021, 1, 2)), isTrue);
      expect(itineraries.hasDate(DateTime(2021, 1, 3)), isTrue);
      expect(itineraries.hasDate(DateTime(2021, 1, 4)), isFalse);
    });

    test('"fromDate" works', () {
      final itineraries = ItinerariesProvider(mockMe: true);
      itineraries.initializeAuth(AuthProvider(mockMe: true));

      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 1)));
      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 2)));
      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 3)));

      expect(itineraries.fromDate(DateTime(2021, 1, 1)), isNotNull);
      expect(itineraries.fromDate(DateTime(2021, 1, 2)), isNotNull);
      expect(itineraries.fromDate(DateTime(2021, 1, 3)), isNotNull);
      expect(itineraries.fromDate(DateTime(2021, 1, 4)), isNull);
    });

    test('"serialize" works', () {
      final itineraries = ItinerariesProvider(mockMe: true);
      itineraries.initializeAuth(AuthProvider(mockMe: true));

      itineraries
          .add(dummyItinerary(id: 'firstId', date: DateTime(2021, 1, 1)));
      itineraries
          .add(dummyItinerary(id: 'secondId', date: DateTime(2021, 1, 2)));
      itineraries
          .add(dummyItinerary(id: 'thirdId', date: DateTime(2021, 1, 3)));

      final serialized = itineraries.serialize();

      final serializedWaypoints = [
        {
          'id': 'waypointId',
          'title': 'Waypoint',
          'subtitle': 'Subtitle',
          'latitude': 40.0,
          'longitude': 50.0,
          'street': '123 rue de la rue',
          'locality': 'Ville',
          'postalCode': 'H0H 0H0',
          'priority': 3
        },
        {
          'id': 'waypointId2',
          'title': 'Waypoint',
          'subtitle': 'Subtitle',
          'latitude': 30.0,
          'longitude': 30.5,
          'street': '123 rue de la rue',
          'locality': 'Ville',
          'postalCode': 'H0H 0H0',
          'priority': 3
        }
      ];
      expect(serialized, {
        'itinerary': [
          {
            'id': 'firstId',
            'date': DateTime(2021, 1, 1).millisecondsSinceEpoch,
            'waypoints': serializedWaypoints,
          },
          {
            'id': isNotNull,
            'date': DateTime(2021, 1, 2).millisecondsSinceEpoch,
            'waypoints': serializedWaypoints,
          },
          {
            'id': isNotNull,
            'date': DateTime(2021, 1, 3).millisecondsSinceEpoch,
            'waypoints': serializedWaypoints,
          },
        ]
      });
    });

    test('"deserializeItem" works', () {
      final itineraries = ItinerariesProvider(mockMe: true);
      final itinerary = itineraries.deserializeItem({
        'date': DateTime(2021, 1, 1).millisecondsSinceEpoch,
        'visits': [],
      });
      expect(itinerary.date, DateTime(2021, 1, 1));
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withItineraries: true);
      final itineraries = ItinerariesProvider.of(context, listen: false);
      expect(itineraries, isNotNull);
    });
  });

  group('SchoolsProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('deserializeItem works', () {
      final schools = SchoolsProvider(mockMe: true);
      final school = schools.deserializeItem({'name': 'Test School'});
      expect(school.name, 'Test School');
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withSchools: true);
      final schools = SchoolsProvider.of(context, listen: false);
      expect(schools, isNotNull);
    });
  });

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
      final students = StudentsProvider(mockMe: true);
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

  group('TeachersProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('"currentTeacherId" works', () {
      final teachers = TeachersProvider(mockMe: true);
      expect(() => teachers.currentTeacherId, throwsException);

      teachers.initializeAuth(AuthProvider(mockMe: true));
      expect(teachers.currentTeacherId, 'Mock User');
    });

    test('"getCurrentTeacher" works', () {
      final teachers = TeachersProvider(mockMe: true);
      expect(teachers.currentTeacher.firstName, 'Error');

      final auth = AuthProvider(mockMe: true);
      teachers.initializeAuth(auth);
      teachers.add(dummyTeacher());
      expect(teachers.currentTeacher.firstName, 'Error');

      teachers.add(dummyTeacher(id: auth.currentUser!.uid));
      expect(teachers.currentTeacher.firstName, 'Pierre');
    });

    test('"deserializeItem" works', () {
      final teachers = TeachersProvider(mockMe: true);
      final teacher = teachers.deserializeItem(dummyTeacher().serialize());

      expect(teacher.firstName, 'Pierre');
      expect(teacher.middleName, 'Jean');
      expect(teacher.lastName, 'Jacques');
      expect(teacher.schoolId, 'schoolId');
      expect(teacher.email, 'peter.john.jakob@test.com');
      expect(teacher.groups, ['101', '102']);
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withTeachers: true);
      final teachers = TeachersProvider.of(context, listen: false);
      expect(teachers, isNotNull);
    });
  });
}
