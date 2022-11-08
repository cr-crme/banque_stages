import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import '../../../crcrme_enhanced_containers/lib/list_provided.dart';

import './waypoints.dart';

class StudentsWithAddress extends ListProvided<Waypoint>
    with Iterator<Waypoint> {
  List<LatLng> toLatLng({bool activeOnly = false}) {
    List<LatLng> out = [];
    for (final address in this) {
      if (activeOnly && !address.isActivated) continue;

      out.add(LatLng(address.latitude, address.longitude));
    }
    return out;
  }

  List<LngLat> toLngLat({bool activeOnly = false}) {
    List<LngLat> out = [];
    for (final address in this) {
      if (activeOnly && !address.isActivated) continue;

      out.add(LngLat(lng: address.longitude, lat: address.latitude));
    }
    return out;
  }

  @override
  Waypoint deserializeItem(data) {
    return Waypoint.deserialize(data);
  }

  // LatLng get meanLatLng => LngLatUtils.meanLatLng(this);

  bool get hasActivated {
    for (final point in this) {
      if (point.isActivated) return true;
    }
    return false;
  }

  // Iterator implementation
  int _currentIndex = 0;
  int get activeLength {
    int total = 0;
    for (final address in this) {
      if (address.isActivated) total++;
    }
    return total;
  }

  @override
  Waypoint get current => this[_currentIndex];

  @override
  bool moveNext() {
    _currentIndex++;
    return _currentIndex < length;
  }
}
