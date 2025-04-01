import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/waypoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

// coverage:ignore-file
class ShowAddressDialog extends StatelessWidget {
  const ShowAddressDialog(this.address, {super.key});

  final Address address;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Waypoint>(
        future: Waypoint.fromAddress(title: '', address: address.toString()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final waypoint = snapshot.data!;
          return FlutterMap(
            options: MapOptions(
                initialCenter:
                    LatLng(waypoint.gcs.latitude, waypoint.gcs.longitude),
                initialZoom: 16),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              MarkerLayer(markers: [
                Marker(
                    point:
                        LatLng(waypoint.gcs.latitude, waypoint.gcs.longitude),
                    child: const Icon(
                      Icons.location_on_sharp,
                      size: 45,
                      color: Colors.purple,
                    )),
              ]),
            ],
          );
        });
  }
}
