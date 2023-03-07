import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import 'waypoints.dart';

class LngLatUtils {
  static fromLatLngToLngLat(List<LatLng> toConvert) {
    List<LngLat> out = [];
    for (final point in toConvert) {
      out.add(LngLat(lng: point.longitude, lat: point.latitude));
    }
    return out;
  }

  static fromWaypointToLngLat(List<Waypoint> toConvert) {
    List<LngLat> out = [];
    for (final point in toConvert) {
      out.add(LngLat(lng: point.longitude, lat: point.latitude));
    }
    return out;
  }

  static fromLngLatToLatLng(List<LngLat> toConvert) {
    List<LatLng> out = [];
    for (final point in toConvert) {
      out.add(LatLng(point.lat, point.lng));
    }
    return out;
  }

  static fromWaypointtToLatLng(List<Waypoint> toConvert) {
    List<LatLng> out = [];
    for (final point in toConvert) {
      out.add(LatLng(point.latitude, point.longitude));
    }
    return out;
  }

  static LatLng meanLatLng(List<Waypoint> waypoints) {
    double lat = 0;
    double long = 0;
    for (final waypoint in waypoints) {
      lat += waypoint.latitude;
      long += waypoint.longitude;
    }

    return LatLng(lat / waypoints.length, long / waypoints.length);
  }
}
