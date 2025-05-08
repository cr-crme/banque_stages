import 'package:common/models/itineraries/itinerary.dart';
import 'package:common/models/itineraries/waypoint.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priorities_extension.dart';
import 'package:crcrme_banque_stages/common/providers/itineraries_helpers.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/widgets/zoom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart' as routing_client;

class RoutingController {
  RoutingController({
    required this.destinations,
    required Itinerary itinerary,
    this.onItineraryChanged,
  }) : _itinerary = itinerary;

  final List<Waypoint> destinations;
  final Function()? onItineraryChanged;
  Itinerary _itinerary;
  bool _hasChanged = false;

  void saveItinerary(BuildContext context) {
    if (_hasChanged) ItinerariesHelpers.add(context, _itinerary);
  }

  void setItinerary(BuildContext context, Itinerary itinerary) {
    saveItinerary(context);

    _itinerary = itinerary;
    _hasChanged = false;
    _updateInternal();
  }

  final _routingManager = routing_client.RoutingManager();
  Function? _triggerSetState;
  routing_client.Route? _route;
  List<double> _distances = [];
  List<double> get distances => _distances;

  void addToItinerary(int destinationIndex) {
    _itinerary.add(destinations[destinationIndex].copyWith(forceNewId: true));
    _hasChanged = true;
    _updateInternal();
  }

  void removeFromItinerary(int index) {
    _itinerary.remove(index);
    _hasChanged = true;
    _updateInternal();
  }

  Future<void> _updateInternal() async {
    _route = await _getActivateRoute();

    if (_route != null) {
      _distances = _routeToDistances(_route);
    } else {
      _distances = [];
    }

    if (_triggerSetState != null) {
      _triggerSetState!();
    }
    if (onItineraryChanged != null) {
      onItineraryChanged!();
    }
  }

  Future<routing_client.Route?> _getActivateRoute() async {
    if (_itinerary.length <= 1) return null;

    final out = await _routingManager.getRoute(
        request: routing_client.OSRMRequest.route(
      waypoints: _itinerary
          .map((e) => routing_client.LngLat(lat: e.latitude, lng: e.longitude))
          .toList(),
      geometries: routing_client.Geometries.polyline,
      steps: true,
      languages: routing_client.Languages.en,
    ));

    return out;
  }

  List<double> _routeToDistances(routing_client.Route? route) {
    List<double> distances = [];

    if (route != null) {
      distances.add(0);
      for (final leg in route.instructions) {
        // Instruction that has a distance of 0, is a sub-destination. Otherwise
        // is it part part of the way to get to this sub-destination.
        if (leg.distance > 0) {
          distances[distances.length - 1] += leg.distance;
        } else {
          distances.add(0);
        }
      }
      // Pop the last item which is added by the previous loop.
      distances.removeLast();
    }

    return distances;
  }
}

class RoutingMap extends StatefulWidget {
  const RoutingMap({
    super.key,
    required this.controller,
    required this.waypoints,
    required this.itinerary,
    this.onItineraryChanged,
    this.onComputedDistancesCallback,
  });

  final RoutingController controller;
  final List<Waypoint> waypoints;
  final Function(int index)? onItineraryChanged;
  final Function(List<double>?)? onComputedDistancesCallback;
  final Itinerary itinerary;

  @override
  State<RoutingMap> createState() => _RoutingMapState();
}

class _RoutingMapState extends State<RoutingMap> {
  @override
  void initState() {
    super.initState();

    widget.controller._triggerSetState = () {
      setState(() {});
    };
  }

  List<Polyline> _routeToPolyline(routing_client.Route? route) {
    if (route == null || route.polyline == null) return [Polyline(points: [])];

    return [
      Polyline(
        points: route.polyline!.map((e) => LatLng(e.lat, e.lng)).toList(),
        strokeWidth: 4,
        color: Theme.of(context).primaryColor,
      )
    ];
  }

  void _toggleName(index) {
    widget.waypoints[index] = widget.waypoints[index]
        .copyWith(showTitle: !widget.waypoints[index].showTitle);
    setState(() {});
  }

  List<Marker> _waypointsToMarkers() {
    List<Marker> out = [];

    for (var i = 0; i < widget.waypoints.length; i++) {
      final waypoint = widget.waypoints[i];
      const markerSize = 30.0;

      double nameWidth = 160;
      double nameHeight = 100;

      final previous = out.fold<double>(
          0.0,
          (prev, e) =>
              prev +
              (e.point.latitude == waypoint.latitude &&
                      e.point.longitude == waypoint.longitude
                  ? 1.0
                  : 0.0));
      out.add(
        Marker(
          point: LatLng(waypoint.latitude, waypoint.longitude),
          alignment:
              Alignment(0.8, 0.4 * previous), // Centered almost at max right,
          width: markerSize + nameWidth,
          height: markerSize + nameHeight,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => widget.controller.addToItinerary(i),
                onLongPress: () => _toggleName(i),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(75),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    waypoint.priority.icon,
                    color: waypoint.priority.color,
                    size: markerSize,
                  ),
                ),
              ),
              if (waypoint.showTitle)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.white.withAlpha(125),
                      shape: BoxShape.rectangle),
                  child: Text(waypoint.title),
                )
            ],
          ),
        ),
      );
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FlutterMap(
        options: MapOptions(
            initialCenter: LatLng(widget.waypoints.first.latitude,
                widget.waypoints.first.longitude),
            initialZoom: 12),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          if (widget.controller._route != null)
            PolylineLayer(
                polylines: _routeToPolyline(widget.controller._route)),
          MarkerLayer(markers: _waypointsToMarkers()),
          const ZoomButtons(),
        ],
      ),
    );
  }
}
