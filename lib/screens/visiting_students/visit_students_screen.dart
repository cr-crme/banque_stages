import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/routing_map.dart';
import 'models/waypoints.dart';

class VisitStudentScreen extends StatefulWidget {
  const VisitStudentScreen({super.key});

  static const String route = "/visiting-students/choose-students-screen";

  @override
  State<VisitStudentScreen> createState() => _VisitStudentScreenState();
}

class _VisitStudentScreenState extends State<VisitStudentScreen> {
  @override
  void initState() {
    super.initState();

    final waypoints = Provider.of<Waypoints>(context, listen: false);
    if (waypoints.isEmpty) addWaypoints();
  }

  void addWaypoints() async {
    final waypoints = Provider.of<Waypoints>(context, listen: false);
    waypoints
        .add(await Waypoint.fromAddress("École", "1400 Tillemont, Montréal"));
    waypoints.add(await Waypoint.fromAddress("CRME", "CRME, Montréal",
        isActivated: false));
    waypoints.add(await Waypoint.fromAddress("Métro", "Métro Jarry, Montréal"));
    waypoints
        .add(await Waypoint.fromAddress("Café", "Café Oui mais non, Montréal"));
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
                  if (waypoints.length > 0)
                    _WaypointCard(
                        name: waypoints[0].title, waypoint: waypoints[0]),
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
                        return _WaypointCard(
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
                  const SizedBox(height: 8),
                  SizedBox(height: 500, child: static!),
                ],
              );
            }),
      ),
    );
  }
}

class _WaypointCard extends StatelessWidget {
  const _WaypointCard({
    Key? key,
    required this.name,
    required this.waypoint,
    this.onTap,
  }) : super(key: key);

  final String name;
  final Waypoint waypoint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        key: key,
        contentPadding: const EdgeInsets.all(10),
        onTap: onTap,
        leading: const CircleAvatar(backgroundColor: Colors.amber),
        title: Text(
          name,
          style: TextStyle(
              color: waypoint.isActivated ? Colors.black : Colors.grey),
        ),
        subtitle: Text(waypoint.toString(),
            style: TextStyle(
                color: waypoint.isActivated ? Colors.blueGrey : Colors.grey)),
      ),
    );
  }
}
