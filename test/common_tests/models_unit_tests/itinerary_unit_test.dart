import 'package:crcrme_banque_stages/common/models/itinerary.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('Itinerary', () {
    test('"copyWith" behaves properly', () {
      final itinerary = dummyItinerary();

      final itinerarySame = itinerary.copyWith();
      expect(itinerarySame.id, itinerary.id);
      expect(itinerarySame.date.toString(), itinerary.date.toString());
      expect(itinerarySame.length, itinerary.length);
      expect(itinerarySame[0].id, itinerary[0].id);
      expect(itinerarySame[1].id, itinerary[1].id);

      final itineraryDifferent = itinerary.copyWith(
        id: 'newId',
        date: DateTime(2020, 2, 4),
        waypoints: [
          dummyWaypoint(id: 'newWaypointId'),
          dummyWaypoint(id: 'newWaypointId2'),
          dummyWaypoint(id: 'newWaypointId3'),
        ],
      );

      expect(itineraryDifferent.id, 'newId');
      expect(itineraryDifferent.date, DateTime(2020, 2, 4));
      expect(itineraryDifferent.length, 3);
      expect(itineraryDifferent[0].id, 'newWaypointId');
      expect(itineraryDifferent[1].id, 'newWaypointId2');
      expect(itineraryDifferent[2].id, 'newWaypointId3');
    });

    test('"moveNext" behaves properly', () {
      final itinerary = dummyItinerary();

      expect(itinerary.current.id, 'waypointId');
      expect(itinerary.moveNext(), isTrue);
      expect(itinerary.current.id, 'waypointId2');
      expect(itinerary.moveNext(), isFalse);
    });

    test('"toLatLng" and "toLngLat" behave properly', () {
      final itinerary = dummyItinerary();
      final latLng = itinerary.toLatLng();
      final lngLat = itinerary.toLngLat();

      int i = 0;
      for (final next in itinerary) {
        expect(latLng[i].latitude, next.latitude);
        expect(latLng[i].longitude, next.longitude);
        expect(lngLat[i].lat, next.latitude);
        expect(lngLat[i].lng, next.longitude);
        i++;
      }
      expect(i, 2);
    });

    test('"deserializeItem" behaves properly', () {
      final itinerary = Itinerary(date: DateTime(0));
      final waypoint = itinerary.deserializeItem(dummyWaypoint().serialize());

      expect(waypoint.id, 'waypointId');
    });

    test('serialization and deserialization works', () {
      final itinerary = dummyItinerary();
      final serialized = itinerary.serialize();
      final deserialized = Itinerary.fromSerialized(serialized);

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
        'id': 'itineraryId',
        'date': itinerary.date.millisecondsSinceEpoch,
        'waypoints': serializedWaypoints,
      });

      expect(deserialized.id, 'itineraryId');
      expect(deserialized.date.toString(), itinerary.date.toString());
      expect(deserialized.length, 2);
      expect(deserialized[0].id, 'waypointId');
      expect(deserialized[1].id, 'waypointId2');

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Itinerary.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.date, DateTime(0));
      expect(emptyDeserialized.length, 0);
    });
  });
}
