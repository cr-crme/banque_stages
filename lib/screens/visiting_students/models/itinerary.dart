import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:latlong2/latlong.dart';
import 'package:nanoid/nanoid.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import 'waypoints.dart';

class Itinerary extends ListSerializable<Waypoint>
    with Iterator<Waypoint>
    implements ItemSerializable {
  List<LatLng> toLatLng() {
    List<LatLng> out = [];
    for (final address in this) {
      out.add(LatLng(address.latitude, address.longitude));
    }
    return out;
  }

  List<LngLat> toLngLat() {
    List<LngLat> out = [];
    for (final address in this) {
      out.add(LngLat(lng: address.longitude, lat: address.latitude));
    }
    return out;
  }

  @override
  Waypoint deserializeItem(data) {
    return Waypoint.deserialize(data);
  }

  // Iterator implementation
  int _currentIndex = 0;

  @override
  Waypoint get current => this[_currentIndex];

  @override
  bool moveNext() {
    _currentIndex++;
    return _currentIndex < length;
  }

  @override
  final String id = nanoid();

  @override
  Map<String, dynamic> serializedMap() {
    final map = <String, dynamic>{};
    for (final waypoint in this) {
      map[waypoint.id] = waypoint.serialize();
    }
    return map;
  }
}
