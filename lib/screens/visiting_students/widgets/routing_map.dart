import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import '../models/waypoints.dart';

class RoutingMap extends StatefulWidget {
  const RoutingMap({Key? key}) : super(key: key);

  @override
  State<RoutingMap> createState() => _RoutingMapState();
}

class _RoutingMapState extends State<RoutingMap> {
  double? _routeDistance;
  Future<List<Polyline>> _route = Future<List<Polyline>>.value([]);

  Future<List<Polyline>> _getActivateRoute() async {
    _routeDistance = null;
    final waypoints = Provider.of<Waypoints>(context, listen: false);
    if (waypoints.activeLength <= 1) return [];

    final manager = OSRMManager();
    final route = waypoints.toLngLat(activeOnly: true);

    final road = await manager.getTrip(
      waypoints: route,
      roundTrip: true,
      geometry: Geometries.geojson,
      steps: false,
      languageCode: "en",
    );
    _routeDistance = road.distance;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("La trajectoire apparaitra lors de la mise à jour 0.3.2"),
      ));
    }
    if (road.polyline == null) return [Polyline(points: [])];
    setState(() {});
    return [
      Polyline(
        points: Waypoints.fromLngLatToLatLng(road.polyline!),
        strokeWidth: 4,
        color: Colors.red,
      )
    ];
  }

  void _clickOnWaypoint(int index) {
    final waypoints = Provider.of<Waypoints>(context, listen: false);
    waypoints[index] =
        waypoints[index].copyWith(isActivated: !waypoints[index].isActivated);
    _route = _getActivateRoute();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _forceUpdateRoute();
  }

  void _forceUpdateRoute() {
    Provider.of<Waypoints>(context);
    _route = _getActivateRoute();
    setState(() {});
  }

  List<Marker> _waypointsToMarkers() {
    final waypoints = Provider.of<Waypoints>(context, listen: false);
    List<Marker> out = [];

    const double markerSize = 50;
    for (var i = 0; i < waypoints.length; i++) {
      final waypoint = waypoints[i];
      out.add(Marker(
          point: waypoint.toLatLng(),
          anchorPos: AnchorPos.exactly(Anchor(3, -15)),
          builder: (context) => GestureDetector(
                onTap: i == 0 ? () {} : () => _clickOnWaypoint(i),
                child: Icon(
                  i == 0 ? Icons.school : Icons.location_history_outlined,
                  color: waypoint.isActivated ? Colors.deepPurple : Colors.grey,
                  size: markerSize,
                ),
              )));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final distance = _routeDistance == null
        ? '\ncalcul du trajet en cours...'
        : '${_routeDistance!.toStringAsFixed(1)}km';
    return Consumer<Waypoints>(builder: (context, waypoints, child) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            waypoints.activeLength <= 1
                ? 'Aucun trajet sélectionné'
                : 'Distance de trajet prévue = $distance',
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FutureBuilder<List<Polyline>>(
                future: _route,
                builder: (context, route) {
                  if (route.hasData && waypoints.isNotEmpty) {
                    return FlutterMap(
                      options:
                          MapOptions(center: waypoints[0].toLatLng(), zoom: 14),
                      nonRotatedChildren: const [_ZoomButtons()],
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example',
                        ),
                        PolylineLayer(polylines: route.data!),
                        MarkerLayer(markers: _waypointsToMarkers()),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ZoomButtons extends StatelessWidget {
  const _ZoomButtons();
  final double minZoom = 4;
  final double maxZoom = 19;
  final bool mini = true;
  final double padding = 10;
  final Alignment alignment = Alignment.topRight;

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
