import 'package:flutter/foundation.dart';

import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:geocoding/geocoding.dart';

class Waypoint {
  Waypoint(this.latitude, this.longitude,
      {required this.address, this.isActivated = true});

  static Future<Waypoint> fromCoordinates(latitude, longitude,
      {isActivated}) async {
    final placemark =
        (await placemarkFromCoordinates(latitude, longitude)).first;
    final address =
        "${placemark.street}, ${placemark.locality} ${placemark.postalCode}";
    return Waypoint(latitude, longitude,
        address: address, isActivated: isActivated);
  }

  Waypoint copyWith({latitude, longitude, address, isActivated}) {
    isActivated = isActivated ?? this.isActivated;
    latitude = latitude ?? this.latitude;
    longitude = longitude ?? this.longitude;
    address = address ?? this.address;
    return Waypoint(latitude, longitude,
        address: address, isActivated: isActivated);
  }

  static Future<Waypoint> fromAddress(String address,
      {isActivated = true}) async {
    final locations = await locationFromAddress(address);
    var first = locations.first;
    return Waypoint.fromCoordinates(first.latitude, first.longitude,
        isActivated: isActivated);
  }

  static Future<Waypoint> fromLatLng(LatLng point, {isActivated = true}) async {
    return Waypoint.fromCoordinates(point.latitude, point.longitude,
        isActivated: isActivated);
  }

  LatLng toLatLng() => LatLng(latitude, longitude);

  static Future<Waypoint> fromLngLat(LngLat point, {isActivated = true}) {
    return Waypoint.fromCoordinates(point.lat, point.lng,
        isActivated: isActivated);
  }

  LngLat toLngLat() => LngLat(lng: longitude, lat: latitude);

  final bool isActivated;
  final double latitude;
  final double longitude;
  late final String address;

  @override
  String toString() {
    return address;
  }
}

class Waypoints extends Iterable with Iterator, ChangeNotifier {
  Waypoints() : waypoints = [];

  static Future<Waypoints> fromLatLng(List<LatLng> points) async {
    final out = Waypoints();
    for (final waypoint in points) {
      out.waypoints.add(await Waypoint.fromLatLng(waypoint, isActivated: true));
    }
    return out;
  }

  List<LatLng> toLatLng({bool activeOnly = false}) {
    List<LatLng> out = [];
    for (final waypoint in waypoints) {
      if (activeOnly && !waypoint.isActivated) continue;

      out.add(LatLng(waypoint.latitude, waypoint.longitude));
    }
    return out;
  }

  static Future<Waypoints> fromLngLat(List<LngLat> points) async {
    final out = Waypoints();

    for (final waypoint in points) {
      out.waypoints.add(await Waypoint.fromLngLat(waypoint, isActivated: true));
    }
    return out;
  }

  List<LngLat> toLngLat({bool activeOnly = false}) {
    List<LngLat> out = [];
    for (final waypoint in waypoints) {
      if (activeOnly && !waypoint.isActivated) continue;

      out.add(LngLat(lng: waypoint.longitude, lat: waypoint.latitude));
    }
    return out;
  }

  late final List<Waypoint> waypoints;
  void add(Waypoint point) {
    waypoints.add(point);
    notifyListeners();
  }

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
