import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import '/common/models/visiting_priority.dart';
import '/screens/visiting_students/widgets/zoom_button.dart';
import '../models/all_itineraries.dart';
import '../models/lng_lat_utils.dart';

class RoutingMap extends StatefulWidget {
  const RoutingMap({
    Key? key,
    required this.currentDate,
    this.onClickWaypointCallback,
    this.onComputedDistancesCallback,
  }) : super(key: key);

  final Function(int index)? onClickWaypointCallback;
  final Function(List<double>?)? onComputedDistancesCallback;
  final String currentDate;

  @override
  State<RoutingMap> createState() => _RoutingMapState();
}

class _RoutingMapState extends State<RoutingMap> {
  Future<Road?> _road = Future<Road?>.value();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    computeRoute();
  }

  void computeRoute() {
    final itineraries = Provider.of<AllItineraries>(context);
    _road = _getActivatedRoute(itineraries);
    setState(() {});
  }

  Future<Road?> _getActivatedRoute(AllItineraries itineraries) async {
    if (itineraries.isEmpty) return null;

    final manager = OSRMManager();
    final route = itineraries[widget.currentDate]!.toLngLat();

    late Road out;
    try {
      out = await manager.getRoad(
        waypoints: route,
        geometries: Geometries.geojson,
      );
    } catch (e) {
      out = Road(
          distance: 0, duration: 0, instructions: [], polylineEncoded: null);
    }

    if (widget.onComputedDistancesCallback != null) {
      widget.onComputedDistancesCallback!(_roadToDistances(out));
    }

    return out;
  }

  List<Polyline> _roadToPolyline(Road? road) {
    if (road == null || road.polyline == null) return [Polyline(points: [])];

    return [
      Polyline(
        points: LngLatUtils.fromLngLatToLatLng(road.polyline!),
        strokeWidth: 4,
        color: Colors.red,
      )
    ];
  }

  List<double> _roadToDistances(Road? road) {
    List<double> distances = [];

    if (road != null) {
      for (final leg in road.details.roadLegs) {
        distances.add(leg.distance);
      }
    }

    return distances;
  }

  void _toggleName(index) {
    final waypoints = Provider.of<AllStudentsWaypoints>(context, listen: false);
    waypoints[index] =
        waypoints[index].copyWith(showTitle: !waypoints[index].showTitle);
    setState(() {});
  }

  List<Marker> _waypointsToMarkers() {
    final waypoints = Provider.of<AllStudentsWaypoints>(context, listen: false);
    List<Marker> out = [];

    for (var i = 0; i < waypoints.length; i++) {
      final waypoint = waypoints[i];
      const markerSize = 30.0;

      double nameWidth = 160;
      double nameHeight = 100;
      final previous = out.fold<int>(0, (prev, e) {
        final newLatLng = waypoint.toLatLng();
        return prev +
            (e.point.latitude == newLatLng.latitude &&
                    e.point.longitude == newLatLng.longitude
                ? 1
                : 0);
      });
      out.add(
        Marker(
          point: waypoint.toLatLng(),
          anchorPos: AnchorPos.exactly(Anchor(markerSize / 2 + nameWidth,
              nameHeight / 2 + previous * nameHeight / 5)),
          width: markerSize + nameWidth,
          height: markerSize + nameHeight,
          builder: (context) => Row(
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
    return Consumer<AllStudentsWaypoints>(builder: (context, waypoints, child) {
      if (waypoints.isEmpty) {
        // The column is necessary otherwise the ProgressIndicator is huge
        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [CircularProgressIndicator()]);
      }

      return Padding(
        padding: const EdgeInsets.all(8),
        child: FlutterMap(
          options: MapOptions(center: waypoints[0].toLatLng(), zoom: 12),
          nonRotatedChildren: const [ZoomButtons()],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            ),
            FutureBuilder<Road?>(
              future: _road,
              builder: (context, road) {
                if (!road.hasData || waypoints.isEmpty) return Container();
                return PolylineLayer(polylines: _roadToPolyline(road.data));
              },
            ),
            MarkerLayer(markers: _waypointsToMarkers()),
          ],
        ),
      );
    });
  }
}
