import 'package:flutter/services.dart';
import '../../../crcrme_enhanced_containers/lib/item_serializable.dart';

import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:geocoding/geocoding.dart';

enum Priority {
  none,
  low,
  mid,
  high,
}

class Waypoint extends ItemSerializable {
  Waypoint(
    this.title,
    this.latitude,
    this.longitude, {
    required this.address,
    this.priority = Priority.low,
    this.showTitle = true,
  });

  static Future<Waypoint> fromCoordinates(
    String title,
    double latitude,
    double longitude, {
    priority = Priority.low,
    showTitle = true,
  }) async {
    late Placemark placemark;
    try {
      placemark = (await placemarkFromCoordinates(latitude, longitude)).first;
    } catch (e) {
      placemark = Placemark();
    }

    return Waypoint(
      title,
      latitude,
      longitude,
      address: placemark,
      priority: priority,
      showTitle: showTitle,
    );
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'street': address.street,
      'locality': address.locality,
      'postalCode': address.postalCode,
      'priority': priority,
    };
  }

  static Waypoint deserialize(Map<String, dynamic> data) {
    final address = Placemark(
      street: data['street'],
      locality: data['locality'],
      postalCode: data['postalCode'],
    );
    return Waypoint(
      data['title'],
      data['latitude'],
      data['longitude'],
      address: address,
      priority: data['priority'] as Priority,
    );
  }

  static Waypoint copy(Waypoint other) {
    return Waypoint(
      other.title,
      other.latitude,
      other.longitude,
      address: other.address,
      priority: other.priority,
      showTitle: other.showTitle,
    );
  }

  Waypoint copyWith({
    String? title,
    double? latitude,
    double? longitude,
    Placemark? address,
    Priority? priority,
    bool? showTitle,
  }) {
    title = title ?? this.title;
    latitude = latitude ?? this.latitude;
    longitude = longitude ?? this.longitude;
    address = address ?? this.address;
    priority = priority ?? this.priority;
    showTitle = showTitle ?? this.showTitle;
    return Waypoint(
      title,
      latitude,
      longitude,
      address: address,
      priority: priority,
      showTitle: showTitle,
    );
  }

  static Future<Waypoint> fromAddress(
    String title,
    String address, {
    priority = Priority.low,
    showTitle = true,
  }) async {
    late List<Location> locations;
    try {
      locations = await locationFromAddress(address);
    } on PlatformException {
      return Waypoint('', 0.0, 0.0, address: Placemark());
    }

    var first = locations.first;
    return Waypoint.fromCoordinates(
      title,
      first.latitude,
      first.longitude,
      priority: priority,
      showTitle: showTitle,
    );
  }

  static Future<Waypoint> fromLatLng(String title, LatLng point,
      {priority = Priority.low, showTitle = true}) async {
    return Waypoint.fromCoordinates(
      title,
      point.latitude,
      point.longitude,
      priority: priority,
      showTitle: showTitle,
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);

  static Future<Waypoint> fromLngLat(
    String title,
    LngLat point, {
    priority = Priority.low,
    showTitle = true,
  }) {
    return Waypoint.fromCoordinates(
      title,
      point.lat,
      point.lng,
      priority: priority,
      showTitle: showTitle,
    );
  }

  LngLat toLngLat() => LngLat(lng: longitude, lat: latitude);

  final String title;
  final double latitude;
  final double longitude;
  final Placemark address;
  final Priority priority;
  final bool showTitle;

  @override
  String toString() =>
      '${address.street}\n${address.locality} ${address.postalCode}';
}