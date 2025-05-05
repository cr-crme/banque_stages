import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('ItinerariesProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('"add" works', () async {
      final teachers =
          TeachersProvider(uri: Uri.parse('ws://localhost'), mockMe: true);
      teachers.initializeAuth(AuthProvider(mockMe: true));
      final itineraries = [...teachers.currentTeacher.itineraries];

      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 1)));
      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 2)));
      itineraries.add(dummyItinerary(date: DateTime(2021, 1, 3)));

      final teacherItineraries = teachers.currentTeacher.itineraries;
      expect(teacherItineraries.length, 0);

      // TODO FROM HERE
      expect(itineraries.length, 3);
      expect(itineraries[0].date, DateTime(2021, 1, 1));
      expect(itineraries[1].date, DateTime(2021, 1, 2));
      expect(itineraries[2].date, DateTime(2021, 1, 3));
    });

    test('"replace" works', () {
      // TODO FROM HERE
      // final itineraries = ItinerariesProvider(mockMe: true);
      // itineraries.initializeAuth(AuthProvider(mockMe: true));

      // itineraries
      //     .add(dummyItinerary(id: 'itineraryId', date: DateTime(2021, 1, 1)));
      // itineraries
      //     .add(dummyItinerary(id: 'itineraryId2', date: DateTime(2021, 1, 2)));
      // itineraries
      //     .add(dummyItinerary(id: 'itineraryId3', date: DateTime(2021, 1, 3)));

      // expect(itineraries.length, 3);
      // expect(itineraries[0].length, 2);
      // expect(itineraries[1].length, 2);
      // expect(itineraries[2].length, 2);

      // // This is an indirect call to replace
      // itineraries.add(itineraries[0].copyWith(waypoints: []));
      // expect(itineraries.length, 3);
      // expect(itineraries[0].length, 0);
      // expect(itineraries[1].length, 2);
      // expect(itineraries[2].length, 2);

      // // This is a direct call to replace
      // itineraries
      //     .replace(itineraries[0].copyWith(waypoints: [dummyWaypoint()]));
      // expect(itineraries.length, 3);
      // expect(itineraries[0].length, 1);
      // expect(itineraries[1].length, 2);
      // expect(itineraries[2].length, 2);
    });

    test('"hasDate" works', () {
      // TODO
      // final itineraries = ItinerariesProvider(mockMe: true);
      // itineraries.initializeAuth(AuthProvider(mockMe: true));

      // itineraries.add(dummyItinerary(date: DateTime(2021, 1, 1)));
      // itineraries.add(dummyItinerary(date: DateTime(2021, 1, 2)));
      // itineraries.add(dummyItinerary(date: DateTime(2021, 1, 3)));

      // expect(itineraries.hasDate(DateTime(2021, 1, 1)), isTrue);
      // expect(itineraries.hasDate(DateTime(2021, 1, 2)), isTrue);
      // expect(itineraries.hasDate(DateTime(2021, 1, 3)), isTrue);
      // expect(itineraries.hasDate(DateTime(2021, 1, 4)), isFalse);
    });

    test('"fromDate" works', () {
      // TODO FROM HERE
      // final itineraries = ItinerariesProvider(mockMe: true);
      // itineraries.initializeAuth(AuthProvider(mockMe: true));

      // itineraries.add(dummyItinerary(date: DateTime(2021, 1, 1)));
      // itineraries.add(dummyItinerary(date: DateTime(2021, 1, 2)));
      // itineraries.add(dummyItinerary(date: DateTime(2021, 1, 3)));

      // expect(itineraries.fromDate(DateTime(2021, 1, 1)), isNotNull);
      // expect(itineraries.fromDate(DateTime(2021, 1, 2)), isNotNull);
      // expect(itineraries.fromDate(DateTime(2021, 1, 3)), isNotNull);
      // expect(itineraries.fromDate(DateTime(2021, 1, 4)), isNull);
    });
  });
}
