import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/models/waypoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '/screens/visiting_students/widgets/zoom_button.dart';

class ShowSchoolAddress extends StatelessWidget {
  const ShowSchoolAddress(this.address, {super.key});

  final Address address;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Waypoint>(
        future: Waypoint.fromAddress('', address.toString()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final waypoint = snapshot.data!;
          return FlutterMap(
            options: MapOptions(center: waypoint.toLatLng(), zoom: 16),
            nonRotatedChildren: const [ZoomButtons()],
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              MarkerLayer(markers: [
                Marker(
                    point: waypoint.toLatLng(),
                    builder: (BuildContext context) => const Icon(
                          Icons.school,
                          size: 45,
                          color: Colors.purple,
                        )),
              ]),
            ],
          );
        });
  }
}
