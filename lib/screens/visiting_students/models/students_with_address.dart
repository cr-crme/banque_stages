import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import '../../../crcrme_enhanced_containers/lib/list_provided.dart';

import './waypoints.dart';

class StudentsWithAddress extends ListProvided<Waypoint>
    with Iterator<Waypoint> {
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
}

class SelectedStudentForItinerary extends StudentsWithAddress {}
