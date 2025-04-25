import 'package:crcrme_banque_stages/common/models/visiting_priorities_extension.dart';
import 'package:crcrme_banque_stages/common/models/waypoints.dart';
import 'package:crcrme_banque_stages/common/providers/itineraries_provider.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/widgets/zoom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

class RoutingMap extends StatefulWidget {
  const RoutingMap({
    super.key,
    required this.currentDate,
    required this.waypoints,
    this.onClickWaypointCallback,
    this.onComputedDistancesCallback,
  });

  final List<Waypoint> waypoints;
  final Function(int index)? onClickWaypointCallback;
  final Function(List<double>?)? onComputedDistancesCallback;
  final DateTime currentDate;

  @override
  State<RoutingMap> createState() => _RoutingMapState();
}

class _RoutingMapState extends State<RoutingMap> {
  // Future<Road?> _road = Future<Road?>.value();

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   computeRoute();
  // }

  // void computeRoute() {
  //   final itineraries = Provider.of<ItinerariesProvider>(context);
  //   _road = _getActivatedRoute(itineraries);
  //   setState(() {});
  // }

  // Future<Road?> _getActivatedRoute(ItinerariesProvider itineraries) async {
  //   if (itineraries.isEmpty || !itineraries.hasDate(widget.currentDate)) {
  //     if (widget.onComputedDistancesCallback != null) {
  //       widget.onComputedDistancesCallback!([]);
  //     }
  //     return null;
  //   }

  //   final manager = OSRMManager();
  //   final route = itineraries
  //       .fromDate(widget.currentDate)!
  //       .map((e) => LngLat(lat: e.gcs.latitude, lng: e.gcs.longitude))
  //       .toList();

  //   late Road out;
  //   try {
  //     out = await manager.getRoad(
  //       waypoints: route,
  //       geometries: Geometries.geojson,
  //     );
  //   } catch (e) {
  //     out = Road(distance: 0, duration: 0, polylineEncoded: null);
  //   }

  //   if (widget.onComputedDistancesCallback != null) {
  //     widget.onComputedDistancesCallback!(_roadToDistances(out));
  //   }

  //   return out;
  // }

  // List<Polyline> _roadToPolyline(Road? road) {
  //   if (road == null || road.polyline == null) return [Polyline(points: [])];

  //   return [
  //     Polyline(
  //       points: road.polyline!.map((e) => LatLng(e.lat, e.lng)).toList(),
  //       strokeWidth: 4,
  //       color: Theme.of(context).primaryColor,
  //     )
  //   ];
  // }

  // List<double> _roadToDistances(Road? road) {
  //   List<double> distances = [];

  //   if (road != null) {
  //     for (final leg in road.details.roadLegs) {
  //       distances.add(leg.distance);
  //     }
  //   }

  //   return distances;
  // }

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
              (e.point.latitude == waypoint.gcs.latitude &&
                      e.point.longitude == waypoint.gcs.longitude
                  ? 1.0
                  : 0.0));
      out.add(
        Marker(
          point: LatLng(waypoint.gcs.latitude, waypoint.gcs.longitude),
          alignment:
              Alignment(0.8, 0.4 * previous), // Centered almost at max right,
          width: markerSize + nameWidth,
          height: markerSize + nameHeight,
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onClickWaypointCallback == null
                    ? null
                    : () => widget.onClickWaypointCallback!(i),
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
    final waypoint = widget.waypoints[0];
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FlutterMap(
        options: MapOptions(
            initialCenter:
                LatLng(waypoint.gcs.latitude, waypoint.gcs.longitude),
            initialZoom: 12),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          // FutureBuilder<Road?>(
          //   future: _road,
          //   builder: (context, road) {
          //     if (!road.hasData || widget.waypoints.isEmpty) return Container();
          //     return PolylineLayer(polylines: _roadToPolyline(road.data));
          //   },
          // ),
          MarkerLayer(markers: _waypointsToMarkers()),
          const ZoomButtons(),
        ],
      ),
    );
  }
}
