import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import 'visiting_priority.dart';

class Waypoint extends ItemSerializable {
  Waypoint({
    required this.title,
    this.subtitle,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.priority = VisitingPriority.notApplicable,
    this.showTitle = true,
  });

  static Future<Waypoint> fromCoordinates({
    required String title,
    String? subtitle,
    required double latitude,
    required double longitude,
    priority = VisitingPriority.notApplicable,
    showTitle = true,
  }) async {
    late Placemark placemark;
    try {
      placemark = (await placemarkFromCoordinates(latitude, longitude)).first;
    } catch (e) {
      placemark = Placemark();
    }

    return Waypoint(
      title: title,
      subtitle: subtitle,
      latitude: latitude,
      longitude: longitude,
      address: placemark,
      priority: priority,
      showTitle: showTitle,
    );
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'latitude': latitude,
      'longitude': longitude,
      'street': address.street,
      'locality': address.locality,
      'postalCode': address.postalCode,
      'priority': priority.index,
    };
  }

  static Waypoint deserialize(data) {
    final address = Placemark(
      street: data['street'],
      locality: data['locality'],
      postalCode: data['postalCode'],
    );
    return Waypoint(
      title: data['title'],
      subtitle: data['subtitle'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      address: address,
      priority: VisitingPriority.values[data['priority']],
    );
  }

  static Waypoint copy(Waypoint other) {
    return Waypoint(
      title: other.title,
      subtitle: other.subtitle,
      latitude: other.latitude,
      longitude: other.longitude,
      address: other.address,
      priority: other.priority,
      showTitle: other.showTitle,
    );
  }

  Waypoint copyWith({
    String? title,
    String? subtitle,
    double? latitude,
    double? longitude,
    Placemark? address,
    VisitingPriority? priority,
    bool? showTitle,
  }) {
    return Waypoint(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      priority: priority ?? this.priority,
      showTitle: showTitle ?? this.showTitle,
    );
  }

  static Future<Waypoint> fromAddress({
    required String title,
    String? subtitle,
    required String address,
    priority = VisitingPriority.notApplicable,
    showTitle = true,
  }) async {
    late List<Location> locations;
    try {
      locations = await locationFromAddress(address);
    } on PlatformException {
      return Waypoint(
          title: '',
          subtitle: subtitle,
          latitude: 0.0,
          longitude: 0.0,
          address: Placemark());
    }

    var first = locations.first;
    return Waypoint.fromCoordinates(
      title: title,
      subtitle: subtitle,
      latitude: first.latitude,
      longitude: first.longitude,
      priority: priority,
      showTitle: showTitle,
    );
  }

  static Future<Waypoint> fromLatLng({
    required String title,
    String? subtitle,
    required LatLng point,
    priority = VisitingPriority.notApplicable,
    showTitle = true,
  }) async {
    return Waypoint.fromCoordinates(
      title: title,
      subtitle: subtitle,
      latitude: point.latitude,
      longitude: point.longitude,
      priority: priority,
      showTitle: showTitle,
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);

  static Future<Waypoint> fromLngLat({
    required String title,
    String? subtitle,
    required LngLat point,
    priority = VisitingPriority.notApplicable,
    showTitle = true,
  }) {
    return Waypoint.fromCoordinates(
      title: title,
      subtitle: subtitle,
      latitude: point.lat,
      longitude: point.lng,
      priority: priority,
      showTitle: showTitle,
    );
  }

  LngLat toLngLat() => LngLat(lng: longitude, lat: latitude);

  final String title;
  final String? subtitle;
  final double latitude;
  final double longitude;
  final Placemark address;
  final VisitingPriority priority;
  final bool showTitle;

  @override
  String toString() {
    String out = '';
    if (subtitle != null) out += '$subtitle\n';
    out += '${address.street}\n${address.locality} ${address.postalCode}';
    return out;
  }
}
