import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import '../models/lng_lat_utils.dart';
import '../models/all_itineraries.dart';
import '../../../common/models/visiting_priority.dart';

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

  MaterialColor _getWaypointColor(VisitingPriority priority) {
    switch (priority) {
      case (VisitingPriority.none):
        return Colors.deepPurple;
      case (VisitingPriority.low):
        return Colors.green;
      case (VisitingPriority.mid):
        return Colors.orange;
      case (VisitingPriority.high):
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Marker> _waypointsToMarkers() {
    final waypoints = Provider.of<AllStudentsWaypoints>(context, listen: false);
    List<Marker> out = [];

    const double markerSize = 40;
    for (var i = 0; i < waypoints.length; i++) {
      final waypoint = waypoints[i];

      double nameWidth = 160;
      double nameHeight = 100;
      out.add(
        Marker(
          point: waypoint.toLatLng(),
          anchorPos: AnchorPos.exactly(
              Anchor(markerSize / 2 + nameWidth, nameHeight / 2)),
          width: markerSize + nameWidth, //markerSize + 1,
          height: markerSize + nameHeight, //markerSize + 1,
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
                    i == 0 ? Icons.school : Icons.location_on_sharp,
                    color: _getWaypointColor(waypoint.priority),
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
          options: MapOptions(center: waypoints[0].toLatLng(), zoom: 14),
          nonRotatedChildren: const [_ZoomButtons()],
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
