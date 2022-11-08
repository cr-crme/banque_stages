import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import '../models/lng_lat_utils.dart';
import '../models/students_with_address.dart';
import '../models/waypoints.dart';

class RoutingMap extends StatefulWidget {
  const RoutingMap({
    Key? key,
    required this.onClickWaypointCallback,
    this.onComputedDistancesCallback,
  }) : super(key: key);

  final Function(int index) onClickWaypointCallback;
  final Function(List<double>?)? onComputedDistancesCallback;

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
    final students = Provider.of<SelectedStudentForItinerary>(context);
    _road = _getActivatedRoute(students);
    setState(() {});
  }

  Future<Road?> _getActivatedRoute(SelectedStudentForItinerary students) async {
    if (students.isEmpty) return null;

    final manager = OSRMManager();
    final route = students.toLngLat();

    late final out;
    try {
      out = await manager.getRoad(
        waypoints: route,
        geometrie: Geometries.geojson,
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

  List<Marker> _waypointsToMarkers() {
    final students = Provider.of<StudentsWithAddress>(context, listen: false);
    List<Marker> out = [];

    const double markerSize = 40;
    for (var i = 0; i < students.length; i++) {
      final waypoint = students[i];
      final color = waypoint.priority == Priority.low
          ? Colors.green
          : waypoint.priority == Priority.mid
              ? Colors.orange
              : waypoint.priority == Priority.high
                  ? Colors.red
                  : Colors.deepPurple;

      out.add(
        Marker(
          point: waypoint.toLatLng(),
          anchorPos: AnchorPos.align(AnchorAlign.top),
          height: markerSize + 1,
          width: markerSize + 1,
          builder: (context) => GestureDetector(
            onTap: () => widget.onClickWaypointCallback(i),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(75),
                shape: BoxShape.circle,
              ),
              child: Icon(
                i == 0 ? Icons.school : Icons.location_on_sharp,
                color: color,
                size: markerSize,
              ),
            ),
          ),
        ),
      );
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentsWithAddress>(builder: (context, students, child) {
      if (students.isEmpty) return const CircularProgressIndicator();

      return Padding(
        padding: const EdgeInsets.all(8),
        child: FlutterMap(
          options: MapOptions(center: students[0].toLatLng(), zoom: 14),
          nonRotatedChildren: const [_ZoomButtons()],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            ),
            FutureBuilder<Road?>(
              future: _road,
              builder: (context, road) {
                if (!road.hasData || students.isEmpty) return Container();
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

class _ZoomButtons extends StatelessWidget {
  const _ZoomButtons();
  final double minZoom = 4;
  final double maxZoom = 19;
  final bool mini = true;
  final double padding = 5;
  final Alignment alignment = Alignment.bottomRight;

  final FitBoundsOptions options =
      const FitBoundsOptions(padding: EdgeInsets.all(12));

  @override
  Widget build(BuildContext context) {
    final map = FlutterMapState.maybeOf(context)!;
    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(left: padding, top: padding, right: padding),
            child: FloatingActionButton(
              heroTag: 'zoomInButton',
              mini: mini,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                final bounds = map.bounds;
                final centerZoom = map.getBoundsCenterZoom(bounds, options);
                var zoom = centerZoom.zoom + 1;
                if (zoom > maxZoom) {
                  zoom = maxZoom;
                }
                map.move(centerZoom.center, zoom,
                    source: MapEventSource.custom);
              },
              child: Icon(Icons.zoom_in, color: IconTheme.of(context).color),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: FloatingActionButton(
              heroTag: 'zoomOutButton',
              mini: mini,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                final bounds = map.bounds;
                final centerZoom = map.getBoundsCenterZoom(bounds, options);
                var zoom = centerZoom.zoom - 1;
                if (zoom < minZoom) {
                  zoom = minZoom;
                }
                map.move(centerZoom.center, zoom,
                    source: MapEventSource.custom);
              },
              child: Icon(Icons.zoom_out, color: IconTheme.of(context).color),
            ),
          ),
        ],
      ),
    );
  }
}
