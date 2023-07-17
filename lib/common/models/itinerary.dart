import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:nanoid/nanoid.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import 'waypoints.dart';

class Itinerary extends ListSerializable<Waypoint>
    implements Iterator<Waypoint>, ItemSerializable {
  final DateTime date;
  final String dateAsString;
  static final dateFormat = DateFormat('dd_MM_yyyy');

  Itinerary({String? id, required this.date})
      : _myId = id ?? nanoid(),
        dateAsString = dateFormat.format(date);

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

  static Itinerary fromSerialized(map) {
    final out = Itinerary(
        id: map['id'], date: DateTime.fromMillisecondsSinceEpoch(map['date']));
    for (final waypoint in map['waypoints']) {
      out.add(Waypoint.deserialize(waypoint));
    }
    return out;
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

  final String _myId;
  @override
  late final String id = _myId;

  @override
  Map<String, dynamic> serialize() => serializedMap();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'date': date.millisecondsSinceEpoch,
        'waypoints': super.map((e) => e.serialize()).toList()
      };
}
