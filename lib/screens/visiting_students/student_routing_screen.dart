import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import '../../common/models/waypoints.dart';

class StudentRoutingScreen extends StatefulWidget {
  static const String route = 'polyline';

  const StudentRoutingScreen({Key? key}) : super(key: key);

  @override
  State<StudentRoutingScreen> createState() => _StudentRoutingScreenState();
}

class _StudentRoutingScreenState extends State<StudentRoutingScreen> {
  Future<List<Polyline>> _route = Future<List<Polyline>>.value([]);
  Waypoints? _waypoints;

  @override
  void initState() {
    super.initState();
    _waypoints = Provider.of<Waypoints>(context, listen: false);
    _route = _getActivateRoute();
  }

  Future<List<Polyline>> _getActivateRoute() async {
    //if (_waypoints == null || _waypoints!.isEmpty) return [];
    _waypoints!.add(await Waypoint.fromAddress("1400 Tillemont, Montréal"));
    _waypoints!.add(await Waypoint.fromAddress("CRME, Montréal"));

    final manager = OSRMManager();
    final road = await manager.getRoad(
      waypoints: _waypoints!.toLngLat(activeOnly: true),
      geometrie: Geometries.geojson,
      steps: true,
      languageCode: "en",
    );
    if (road.polyline == null) return [Polyline(points: [])];

    return [
      Polyline(
        points: Waypoints.fromLngLat(road.polyline!).toLatLng(),
        strokeWidth: 4,
        color: Colors.red,
      )
    ];
  }

  void _clickOnWaypoint(int index) {
    _waypoints![index] = _waypoints![index]
        .copyWith(isActivated: !_waypoints![index].isActivated);
    _route = _getActivateRoute();
    setState(() {});
  }

  List<Marker> _waypointsToMarkers() {
    List<Marker> out = [];

    const double markerSize = 50;
    if (_waypoints != null) {
      for (var i = 0; i < _waypoints!.length; i++) {
        final waypoint = _waypoints![i];
        out.add(Marker(
            point: waypoint.toLatLng(),
            anchorPos: AnchorPos.exactly(Anchor(3, -15)),
            builder: (context) => GestureDetector(
                  onTap: () => _clickOnWaypoint(i),
                  child: Icon(
                    Icons.location_history_outlined,
                    color:
                        waypoint.isActivated ? Colors.deepPurple : Colors.grey,
                    size: markerSize,
                  ),
                )));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Polylines')),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text('Polylines'),
              ),
              FutureBuilder<List<Polyline>>(
                future: _route,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                      child: FlutterMap(
                        options: MapOptions(
                            center: LatLng(52.517037, 13.388860), zoom: 14),
                        nonRotatedChildren: const [_ZoomButtons()],
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'dev.fleaflet.flutter_map.example',
                          ),
                          PolylineLayer(polylines: snapshot.data!),
                          MarkerLayer(markers: _waypointsToMarkers()),
                        ],
                      ),
                    );
                  }
                  return const Expanded(
                      child: Center(child: CircularProgressIndicator()));
                },
              )
            ],
          ),
        ));
  }
}

class _ZoomButtons extends StatelessWidget {
  const _ZoomButtons();
  final double minZoom = 4;
  final double maxZoom = 19;
  final bool mini = true;
  final double padding = 10;
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
