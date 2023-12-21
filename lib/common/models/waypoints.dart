import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import 'visiting_priority.dart';

class Waypoint extends ItemSerializable {
  final String title;
  final String? subtitle;
  final double latitude;
  final double longitude;
  final Placemark address;
  final VisitingPriority priority;
  final bool showTitle;

  LatLng toLatLng() => LatLng(latitude, longitude);
  LngLat toLngLat() => LngLat(lng: longitude, lat: latitude);

  Waypoint({
    super.id,
    required this.title,
    this.subtitle,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.priority = VisitingPriority.notApplicable,
    this.showTitle = true,
  });

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
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

  static Waypoint fromSerialized(data) {
    final address = Placemark(
      street: data['street'],
      locality: data['locality'],
      postalCode: data['postalCode'],
    );
    return Waypoint(
      id: data['id'],
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      latitude: data['latitude'] ?? 0,
      longitude: data['longitude'] ?? 0,
      address: address,
      priority: data['priority'] == null
          ? VisitingPriority.notApplicable
          : VisitingPriority.values[data['priority']],
    );
  }

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
    } catch (e) {
      locations = [
        Location(latitude: 0, longitude: 0, timestamp: DateTime.now())
      ];
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

  Waypoint copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? latitude,
    double? longitude,
    Placemark? address,
    VisitingPriority? priority,
    bool? showTitle,
  }) {
    return Waypoint(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      priority: priority ?? this.priority,
      showTitle: showTitle ?? this.showTitle,
    );
  }

  @override
  String toString() {
    String out = '';
    if (subtitle != null) out += '$subtitle\n';
    out += '${address.street}\n${address.locality} ${address.postalCode}';
    return out;
  }
}
