import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/waypoints.dart';
import 'widgets/routing_map.dart';
import 'widgets/waypoint_card.dart';

class VisitStudentScreen extends StatefulWidget {
  const VisitStudentScreen({super.key});

  static const String route = "/visiting-students-screen";

  @override
  State<VisitStudentScreen> createState() => _VisitStudentScreenState();
}

class _VisitStudentScreenState extends State<VisitStudentScreen> {
  @override
  void initState() {
    super.initState();
    _setWaypoints();
  }

  void _setWaypoints() async {
    final waypoints = Provider.of<Waypoints>(context, listen: false);
    if (waypoints.isNotEmpty) return;

    final school = await Waypoint.fromAddress(
        "École (départ)", "1400 Tillemont, Montréal");

    // TODO - This should be copied from the actual student data
    waypoints.add(school, notify: false);
    waypoints.add(
        await Waypoint.fromAddress("CRME", "CRME, Montréal",
            isActivated: false),
        notify: false);
    waypoints.add(await Waypoint.fromAddress("Métro", "Métro Jarry, Montréal"),
        notify: false);
    waypoints.add(
        await Waypoint.fromAddress("Café", "Café Oui mais non, Montréal"),
        notify: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choix de l\'itinéraire')),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Consumer<Waypoints>(
            child: const RoutingMap(),
            builder: (context, waypoints, static) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const Text("Étudiants à visiter",
                      style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  if (waypoints.length > 0)
                    WaypointCard(
                      name: waypoints[0].title,
                      waypoint: waypoints[0],
                      canMove: false,
                    ),
                  if (waypoints.length > 0)
                    ReorderableListView.builder(
                      onReorder: (oldIndex, newIndex) {
                        waypoints.moveItem(oldIndex + 1, newIndex + 1);
                        setState(() {});
                      },
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        int studentIndex = index + 1;
                        final way = waypoints[studentIndex];
                        return WaypointCard(
                            key: ValueKey(way.toString()),
                            name: way.title,
                            waypoint: way,
                            onTap: () {
                              waypoints[studentIndex] =
                                  way.copyWith(isActivated: !way.isActivated);
                            });
                      },
                      itemCount: waypoints.length - 1,
                    ),
                  const SizedBox(height: 25),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: static!),
                ],
              );
            }),
      ),
    );
  }
}
