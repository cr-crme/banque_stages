import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'student_routing_screen.dart';
import '../../common/models/waypoints.dart';

class ChooseStudentsScreen extends StatefulWidget {
  const ChooseStudentsScreen({super.key});

  static const String route = "/visiting-students/choose-students-screen";

  @override
  State<ChooseStudentsScreen> createState() => _ChooseStudentsScreenState();
}

class _ChooseStudentsScreenState extends State<ChooseStudentsScreen> {
  @override
  void initState() {
    super.initState();
    addWaypoints();
  }

  void addWaypoints() async {
    final waypoints = Provider.of<Waypoints>(context, listen: false);
    waypoints.add(await Waypoint.fromAddress("1400 Tillemont, Montréal"));
    waypoints
        .add(await Waypoint.fromAddress("CRME, Montréal", isActivated: false));
    waypoints.add(await Waypoint.fromAddress("Métro Jarry, Montréal"));
  }

  @override
  Widget build(BuildContext context) {
    final waypoints = Provider.of<Waypoints>(context, listen: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Choix de l\'itinéraire')),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (waypoints.length > 0)
              _WaypointCard(name: "Lieu de départ", waypoint: waypoints[0]),
            if (waypoints.length > 0)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  int studentIndex = index + 1;
                  final way = waypoints[studentIndex];
                  return _WaypointCard(
                      name: "Étudiant $studentIndex",
                      waypoint: way,
                      onTap: () {
                        waypoints[studentIndex] =
                            way.copyWith(isActivated: !way.isActivated);
                      });
                },
                itemCount: waypoints.length - 1,
              ),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: () => Navigator.popAndPushNamed(
                    context, StudentRoutingScreen.route),
                child: const Text('Générer l\'itinéraire'))
          ],
        ),
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
