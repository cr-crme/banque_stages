import 'package:flutter/foundation.dart';

import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:geocoding/geocoding.dart';

class Waypoint {
  const Waypoint(this.latitude, this.longitude, {this.isActivated = true});

  Waypoint copyWith({latitude, longitude, isActivated}) {
    isActivated = isActivated ?? this.isActivated;
    latitude = latitude ?? this.latitude;
    longitude = longitude ?? this.longitude;
    return Waypoint(latitude, longitude, isActivated: isActivated);
  }

  static Future<Waypoint> fromAddress(String address,
      {isActivated = true}) async {
    final addresses = await locationFromAddress(address);
    var first = addresses.first;
    return Waypoint(first.latitude, first.longitude, isActivated: isActivated);
  }

  Waypoint.fromLatLng(LatLng point, {this.isActivated = true})
      : latitude = point.latitude,
        longitude = point.longitude;
  LatLng toLatLng() => LatLng(latitude, longitude);

  Waypoint.fromLngLat(LngLat point, {this.isActivated = true})
      : latitude = point.lat,
        longitude = point.lng;
  LngLat toLngLat() => LngLat(lng: longitude, lat: latitude);

  final bool isActivated;
  final double latitude;
  final double longitude;
}

class Waypoints extends Iterable with Iterator, ChangeNotifier {
  Waypoints() : waypoints = [];

  Waypoints.fromLatLng(List<LatLng> points) : waypoints = [] {
    for (final waypoint in points) {
      waypoints.add(Waypoint.fromLatLng(waypoint, isActivated: true));
    }
  }
  List<LatLng> toLatLng({bool activeOnly = false}) {
    List<LatLng> out = [];
    for (final waypoint in waypoints) {
      if (activeOnly && !waypoint.isActivated) continue;

      out.add(LatLng(waypoint.latitude, waypoint.longitude));
    }
    return out;
  }

  Waypoints.fromLngLat(List<LngLat> points) : waypoints = [] {
    for (final waypoint in points) {
      waypoints.add(Waypoint.fromLngLat(waypoint, isActivated: true));
    }
  }
  List<LngLat> toLngLat({bool activeOnly = false}) {
    List<LngLat> out = [];
    for (final waypoint in waypoints) {
      if (activeOnly && !waypoint.isActivated) continue;

      out.add(LngLat(lng: waypoint.longitude, lat: waypoint.latitude));
    }
    return out;
  }

  final List<Waypoint> waypoints;
  void add(Waypoint point) => waypoints.add(point);

  Waypoint operator [](int item) => waypoints[item];
  void operator []=(int item, Waypoint val) => waypoints[item] = val;

  // Iterator implementation
  int currentIndex = 0;

  @override
  int get length => waypoints.length;

  @override
  Waypoint get current => waypoints[currentIndex];

  @override
  bool moveNext() {
    currentIndex++;
    return currentIndex < waypoints.length;
  }

  @override
  Iterator get iterator => this;
}
