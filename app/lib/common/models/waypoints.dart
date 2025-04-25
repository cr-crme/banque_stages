import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/geographic_coordinate_system.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:enhanced_containers/enhanced_containers.dart';

class Waypoint extends ItemSerializable {
  final String title;
  final String? subtitle;
  final GeographicCoordinateSystem gcs;
  final Address address;
  final VisitingPriority priority;
  final bool showTitle;

  Waypoint({
    super.id,
    required this.title,
    this.subtitle,
    required this.gcs,
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
      'gcs': gcs.serialize(),
      'address': address.serialize(),
      'priority': priority.index,
    };
  }

  static Waypoint fromSerialized(data) => Waypoint(
        id: data['id'],
        title: data['title'] ?? '',
        subtitle: data['subtitle'] ?? '',
        gcs: data['gcs'] == null
            ? GeographicCoordinateSystem()
            : GeographicCoordinateSystem.fromSerialized(data['gcs']),
        address: data['address'] == null
            ? Address()
            : Address.fromSerialized(data['address']),
        priority: data['priority'] == null
            ? VisitingPriority.notApplicable
            : VisitingPriority.values[data['priority']],
      );

  static Future<Waypoint> fromCoordinates({
    required String title,
    String? subtitle,
    required GeographicCoordinateSystem gcs,
    priority = VisitingPriority.notApplicable,
    showTitle = true,
  }) async {
    final address = await Address.fromCoordinates(gcs);

    return Waypoint(
      title: title,
      subtitle: subtitle,
      gcs: gcs,
      address: address ?? Address(),
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
  }) async =>
      Waypoint.fromCoordinates(
        title: title,
        subtitle: subtitle,
        gcs: await GeographicCoordinateSystem.fromAddress(address),
        priority: priority,
        showTitle: showTitle,
      );

  Waypoint copyWith({
    bool forceNewId = false,
    String? id,
    String? title,
    String? subtitle,
    GeographicCoordinateSystem? gcs,
    Address? address,
    VisitingPriority? priority,
    bool? showTitle,
  }) {
    return Waypoint(
      id: forceNewId ? null : id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      gcs: gcs ?? this.gcs,
      address: address ?? this.address,
      priority: priority ?? this.priority,
      showTitle: showTitle ?? this.showTitle,
    );
  }

  @override
  String toString() {
    String out = '';
    if (subtitle != null) out += '$subtitle\n';
    out += '${address.street}\n${address.city} ${address.postalCode}';
    return out;
  }
}
