import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/itineraries_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import '../utils.dart';

void main() {
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
}
