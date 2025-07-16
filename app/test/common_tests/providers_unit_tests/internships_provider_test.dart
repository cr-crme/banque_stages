import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/program_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import '../utils.dart';

void main() {
  group('InternshipsProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    ProgramInitializer.initialize(mockMe: true);

    test('"byStudentId" return the right student', () {
      final internships =
          InternshipsProvider(uri: Uri.parse('ws://localhost'), mockMe: true);
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
      final internships =
          InternshipsProvider(uri: Uri.parse('ws://localhost'), mockMe: true);
      final internship = internships.deserializeItem({
        'student_id': '123',
        'enterprise_id': '456',
        'priority': 0,
      });
      expect(internship.studentId, '123');
      expect(internship.enterpriseId, '456');
      expect(internship.visitingPriority, VisitingPriority.low);
    });

    test('can replace priority', () {
      final internships =
          InternshipsProvider(uri: Uri.parse('ws://localhost'), mockMe: true);
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
}
