import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/models/waypoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import '../utils.dart';

void main() {
  group('Waypoint', () {
    test('"toString" behaves properly', () {
      final waypoint = dummyWaypoint();
      expect(waypoint.toString(), 'Subtitle\n123 rue de la rue\nVille H0H 0H0');
    });

    test('"fromCoordinates" constructor behaves properly', () async {
      // This test is expected to build a Waypoint different from the sent dummy
      // because it uses the geocoding service which we can't test so far
      final waypoint = await Waypoint.fromCoordinates(
        latitude: 1.0,
        longitude: 2.0,
        title: 'title',
      );

      // Test that the waypoint is the default value for the Placemark (address)
      expect(waypoint.id, isNotEmpty);
      expect(waypoint.title, 'title');
      expect(waypoint.subtitle, isNull);
      expect(waypoint.latitude, 1.0);
      expect(waypoint.longitude, 2.0);
      expect(waypoint.address.toString(), const Placemark().toString());
      expect(waypoint.priority, VisitingPriority.notApplicable);
      expect(waypoint.showTitle, isTrue);
    });

    test('"fromAddress" constructor behaves properly', () async {
      // This test is expected to build a Waypoint different from the sent dummy
      // because it uses the geocoding service which we can't test so far
      final waypoint = await Waypoint.fromAddress(
          title: 'My wonderful place', address: 'Here');

      // Test that the waypoint is the default value for the Placemark (address)
      expect(waypoint.id, isNotEmpty);
      expect(waypoint.title, 'My wonderful place');
      expect(waypoint.subtitle, isNull);
      expect(waypoint.latitude, 0.0);
      expect(waypoint.longitude, 0.0);
      expect(waypoint.address.toString(), const Placemark().toString());
      expect(waypoint.priority, VisitingPriority.notApplicable);
      expect(waypoint.showTitle, isTrue);
    });

    test('"fromLatLng" constructor behaves properly', () async {
      // This test is expected to build a Waypoint different from the sent dummy
      // because it uses the geocoding service which we can't test so far
      final waypoint = await Waypoint.fromLatLng(
          title: 'My wonderful place', point: const LatLng(1.0, 2.0));

      // Test that the waypoint is the default value for the Placemark (address)
      expect(waypoint.id, isNotEmpty);
      expect(waypoint.title, 'My wonderful place');
      expect(waypoint.subtitle, isNull);
      expect(waypoint.latitude, 1.0);
      expect(waypoint.longitude, 2.0);
      expect(waypoint.address.toString(), const Placemark().toString());
      expect(waypoint.priority, VisitingPriority.notApplicable);
      expect(waypoint.showTitle, isTrue);
    });

    test('"fromLngLat" constructor behaves properly', () async {
      // This test is expected to build a Waypoint different from the sent dummy
      // because it uses the geocoding service which we can't test so far
      final waypoint = await Waypoint.fromLngLat(
          title: 'My wonderful place', point: LngLat(lat: 1.0, lng: 2.0));

      // Test that the waypoint is the default value for the Placemark (address)
      expect(waypoint.id, isNotEmpty);
      expect(waypoint.title, 'My wonderful place');
      expect(waypoint.subtitle, isNull);
      expect(waypoint.latitude, 1.0);
      expect(waypoint.longitude, 2.0);
      expect(waypoint.address.toString(), const Placemark().toString());
      expect(waypoint.priority, VisitingPriority.notApplicable);
      expect(waypoint.showTitle, isTrue);
    });

    test('"toLatLng" and "toLngLat" behave properly', () {
      final waypoint = dummyWaypoint();
      final latLng = waypoint.toLatLng();
      final lngLat = waypoint.toLngLat();

      expect(latLng.latitude, waypoint.latitude);
      expect(latLng.longitude, waypoint.longitude);
      expect(lngLat.lat, waypoint.latitude);
      expect(lngLat.lng, waypoint.longitude);
    });

    test('"copyWith" behaves properly', () {
      final waypoint = dummyWaypoint();

      final waypointSame = waypoint.copyWith();
      expect(waypointSame.id, waypoint.id);
      expect(waypointSame.title, waypoint.title);
      expect(waypointSame.subtitle, waypoint.subtitle);
      expect(waypointSame.latitude, waypoint.latitude);
      expect(waypointSame.longitude, waypoint.longitude);
      expect(waypointSame.address, waypoint.address);
      expect(waypointSame.priority, waypoint.priority);
      expect(waypointSame.showTitle, waypoint.showTitle);

      final waypointDifferent = waypoint.copyWith(
        id: 'newId',
        title: 'newTitle',
        subtitle: 'newSubtitle',
        latitude: 1.0,
        longitude: 2.0,
        address: const Placemark(street: 'newStreet'),
        priority: VisitingPriority.high,
        showTitle: false,
      );

      expect(waypointDifferent.id, 'newId');
      expect(waypointDifferent.title, 'newTitle');
      expect(waypointDifferent.subtitle, 'newSubtitle');
      expect(waypointDifferent.latitude, 1.0);
      expect(waypointDifferent.longitude, 2.0);
      expect(waypointDifferent.address.toString(),
          const Placemark(street: 'newStreet').toString());
      expect(waypointDifferent.priority, VisitingPriority.high);
      expect(waypointDifferent.showTitle, isFalse);
    });

    test('serialization and deserialization works', () {
      final waypoint = dummyWaypoint();
      final serialized = waypoint.serialize();
      final deserialized = Waypoint.fromSerialized(serialized);

      expect(serialized, {
        'id': waypoint.id,
        'title': waypoint.title,
        'subtitle': waypoint.subtitle,
        'latitude': waypoint.latitude,
        'longitude': waypoint.longitude,
        'street': waypoint.address.street,
        'locality': waypoint.address.locality,
        'postalCode': waypoint.address.postalCode,
        'priority': waypoint.priority.index,
      });

      expect(deserialized.id, waypoint.id);
      expect(deserialized.title, waypoint.title);
      expect(deserialized.subtitle, waypoint.subtitle);
      expect(deserialized.latitude, waypoint.latitude);
      expect(deserialized.longitude, waypoint.longitude);
      expect(deserialized.address.toString(), waypoint.address.toString());
      expect(deserialized.priority, waypoint.priority);
      expect(deserialized.showTitle, waypoint.showTitle);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Waypoint.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.title, '');
      expect(emptyDeserialized.subtitle, '');
      expect(emptyDeserialized.latitude, 0);
      expect(emptyDeserialized.longitude, 0);
      expect(
          emptyDeserialized.address.toString(), const Placemark().toString());
      expect(emptyDeserialized.priority, VisitingPriority.notApplicable);
      expect(emptyDeserialized.showTitle, isTrue);
    });
  });
}
